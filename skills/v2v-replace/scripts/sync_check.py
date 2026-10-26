#!/usr/bin/env python3
"""Motion-sync check between a source clip and a V2V output.

Compares motion energy (mean absolute frame difference, resampled to 24fps and smoothed over
0.25s so frame-rate-conversion judder does not dominate) of both videos:
- overall: correlation at lag 0, best lag within +/-0.5s, and its correlation
- drift: best lag on the first half vs the second half
- windows: best lag and correlation per 2s window
- optional --audio: share of motion "hits" (sharp energy drops) within 90ms of a beat
  (needs librosa; skipped when it is not installed)

Exit code 0 when the overall gate passes (best r >= --min-r and |lag| <= --max-lag-frames),
1 otherwise. Positive lag = output is late.

Usage:
  sync_check.py SRC.mp4 OUT.mp4 [--crop x0,y0,x1,y1] [--dur S] [--audio SRC_AUDIO]
"""
import argparse
import subprocess
import sys

import numpy as np

FPS = 24
MAX_LAG = 12  # frames, +/-0.5s
SMOOTH = 6  # frames, 0.25s moving average


def energy(path, dur, crop):
    vf = f"fps={FPS},scale=64:112,format=gray"
    if crop:
        x0, y0, x1, y1 = crop
        vf = f"crop=iw*{x1 - x0}:ih*{y1 - y0}:iw*{x0}:ih*{y0}," + vf
    cmd = ["ffmpeg", "-v", "error", "-i", path]
    if dur:
        cmd += ["-t", str(dur)]
    cmd += ["-vf", vf, "-f", "rawvideo", "-"]
    raw = subprocess.run(cmd, capture_output=True, check=True).stdout
    frames = np.frombuffer(raw, np.uint8).reshape(-1, 112, 64).astype(float)
    e = np.abs(np.diff(frames, axis=0)).mean(axis=(1, 2))
    return np.convolve(e, np.ones(SMOOTH) / SMOOTH, mode="valid")


def corr(a, b):
    if len(a) < 3 or a.std() == 0 or b.std() == 0:
        return float("nan")
    return float(np.corrcoef(a, b)[0, 1])


def best_lag(s, g, max_lag=MAX_LAG):
    """Return (r_at_0, best_r, lag_frames); lag > 0 means g is late."""
    n = min(len(s), len(g))
    s, g = s[:n], g[:n]
    results = []
    for k in range(-max_lag, max_lag + 1):
        a, b = (s[: n - k], g[k:]) if k >= 0 else (s[-k:], g[: n + k])
        results.append((corr(a, b), k))
    r0 = next(r for r, k in results if k == 0)
    r, k = max((x for x in results if x[0] == x[0]), default=(float("nan"), 0))
    return r0, r, k


def window_lag(s, g, i0, i1, max_lag=MAX_LAG):
    best = (float("-inf"), 0)
    for k in range(-max_lag, max_lag + 1):
        j0, j1 = i0 + k, i1 + k
        if j0 < 0 or j1 > len(g):
            continue
        r = corr(s[i0:i1], g[j0:j1])
        if r == r and r > best[0]:
            best = (r, k)
    return best


def hits(e):
    d = np.diff(e)
    thr = -np.std(d) * 0.8
    idx = [i for i in range(1, len(d) - 1) if d[i] < d[i - 1] and d[i] < d[i + 1] and d[i] < thr]
    return np.array(idx) / FPS


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src")
    ap.add_argument("out")
    ap.add_argument("--crop", help="dancer region as fractions x0,y0,x1,y1 (default: full frame)")
    ap.add_argument("--dur", type=float, help="seconds to compare (default: shorter clip)")
    ap.add_argument("--audio", help="source audio for the beat-hit report (optional, needs librosa)")
    ap.add_argument("--min-r", type=float, default=0.7)
    ap.add_argument("--max-lag-frames", type=int, default=1)
    a = ap.parse_args()

    crop = [float(x) for x in a.crop.split(",")] if a.crop else None
    s, g = energy(a.src, a.dur, crop), energy(a.out, a.dur, crop)
    n = min(len(s), len(g))
    s, g = s[:n], g[:n]

    r0, r, k = best_lag(s, g)
    h = n // 2
    _, r1, k1 = best_lag(s[:h], g[:h])
    _, r2, k2 = best_lag(s[h:], g[h:])
    print(f"frames={n} ({n / FPS:.2f}s @ {FPS}fps)")
    print(f"overall  r@0={r0:.2f}  best r={r:.2f} at lag={k / FPS:+.3f}s ({k:+d} frames)")
    print(f"drift    1st half lag={k1 / FPS:+.3f}s (r={r1:.2f})  2nd half lag={k2 / FPS:+.3f}s (r={r2:.2f})")

    print("window   lag(s)   r     verdict")
    step = 2 * FPS
    for i0 in range(0, n - FPS, step):
        i1 = min(n, i0 + step)
        wr, wk = window_lag(s, g, i0, i1)
        v = "✓" if abs(wk / FPS) <= 0.15 and wr >= 0.5 else ("△" if wr >= 0.3 else "✗")
        print(f"{i0 / FPS:>4.1f}-{i1 / FPS:<4.1f}s {wk / FPS:+.3f}  {wr:.2f}  {v}")

    if a.audio:
        try:
            import librosa
        except ImportError:
            print("beat-hit report skipped: librosa not installed")
        else:
            y, sr = librosa.load(a.audio, sr=22050)
            _, bf = librosa.beat.beat_track(y=y, sr=sr)
            beats = librosa.frames_to_time(bf, sr=sr)
            for name, e in (("src", s), ("out", g)):
                t = hits(e)
                on = np.mean([np.min(np.abs(beats - x)) <= 0.09 for x in t]) if len(t) and len(beats) else 0
                print(f"{name} hits={len(t)} on-beat(±90ms)={on:.0%}")

    ok = r == r and r >= a.min_r and abs(k) <= a.max_lag_frames
    print(f"verdict  {'PASS' if ok else 'FAIL'} (gate: best r >= {a.min_r}, |lag| <= {a.max_lag_frames} frame)")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
