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

  Upload photos at whatever size the phone produced. Once they reach `main`,
  `.github/workflows/optimise-images.yml` resizes them to 1600px on the long
  edge, converts to sRGB, strips metadata and re-saves photographic PNGs as
  JPEG, then commits the result. Run `.github/scripts/optimise-images.sh`
  locally for the same thing, or `--check` to see what it would do. It only
  touches `img/tattoos/`, never site chrome, and running it twice changes
  nothing the second time.

  The script also fails if a file in `img/tattoos/` is not a valid image.
  Uploading through the GitHub web UI has silently produced 2-byte files
  before, recording the filename but not the contents; this is the guard
  against that going unnoticed.
- **SEO**: every page carries a canonical URL, OG tags and JSON-LD. When you
  add a page, add it to `sitemap.xml` too and bump `lastmod`.

## Current state / known work

- The gallery at `tattoos/index.html` is still wired to
  `img/tattoos/placeholder-*.jpg` and `*.webp` stubs with "Replace with
  description" alt text. The ~60 real photos in `img/tattoos/` are not yet
  used anywhere. Wiring them up, with real captions and alt text, is the
  next obvious job.
- Photos in `img/tattoos/` are optimised automatically once they land on
  `main` — see "Images" above. Nothing needs doing by hand.
- The "Healed" section of the portfolio page is a heading with no photos yet.

## Working agreement

Ask before: changing the colour palette or typefaces, restructuring the nav,
altering prices, studio address or booking links, or touching anything that
makes a claim about Luke's practice. Those are the artist's call, not a
styling decision.
