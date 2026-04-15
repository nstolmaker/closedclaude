---
name: openai-image-gen
description: Batch-generate images via OpenAI Images API. Random prompt sampler + `index.html` gallery.
---

# OpenAI Image Gen

Generate a handful of "random but structured" prompts and render them via the OpenAI Images API.

## Setup

- Needs env: `OPENAI_API_KEY`

## Run

From any directory (outputs to `~/Projects/tmp/...` when that directory exists, else `./tmp/...`):

```bash
python3 {baseDir}/scripts/gen.py
```

The script prints `out_dir=...` and `index_file=...` when it finishes.

To open the gallery after a run:

```bash
xdg-open <printed-index-file>   # Linux
open <printed-index-file>       # macOS
```

Useful flags:

```bash
python3 {baseDir}/scripts/gen.py --count 16 --model gpt-image-1.5
python3 {baseDir}/scripts/gen.py --prompt "ultra-detailed studio photo of a lobster astronaut" --count 4
python3 {baseDir}/scripts/gen.py --size 1536x1024 --quality high --out-dir ./out/images
```

## Output

- `*.png` images
- `prompts.json` (prompt ↔ file mapping)
- `index.html` (thumbnail gallery)
