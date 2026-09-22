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
studio/index.html     gallery/index.html
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

- `gallery/index.html` is one flat gallery of 54 photos, with no
  Custom/Flash/Healed split and no captions. Luke chose the first six
  (swordneck, skull2, panther, dag, angel, horses1); the rest follow in
  descending file size. The alt text was written from the photographs and
  should be corrected wherever it misreads a piece.
- `img/dagger-flipped.png` is a mirrored copy of `img/dagger.png`, used
  for the divider above "Recent work" so the two rules on the home
  page point opposite ways. It is a real flipped file rather than a CSS
  `scaleX(-1)` so the divider cannot render the wrong way round against a
  stale cached stylesheet. If the dagger artwork is ever redrawn, redo
  the mirror with `convert img/dagger.png -flop img/dagger-flipped.png`.
- `.grid` photos zoom slightly on hover, on both the home page and the
  portfolio. The effect is off under `prefers-reduced-motion` and on
  touch screens, and `overflow: hidden` on the figure keeps it inside
  its tile. Keep those guards if you change it.
- Three files in `img/tattoos/` are deliberately not on any page:
  - `me.jpg` is a portrait of Luke, not a tattoo. It belongs on `about/`
    if anywhere.
  - `bread.jpg` is a group photo in which four people's faces are clearly
    identifiable. Not published pending their say-so.
  - `pin.jpg` is the same photograph as `bicep_heart.webp`, which is the
    copy the site uses.
- Photos in `img/tattoos/` are optimised automatically once they land on
  `main` — see "Images" above. Nothing needs doing by hand.
- Every page's background is `img/bg-pattern.jpg`, Luke's bird-and-leaf
  tile, set on `html` over the `--parchment` colour. The tile is seamless
  and its light areas are exactly `#e5e4c6`, so the colour underneath
  matches and nothing shifts if the image fails to load.
  Drawn at 26rem. It is a kaleidoscope rather than a true repeating
  wallpaper, so past roughly 30rem its mirror axes read as irregular
  blobs rather than a pattern. 30rem was the first setting tried and was
  rejected for exactly that; 26 is about the ceiling.
- The hero artwork is `img/eye-flash-light.png`: the eye design in cream
  ink on transparency, so it sits straight on the dark hero with no
  mount. `.hero-art img` therefore sets `background: none; border: 0`.
  It is a 64-colour palette PNG, which for two-tone artwork is a tenth
  the size of truecolour with no visible loss, 12.4 MB down to 94 KB.
  `img/eye-flash.jpg`, the black-on-white version it replaced, is now
  unused, as is `img/texture.jpg`.
- The home page hero sits on `img/hero-collage.jpg`, 24 pieces from
  `img/tattoos/` in a 12x2 grid, desaturated and darkened. It replaced
  `img/texture.jpg`, which is now unused. White text sits on it, so the
  darkening in the file and the `.hero::before` gradient work together:
  keep both. That gradient is horizontal, dark on the left, because on a
  wide screen the text is in the left column. On a phone the text spans
  the full width and reaches the light end, which is why that stop is
  `.4` and not lower; at `.25` the heading measured 4.2:1 there, under
  AA. Re-check contrast at 390px as well as desktop if you rebuild the
  collage or touch the gradient.
- `img/luke.jpg` is the portrait on `about/`. It is a flat JPEG, not a
  transparent PNG: the source was a circle inscribed in a square, so
  `.portrait img` does the crop with `border-radius: 50%`. The source was
  also shaved slightly before flattening, so the circle's soft edge falls
  outside the CSS circle; without that a pale fringe rings the portrait.
- The portfolio lives at `/gallery/`. It was at `/tattoos/`, and
  `tattoos/index.html` is now a small stub that redirects there: a meta
  refresh plus a canonical, since GitHub Pages cannot serve a 301. It is
  marked noindex and is deliberately absent from `sitemap.xml`. Do not
  delete it; old links and shared posts still point at the old address.
  Note `img/tattoos/` is the photo directory and is unrelated to the page
  path — it did not move.

## Working agreement

Ask before: changing the colour palette or typefaces, restructuring the nav,
altering prices, studio address or booking links, or touching anything that
makes a claim about Luke's practice. Those are the artist's call, not a
styling decision.
