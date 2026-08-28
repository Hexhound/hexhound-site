# hexhound.dev

The Hexhound company page. One static HTML file, no build step, no framework.

```
site/                 the deployable directory (Cloudflare Pages project hexhound-site)
  index.html          the whole page, styles inline
  _redirects          /favicon.ico rewrite
  images/             hero, logo, member photos
docs/superpowers/specs/   design document
```

Its main job is company verification: Google Play organization accounts need a reachable
site the company demonstrably controls, and the footer carries the legal entity name and
CNPJ that must match the D&B record.

## Dev shell

`direnv allow` (or `nix develop --accept-flake-config --no-pure-eval`) gets you node/npx,
a pinned `wrangler`, and `imagemagick` for reprocessing the photos. Same devenv layout as
the other Hexhound repos, minus the Elixir/Rust modules this site has no use for.

## Editing

Open `site/index.html`. Everything is in that one file — the colour tokens live in the
`body { --accent: … }` block at the top of the `<style>`.

Preview locally:

```bash
cd site && python3 -m http.server 8080   # then open http://127.0.0.1:8080
```

Root-relative paths (`/images/…`) resolve correctly this way; opening `index.html`
directly with `file://` does not load the images.

## Deploying

```bash
pushd site
wrangler pages deploy . --project-name=hexhound-site --branch=main
popd
```

`--branch=main` targets the project's **production** branch. Without it the deploy lands on
a `*.preview` URL and the custom domain never updates.

Authentication is either `wrangler login` (interactive, browser) or a
`CLOUDFLARE_API_TOKEN` in `.env` — `.envrc` loads it via `dotenv`, and `.env` is gitignored.
The token needs **Account → Cloudflare Pages → Edit**. Non-interactive shells (CI, agents)
can only use the token; wrangler refuses the OAuth flow without a TTY.

## DNS

`hexhound.dev` is attached to the `hexhound-site` Pages project as a custom domain, with
`www.hexhound.dev` redirecting to the apex.

`caremate.hexhound.dev` (the Caremate share loader + privacy policy) and
`olhar-factual.hexhound.dev` are separate records on the same zone — leave them alone.

## Images

`site/images/hero.jpg` is [Pexels photo 8947184](https://www.pexels.com/photo/a-person-holding-a-cellphone-on-white-background-8947184/)
by kaboompics.com (Pexels licence: commercial use, no attribution required), resized to
1800px wide, with a Caremate journey screen composited into the phone's blank glass.

The screen came from `caremate/mockup-journey.png` — a **design mockup**, not a capture of
the shipping app. To redo it after the UI changes, crop the screen out of a new source and
perspective-warp it onto the glass:

```bash
QUAD="0,0 1181,295  400,0 1469,291  400,866 1471,905  0,866 1183,909"
magick screen.png \( +clone -alpha transparent -background none -fill white \
  -draw "roundrectangle 0,0 399,865 30,30" \) -compose DstIn -composite round.png
magick round.png -blur 0x0.5 -modulate 99,94,100 -alpha set -virtual-pixel transparent \
  -define distort:viewport=1800x1200+0+0 -distort Perspective "$QUAD" warp.png
magick photo.jpg warp.png -compose over -composite -quality 82 site/images/hero.jpg
```

The quad is the screen's four corners in the 1800×1200 photo, clockwise from top-left; the
blur and `-modulate` keep the crisp screenshot from looking pasted onto a soft photograph.

If you replace it, recompress — don't drop a raw camera JPEG in — and re-check both hero
scrims. The desktop gradient is heaviest on the left where the copy sits; below 640px a
separate bottom-up gradient takes over, because the crop otherwise puts the subject behind
the headline.
