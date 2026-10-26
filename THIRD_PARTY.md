# Third-party and adapted skills

Several skills here are adaptations of MIT-licensed work. Upstream attribution is kept next to the skill (`references/UPSTREAM.md`, `references/LICENSE.txt`); this file is the summary.

| Skill | Upstream | Version / commit | License | What changed |
|---|---|---|---|---|
| `leader` | [KKKKhazix/khazix-skills](https://github.com/KKKKhazix/khazix-skills) | `30c131ee3d804db7b31e4951c62018d5bde27e08` (2026-07-26) | MIT | Kept the core contract (measured preflight, write allowlists, frozen acceptance, resumable progress, stop conditions). Reworked for Space-scoped authority, side-effect gates and scoped hooks. |
| `grilling` | [mattpocock/skills](https://github.com/mattpocock/skills) | `v1.2.2`, `8b36d4fb2635b3c21998dcd8144439c9e5ba7302` | MIT | Kept the dependency-aware frontier and round-by-round questioning. Added a single-question mode, a five-question cap, a direct-research fallback, and durable session state. |
| `tempmail` | [dreamhunter2333/cloudflare_temp_email](https://github.com/dreamhunter2333/cloudflare_temp_email) | `d04c1a865dbfedd1a05feba10046193d3adf22da` | MIT | Wrote provider routing and compatibility rules around the upstream deployment; the deployment itself is not included. |

`okp-import` and `okp-search` are original instructions that drive the `@markbangwu/okp` CLI. The CLI is not bundled here.

Skills that are mostly other people's work are deliberately **not** included in this repository — install them from their own homes:

- [`markbang/wgetx-skill`](https://github.com/markbang/wgetx-skill) — social platform fetching
- [`markbang/wikis-skill`](https://github.com/markbang/wikis-skill) — Fandom/Miraheze/wiki.gg queries
- [`markbang/warp-proxy-skill`](https://github.com/markbang/warp-proxy-skill) — userspace WARP proxy
- [`kjx-talesofai/claude-skill-hypersampling`](https://github.com/kjx-talesofai/claude-skill-hypersampling) — multi-provider web search
