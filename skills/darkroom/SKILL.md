---
name: darkroom
description: Generate images with a human in the loop. Opens the Darkroom Work in the user's Cohub tab, lets them iterate on prompts, looks, and models, and returns the one frame they pick. Use when the user asks for an image and their taste should decide, or when a first generation missed and they should steer.
---

# Darkroom

Hand image generation to the user instead of guessing for them.

`cohub generate` is the right tool when the user described exactly what they want and any competent result will do. Darkroom is the right tool when **taste decides**: cover art, a hero image, anything with a "no, more like…" in its future. It opens a studio in the user's Cohub tab, they generate and compare as many takes as they like, then pick one frame. That frame comes back to you as a durable URL.

## When To Use

Use Darkroom when:

- The user asks for an image where their judgment matters more than your prompt
- A `cohub generate` result missed and they should steer rather than re-describe
- The user wants to explore styles, models, or aspect ratios before committing
- You need one approved image to put into a document, page, or Work

Prefer `cohub generate` (the `cohub-generate` skill) when:

- The image is incidental (a placeholder, a texture, a test fixture)
- The user is not present to choose
- You need many images in a batch

## The Work

| | |
|---|---|
| Work ID | `6eaf82fb-ef91-4471-a035-c673ca03da46` |
| Public URL | https://cohub.run/tzwm/image-studio/w/darkroom |
| Reference | `tzwm/image-studio/darkroom` |
| Surface method | `image.open` |

## Open It

One command. It shows the Work in the Cohub tab this chat came from, calls `image.open`, and waits for the user's pick:

```bash
cohub ui preview tzwm/image-studio/darkroom \
  --call image.open \
  --data '{"prompt":"a persimmon on a stone ledge, overcast light"}' \
  --timeout-ms 1800000 \
  --json
```

Always pass `--data` with a `prompt`. It seeds the composer so the user starts from your reading of their request instead of a blank box.

Optionally steer the model too:

```bash
--data '{"prompt":"anime cover art, two characters back to back","model":"noobxl-t2i-onediff"}'
```

Valid `model` values come from the studio's own list: `gemini-3.1-flash-image-preview`, `gpt-image-2`, `krea2`, `noobxl-t2i-onediff`, `gemini-3.1-flash-lite-image`. Omit it unless the user named a style that clearly maps to one — the studio's default is a good general choice and the user can switch models themselves.

### Timeout

**Set `--timeout-ms` explicitly.** The default is 10 minutes, and a user browsing looks across several generations will blow through that. Use 30 minutes (`1800000`) as a baseline; the max is 12 hours (`43200000`).

If it does time out, nothing is lost — the pick is still waiting. Re-run the command to bring the studio back (a stable `--command-id` reattaches to the same pick), or ask if they still want it.

## Read The Result

On success the command prints a JSON record. The picked frame is in `result`:

```json
{
  "status": "applied",
  "result": {
    "url": "https://cca.neta.art/chat-attachments/<user>/<id>.png",
    "model": "gemini-3.1-flash-image-preview",
    "prompt": "a persimmon on a stone ledge, overcast light, soft overcast daylight",
    "parameters": { "aspect_ratio": "1:1", "image_size": "2K" }
  }
}
```

Extract the URL:

```bash
url="$(cohub ui preview tzwm/image-studio/darkroom \
  --call image.open --data "{\"prompt\":$(printf '%s' "$prompt" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}" \
  --timeout-ms 1800000 --json | python3 -c 'import json,sys; print((json.load(sys.stdin).get("result") or {}).get("url",""))')"
```

Notes on the payload:

- `prompt` is the **composed** prompt, including any look fragments the user added. It is what actually produced the image, so reuse it verbatim if you regenerate.
- The studio re-hosts a picked frame on Cohub storage when it can, so the link is usually permanent; a fallback keeps the provider's temporary URL if that fails. Images are large (a 2K frame runs several MB) — reference the URL rather than inlining the bytes.

## Other Statuses

`status` is not always `applied`. Handle these plainly:

| Status | Meaning | What to do |
|---|---|---|
| `applied` | The user picked a frame | Use `result.url` |
| `timeout` | Delivered and opened, but no pick inside the window | Re-run the command, or ask if they still want it |
| `no_active_client` | No Cohub tab to show it in | Tell the user to open the Space in a browser |
| `ui_host_unavailable` | Their tab is not on a Space workspace | Ask them to open the Space workspace |
| `rejected` / `unsupported` | The call could not run | Read `error.message`; fall back to `cohub generate` |

Treat a non-`applied` status as "the user did not choose", never as a failure to retry blindly.

`timeout` and `unsupported` mean different things and should not be conflated. `timeout` means the studio opened fine and is still waiting on a human — the right response is patience or a nudge. `unsupported` means the call never reached a handler, which is a real fault worth falling back on.

## First Run In A Space

The studio spends the viewer's own credits, so on first use Cohub shows a one-time consent dialog for `generation.create`. Mention this before opening, so the prompt is expected:

> Opening Darkroom so you can pick the image. It will ask once for permission to generate on your account.

Returning users are re-authorized silently.

## Do Not

- **Do not open Darkroom without a seed prompt.** A blank composer makes the user do the work you were asked to do.
- **Do not open it when the user is not present.** It blocks on a human choice; without one it just times out.
- **Do not open several at once.** Showing a preview is idempotent per Work, so a second call re-activates the same tab and the earlier command is left hanging.
- **Do not re-run on `applied`.** The user already chose; a second run charges them again.
