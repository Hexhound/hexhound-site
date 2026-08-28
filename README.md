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
npx wrangler@latest pages deploy . --project-name=hexhound-site --branch=main
popd
```

`--branch=main` targets the project's **production** branch. Without it the deploy lands on
a `*.preview` URL and the custom domain never updates.

## DNS

`hexhound.dev` is attached to the `hexhound-site` Pages project as a custom domain, with
`www.hexhound.dev` redirecting to the apex.

`caremate.hexhound.dev` (the Caremate share loader + privacy policy) and
`olhar-factual.hexhound.dev` are separate records on the same zone — leave them alone.

## Images

`site/images/hero.jpg` is [Pexels photo 8947184](https://www.pexels.com/photo/a-person-holding-a-cellphone-on-white-background-8947184/)
by kaboompics.com, resized to 1800px wide and recompressed to ~44 KB. The Pexels licence
allows commercial use with no attribution required.

If you replace it, recompress — don't drop a raw camera JPEG in — and re-check both hero
scrims. The desktop gradient is heaviest on the left where the copy sits; below 640px a
separate bottom-up gradient takes over, because the crop otherwise puts the subject behind
the headline.
