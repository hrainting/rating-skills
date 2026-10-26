# Agent Skills

Skills I use every day when working with a coding agent — writing goals, pressure-testing plans, shipping reports, producing video, and keeping knowledge retrievable.

Each skill is a folder with a `SKILL.md`: YAML frontmatter (name + description) followed by instructions the agent loads on demand. Nothing here runs on its own; there is no build step and no dependencies beyond what each skill lists.

## Skills

| Skill | What it does |
|---|---|
| [`leader`](skills/leader) | Turns an underspecified, multi-step request into an executable goal contract: baseline, write boundaries, anti-cheating checks, resumable state, stop conditions. |
| [`grilling`](skills/grilling) | Stress-tests a plan or decision through a dependency-aware interview, so assumptions surface before the work starts. |
| [`report-delivery`](skills/report-delivery) | The last mile for a report or page: pre-ship self-check, one repair loop, a real public URL, and a delivery receipt. |
| [`v2v-replace`](skills/v2v-replace) | Video character replacement: keeps the original choreography, beat, blocking and camera, replaces only the people. |
| [`darkroom`](skills/darkroom) | Human-in-the-loop image generation: the user steers and picks a frame instead of the agent guessing. |
| [`tempmail`](skills/tempmail) | Disposable-mailbox routing for authorized sign-up QA, with provider choice decided per target. |
| [`okp-import`](skills/okp-import) | Distils domain knowledge into an Open Knowledge Protocol domain: dedupe, distil, validate, write. |
| [`okp-search`](skills/okp-search) | Searches and navigates an OKP domain: read the README, filter by schema, read few, follow links. |

## Installing

Copy (or symlink) a skill folder into your agent's skills directory:

```bash
cp -r skills/leader ~/.claude/skills/leader
```

`okp-import` and `okp-search` expect the `okp` CLI on `PATH` (`npm install -g @markbangwu/okp`). `v2v-replace` expects `ffmpeg` and a video model provider. Everything else is instructions only.

## A caveat

These were written for one specific working environment — a Cohub Space with a `cohub` CLI, mounted mods under `/mods`, and Space-scoped file paths. The reasoning and the checklists travel; some path conventions and product names do not. Read a skill before wiring it into your own setup and adjust the paths.

## License

MIT — see [LICENSE](LICENSE). Skills adapted from other projects keep their upstream MIT terms and are listed in [THIRD_PARTY.md](THIRD_PARTY.md).
