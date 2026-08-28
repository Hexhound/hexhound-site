# hexhound.dev — static company page

**Date:** 2026-08-28
**Status:** approved design, not yet implemented

## Why

`hexhound.dev` currently returns HTTP 521 — Cloudflare is proxying to a dead origin. The
old page was a Phoenix LiveView (`core_old/lib/core_web/live/home.ex`) that is no longer
deployed anywhere.

A live company site is needed to convert the Google Play Console account to an
organization account. Play organization accounts require a D-U-N-S number and, for
accounts created after February 2024, a website-verification step — Google checks that the
company controls a reachable site. Caremate cannot ship to Play until that account
conversion goes through.

The page's job is **verification and credibility**, not lead generation. Minimal, accurate,
low-maintenance.

## Constraints

- Static only. No build step, no framework, no runtime dependency. One HTML file with an
  inline `<style>` block, matching how `caremate.hexhound.dev` is built.
- Hosted on Cloudflare Pages, deployed with wrangler, same as the `caremate-share` project.
- Must not disturb the existing `caremate.hexhound.dev` or `olhar-factual.hexhound.dev`
  DNS records.
- The legal entity name must appear so it can be matched against the D&B record.
- The registered address must **not** appear — it is the founder's home address. Google
  verifies the organization against the D&B record rather than against the page, so the
  address is not required on the site.

## Content decisions

Carried over from the old page, changed, or dropped:

| Old page | New page |
|---|---|
| Hero: "Engineered for Velocity & Scale" | Hero: "Engineered for **Mobile.**" |
| Sub: "robust APIs and SaaS to scalable B2B & B2C platforms" | Sub: privacy-first mobile applications |
| Philosophy quote ("Code should be a catalyst…") | Kept, reworded for mobile |
| Solutions grid (4 cards) | **Dropped** — linked to Phoenix routes that no longer exist |
| Team: Eduardo, Felipe, Jeferson | Team: Eduardo, Jeferson — Felipe removed |
| Team blurb (sectors, USA/Brazil) | Kept verbatim |
| No legal footer | Legal entity + CNPJ + contact |

Positioning is **mobile-first product studio** — "we build privacy-first mobile
applications." Mobile leads because that is what the Play account is for.

## Page structure

Single page, five blocks:

1. **Nav** — Home · About anchors, plus a "Contact Us" button linking to
   `mailto:admin@hexhound.dev`.
2. **Hero** — full-height, `landing_page_hero.jpg` under a light `135deg` gradient with
   dark text. Headline "Engineered for **Mobile.**" (accent on the second line), subhead
   "We build privacy-first mobile applications. Designed, engineered, and published
   in-house." Anchor link down to the team.
3. **Philosophy** — centered pull-quote under "The HexHound Standard" eyebrow, reworded
   from the original toward mobile and privacy:

   > "Code should be a catalyst, not a constraint. We design mobile applications that keep
   > their data on the device and their promises to the person holding it."
4. **Team** — dark `#111827` section. Two members, each a circular photo, name, "Founder &
   Developer", GitHub and LinkedIn icon links. Blurb above, kept verbatim from the old
   page.
5. **Footer** — legal block:

   ```
   Hexhound is a trade name of
   EDUARDO BARRETO ALEXANDRE DESENVOLVIMENTO DE SOFTWARE LTDA
   CNPJ 59.731.750/0001-86 · admin@hexhound.dev
   © 2026 Hexhound
   ```

## Visual direction

A port of the old page's look, so it stays recognizable: tan `#C49A6C` accent, light
neutral body, dark team section, tight tracking on oversized headline type. The Tailwind
utility classes become hand-written CSS. Single mode — no dark-mode media query, matching
the original.

This deliberately does **not** adopt the Caremate design language (Newsreader / Hanken
Grotesk, cream and rust). Considered and rejected: Caremate's palette belongs to a health
app, and the parent company should not inherit its child's identity.

## Files

```
site/
  index.html             whole page, inline <style>
  _redirects             /favicon.ico → /favicon.svg (200 rewrite)
  favicon.svg
  images/
    hero.jpg
    logo.svg
    members/eduardo.jpg
    members/jeferson.jpeg
README.md                deploy + DNS runbook
docs/superpowers/specs/  this document
```

Assets are copied from `core_old/priv/static/images`. Two need work before they ship:

- `landing_page_hero.jpg` is **1.5 MB** — the entire page weight, and the first thing a
  reviewer loads. Recompress to roughly 200–300 KB.
- `members/jeferson.jpeg` is **232 KB** for a 128 px circle. Resize to render size.

`members/felipe.jpg` is not copied.

## Deployment

```bash
pushd site
npx wrangler@latest pages deploy . --project-name=hexhound-site --branch=main
popd
```

`--branch=main` targets the production branch; without it the deploy lands on a preview URL
and the custom domain does not update. This is the same failure mode documented in
`caremate/web_share/README.md`.

Wrangler is already authenticated on this machine (OAuth token at
`~/.config/.wrangler/config/default.toml`, from the Caremate deploys).

Then, in the Cloudflare dashboard:

1. Attach `hexhound.dev` to the `hexhound-site` Pages project as a custom domain. This
   replaces the record currently returning 521.
2. Add `www.hexhound.dev` redirecting to the apex.
3. Leave `caremate.hexhound.dev` and `olhar-factual.hexhound.dev` alone.

## Verification

- `hexhound.dev` returns 200 over HTTPS; `www.hexhound.dev` redirects to it.
- `caremate.hexhound.dev/privacy` still loads (DNS change didn't collateral-damage it).
- No 404s in the network log — favicon, hero, both member photos resolve.
- Every link resolves: two GitHub profiles, two LinkedIn profiles, the mailto.
- Legal name and CNPJ render exactly as written above.
- Page renders correctly at 375 px and 1440 px.

No automated tests — a single static page with no logic has nothing to unit-test.

## Out of scope

- Products / portfolio block. Dropped by decision; Caremate is not on Play yet.
- Contact form. `mailto:` only, so there is no third-party form service or spam surface.
- Analytics.
- Migrating Olhar Factual off GitHub Pages.

## Follow-up, not part of this work

Play organization accounts publish developer contact details on the store listing ("About
the developer"), sourced from the Payments profile / D&B record. If that address is the
founder's home address, it may become public on the Caremate listing regardless of what
this site shows. Google's documentation is ambiguous about exactly which fields publish.
Verify in Play Console before the first release; the fix would be changing the CNPJ's
registered address, not anything on this page.
