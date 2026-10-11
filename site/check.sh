#!/bin/sh
# Checks the site built by site/build.sh. Run from the repository root: sh site/check.sh
set -eu

SITE='https://harden-ci.secmy.app/'

fail() { echo "check failed: $1" >&2; exit 1; }

# The HTML page links to the repository and keeps template braces from README.md
grep -qF 'href="https://github.com/SecH0us3/harden-ci"' _site/index.html || fail 'no repository link on the page'
grep -qF '{{.Digest}}' _site/index.html || fail 'braces {{.Digest}} lost'
grep -qF '${{ github.event.* }}' _site/index.html || fail 'braces ${{ github.event.* }} lost'

# The Markdown copies are identical to their sources
cmp -s README.md _site/README.md || fail 'README.md copy differs'
cmp -s README.md _site/index.md || fail 'index.md differs from README.md'
cmp -s README.md _site/llms-full.txt || fail 'llms-full.txt differs from README.md'
cmp -s AGENTS.md _site/AGENTS.md || fail 'AGENTS.md copy differs'

# llms-full.txt starts with an H1 and has H2 sections
head -n 1 _site/llms-full.txt | grep -q '^# ' || fail 'llms-full.txt does not start with an H1'
grep -q '^## ' _site/llms-full.txt || fail 'llms-full.txt has no H2 sections'

# llms.txt: exactly one H1, a blockquote, a link list
[ "$(grep -c '^# ' _site/llms.txt)" = 1 ] || fail 'llms.txt must have exactly one H1'
grep -q '^> ' _site/llms.txt || fail 'llms.txt has no blockquote'
grep -q '^- \[' _site/llms.txt || fail 'llms.txt has no link list'

# Every link in llms.txt and sitemap.xml that points to this site exists in the build
for url in $(grep -ho "${SITE}[^)<\"]*" _site/llms.txt _site/sitemap.xml | sort -u); do
  path="${url#"$SITE"}"
  [ -n "$path" ] || path='index.html'
  [ -f "_site/$path" ] || fail "linked file is not in the build: $url"
done

# robots.txt: every group has a rule, and the sitemap line is absolute
grep -q "^Sitemap: ${SITE}sitemap.xml$" _site/robots.txt || fail 'robots.txt has no Sitemap line'
[ "$(grep -c '^User-agent: ' _site/robots.txt)" = "$(grep -c '^Allow: \|^Disallow: ' _site/robots.txt)" ] || fail 'robots.txt: a group has no rule'

# ai.txt agrees with robots.txt: neither file forbids anything
cmp -s site/ai.txt _site/ai.txt || fail 'ai.txt copy differs'
if grep -q '^Disallow:' _site/robots.txt _site/ai.txt; then fail 'robots.txt and ai.txt must not forbid anything: the policy is allow all'; fi

echo 'all checks passed'
