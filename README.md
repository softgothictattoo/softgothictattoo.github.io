# Soft Gothic Tattoo — site

Plain HTML/CSS, no build step, hosted on GitHub Pages.

## Structure
- `index.html`, `tattoos/`, `about/`, `booking/`, `studio/` — one folder per page, clean URLs
- `css/style.css` — the only stylesheet; brand tokens are the `:root` variables at the top
- `fonts/` — self-hosted Grenze Gotisch (headings) and EB Garamond (body), Latin subset, OFL licence
- `img/` — brand assets; `img/tattoos/` — portfolio photos
- `sitemap.xml`, `robots.txt`, `404.html`, `.nojekyll`

## Before going live
1. Search-and-replace `https://softgothictattoo.co.uk` with the real domain (5 HTML files + sitemap + robots).
2. Fill the `[bracketed]` placeholders and `<!-- comments -->` on Booking and Studio pages.
3. Replace `img/tattoos/placeholder-*.jpg` with real photos: 4:5 portrait, ~900×1125, under 150 KB, named descriptively (`blackwork-moth-forearm.jpg`), alt text that says what the tattoo is and where it sits.
4. Swap the About page image for a photo of Luke at the studio.

## Deploy
Repo → Settings → Pages → Deploy from branch `main`, root. Then Settings → Pages → Custom domain, and add a `CNAME` file containing just the domain. Tick "Enforce HTTPS" once the certificate appears.

## After deploy
- Google Search Console: add property, submit `sitemap.xml`
- Bing Webmaster Tools: same
- Test structured data at https://validator.schema.org
