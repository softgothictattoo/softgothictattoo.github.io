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
  Not spooky-cliché, not salesy. "Everyone is welcome here" was removed from
  the footer at Luke's request; it still opens the home page and heads a
  section on `about/`, and remains the spirit of the site.
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
  `.github/workflows/optimise-images.yml` resizes them to 1200px on the long
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
- Two files in `img/tattoos/` are deliberately not on any page:
  - `me.jpg` is a portrait of Luke, not a tattoo. It belongs on `about/`
    if anywhere.
  - `bread.jpg` is a group photo in which four people's faces are clearly
    identifiable. Not published pending their say-so.
  (`pin.jpg` was a third: the same photograph as `bicep_heart.webp`, which
  is the copy the site uses. It was deleted along with its variants.)
- Photos in `img/tattoos/` are optimised automatically once they land on
  `main` — see "Images" above. Nothing needs doing by hand.
- Every photo in `img/tattoos/` also has `-400` and `-800` companions,
  built by the same script, and the gallery and home page offer all three
  through `srcset`. `sizes` declares the tile's real width - 380px above
  52rem, 45vw below - so every screen takes the smallest file that can
  fill the tile: 400w at 1x, 800w at 2x. A `.grid` tile is 371px wide on
  any desktop, because `.wrap` caps at 72rem and the grid is three
  columns, so it cannot show more than that however large the monitor.
  It used to declare 1200px so desktops took the master, on the grounds
  that the gallery is a showcase. Click-to-enlarge replaced that reason:
  the full-size master is now fetched when someone actually asks for it,
  so the tiles no longer carry it. All 54 loaded: 1.27 MB on a 1x desktop
  or 2x phone, 4.22 MB at 2x, against 6.3 MB when the tiles took masters.
  Do not put the 1200px back without also removing the lightbox.
  The `w` descriptors are each file's real width, read per image, not
  assumed, and the variants are resized by width rather than fitted into
  a box. A portrait photo fitted into a 400x400 box is only 300px wide,
  and a `400w` label on it makes the browser pick it for slots it cannot
  fill. If you add an `<img>` from `img/tattoos/` to a page, give it the
  same `srcset` and `sizes`.
  **`width`, `height` and every `srcset` `w` descriptor must match the real
  file.** They are not decorative. Changing a master's dimensions without
  rewriting them makes the browser pick variants for slots they cannot
  fill. Re-derive them from the files after any resize, and check every
  `<img>` on `gallery/` and `index.html`, not just the ones you touched.

  The masters are capped at **1200px** on the long edge and JPEG quality
  74, down from 1600px at quality 82. Luke asked for this: partly to save
  space, partly so people cannot pixel-peep the work. It took the desktop
  gallery from 13.2 MB to 6.3 MB, a 3x phone to 4.2 MB and a 2x phone to
  1.3 MB. Most masters are now 900x1200.
  How that was done matters more than the numbers. The files were **not
  recompressed**. Each was re-encoded in a single pass from its camera
  original, recovered from git history, which is where the originals still
  are. Measured as PSNR against the uncompressed original, a single encode
  at 74 costs about 1 dB against 82, where squeezing an existing 82 file
  down to the same size costs about 4.5 dB and shows as muddy stippling on
  dotwork. **If the masters ever need shrinking again, go back to the
  originals rather than recompressing what is in the tree.**
  The six `.webp` masters have no original behind them - they arrived as
  WebP - so those were resized from themselves. Downscaling averages
  artefacts away faster than re-encoding adds them, which is why that is
  acceptable for a resize but not for a quality drop in place.
  The `-400` and `-800` variants are quality 74 as well. A variant is a
  second generation, encoded from the master, but that costs almost
  nothing at these sizes: building a 400px variant from the camera
  original instead gains only 0.15 dB, because downscaling to a third of
  the width averages the master's artefacts away before they are
  re-encoded. So reruns stay reproducible from the master alone.
  The lightbox never upscales, because `max-width`/`max-height` only ever
  shrink an image: on a large screen an enlarged photo renders at exactly
  its natural 900x1200 and stays crisp, rather than being stretched soft.
- Every page's background is `img/bg-pattern.jpg`, Luke's bird-and-leaf
  tile, set on `html` over the `--parchment` colour. The tile is seamless
  and its light areas are exactly `#e5e4c6`, so the colour underneath
  matches and nothing shifts if the image fails to load.
  Drawn at 55rem, from an 1800px tile so it stays sharp on a 2x screen.
  The awkward range is the middle: around 28-35rem the motifs are too
  big to read as texture and too small to read as birds, so they look
  like blobs. Below and above that it reads as a pattern.
- The hero artwork is `img/eye-flash-light.png`: the eye design in white
  ink on transparency, so it sits straight on the dark hero with no
  mount. Luke supplied the same design in three inks, cream, white and
  black; white is the one on the site, black (`img/eye-flash-dark.png`) is
  still unused. `.hero-art img` therefore sets `background: none; border: 0`.
  It is a 64-colour palette PNG, which for two-tone artwork is a tenth
  the size of truecolour with no visible loss, 12.4 MB down to 94 KB.
  The black version, `img/eye-flash-dark.png`, and the two superseded
  exports `img/eye-flash.jpg` and `img/texture.jpg` were deleted once
  nothing referenced them. They are all in git history:
  `git show 846de0e:img/eye-flash-dark.png > img/eye-flash-dark.png`
  brings the black ink back if the design is ever wanted on a light
  background. Note that one is Luke's artwork in a third ink rather than
  a superseded export, so restore it rather than redrawing it.
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
- The gallery has click-to-enlarge. Each photo is wrapped in a plain
  `<a class="zoom">` pointing at its full-size file, so it still opens the
  photograph with JavaScript off; an inline script at the foot of
  `gallery/index.html` intercepts the click and shows the file in a native
  `<dialog>` instead, which brings the focus trap, the backdrop and
  Escape-to-close with it. Arrow keys and the two arrow buttons step
  through all 54. Modified clicks (ctrl, cmd, shift) are left alone so
  "open in new tab" still works. If you add a photo to the grid, wrap it
  the same way or it will not open.
  Because the tiles only load a 400w or 800w file, the master is
  prefetched on hover, touchstart and focus, so the click does not wait on
  a download the tile used to have cached. Each master is fetched at most
  once, and nothing is prefetched until someone shows intent.
- External links (Venue.ink, Instagram, the map) open in a new tab and
  carry `rel="noopener"`. Internal links do not. Keep that split.
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
