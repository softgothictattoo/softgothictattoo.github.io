# Soft Gothic Tattoo — portfolio site

Static site for Luke (Soft Gothic Tattoo), an illustrative blackwork tattoo
artist working from Studio Trinket, 34 St Nicholas Street, Bristol BS1 1TG.

- Live at <https://softgothictattoo.co.uk> (GitHub Pages, served from `main`)
- Booking goes through Venue.ink; Instagram is `@softgothictattoo`

## How the site is built

There is **no build step and no framework**. Hand-written HTML, one stylesheet,
self-hosted fonts. Editing a file and pushing to `main` is the whole deploy.
Do not introduce a bundler, a static site generator, npm, or a CSS framework
without asking first.

```
index.html            404.html            robots.txt   sitemap.xml
about/index.html      booking/index.html
studio/index.html     tattoos/index.html
css/style.css         fonts/*.woff2
img/                  site chrome only (logo, favicons, textures, og image)
img/tattoos/          every tattoo photo
```

Each page is standalone: the header, nav and footer are copied into all six
HTML files. **A change to nav or footer must be made in all of them.** Pages in
subfolders link with `../` (e.g. `../css/style.css`); only the favicon links in
`index.html` use root-absolute `/img/...`.

## Conventions

- **British English** throughout, and `lang="en-GB"`. "Colour", "jewellery",
  "realise". Prices in £.
- **Tone**: plain, warm, unfussy, lowercase branding ("soft gothic tattoo").
  Not spooky-cliché, not salesy. "Everyone is welcome here" is the footer line
  and the spirit of the whole site.
- **CSS**: all design tokens are custom properties on `:root` in
  `css/style.css` — `--ink`, `--parchment`, `--oxblood`, `--bone`, plus
  `--display` / `--body` for the two typefaces. Use the tokens, don't hardcode
  hex values. Display face is Grenze Gotisch, body is EB Garamond.
- **Fonts** are self-hosted in `fonts/` and preloaded per page. No Google Fonts
  CDN — the licences (OFL) are committed alongside them.
- **Images**: lowercase filenames, hyphens not spaces, `.jpg` (not `.JPEG`).
  Tattoo photos go in `img/tattoos/`; nothing else does. Always give `<img>` a
  `width`, `height`, descriptive `alt`, and `loading="lazy"` below the fold.
- **SEO**: every page carries a canonical URL, OG tags and JSON-LD. When you
  add a page, add it to `sitemap.xml` too and bump `lastmod`.

## Current state / known work

- The gallery at `tattoos/index.html` is still wired to
  `img/tattoos/placeholder-*.jpg` and `*.webp` stubs with "Replace with
  description" alt text. The ~60 real photos in `img/tattoos/` are not yet
  used anywhere. Wiring them up, with real captions and alt text, is the
  next obvious job.
- Several photos are very large (`satan.png` is 15 MB, `knuck.png` 7.6 MB).
  They need resizing and converting to JPEG/WebP before they go on a page —
  as-is they would make the gallery unusable on mobile data.
- The "Healed" section of the portfolio page is a heading with no photos yet.
- `img/tattoos/skull1.jpg` and `img/tattoos/starfishies.jpg` are **not images**
  — each is 2 bytes containing a bare CRLF, left behind by a failed upload via
  the GitHub web UI. Re-upload the real photos or delete the files; do not put
  them on a page.

## Working agreement

Ask before: changing the colour palette or typefaces, restructuring the nav,
altering prices, studio address or booking links, or touching anything that
makes a claim about Luke's practice. Those are the artist's call, not a
styling decision.
