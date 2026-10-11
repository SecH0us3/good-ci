#!/bin/sh
# Builds the site into _site/. Run from the repository root: sh site/build.sh
# Needs Docker with a running daemon.
set -eu

PANDOC_IMAGE='pandoc/core:3.11.0@sha256:62518bfb6833705dc90a1634d8d879299bd820b3f74ad3b32fba8b618452553a'

mkdir -p _site

# The HTML page for people
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$PWD:/data:ro" \
  -v "$PWD/_site:/out" \
  "$PANDOC_IMAGE" \
  --from gfm --to html5 --standalone \
  --toc --toc-depth=2 \
  --lua-filter site/toc.lua \
  --metadata pagetitle="harden-ci - secure CI/CD instructions for AI agents" \
  --metadata lang=en \
  --css style.css \
  --include-after-body site/footer.html \
  --output /out/index.html \
  README.md
cp site/style.css _site/style.css

# The same text as plain Markdown, for agents. All copies come from README.md
cp README.md _site/README.md
cp README.md _site/index.md
cp README.md _site/llms-full.txt

# Files published as they are
cp AGENTS.md _site/AGENTS.md
cp site/llms.txt _site/llms.txt
cp site/robots.txt _site/robots.txt
cp site/ai.txt _site/ai.txt
cp site/sitemap.xml _site/sitemap.xml
