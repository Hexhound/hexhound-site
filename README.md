# hexhound.dev

The Hexhound company page. One static HTML file, no build step, no framework.

```
site/                 the deployable directory (Cloudflare Pages project hexhound-site)
  index.html          the whole page, styles inline
  _redirects          /favicon.ico rewrite
  app-ads.txt         the AdMob publisher line: ad networks look for it at the root of
                      the developer website the Play listing names, which is this one
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
wrangler pages deploy . --project-name=hexhound-site --branch=master
popd
```

`--branch=master` targets the project's **production** branch (`master` here, unlike
caremate-share's `main`). Any other branch, or none, lands on a preview URL
(`<branch>.hexhound-site.pages.dev`) and the custom domain never updates.

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

The hero is the page's entire weight. `site/images/hero.jpg` is a recompressed 1800px-wide
version of the original 3704×5556 / 1.5 MB source in the old Phoenix app. If you replace
it, recompress — don't drop a raw camera JPEG in.
