#!/usr/bin/env bash
#
# Prepare tattoo photos for the web.
#
# Photos arrive straight off a phone: 20 MB, 4000px wide, tagged Display P3.
# This resizes them, converts them to sRGB, strips metadata, and turns
# photographic PNGs into JPEGs. It also fails loudly on files that are not
# images at all, which is how a botched GitHub web upload shows up.
#
# Safe to run repeatedly: a file that already meets every condition below is
# left untouched, so a second run produces no changes and no commit.
#
# Usage: .github/scripts/optimise-images.sh [--check]
#   --check  report what would change, modify nothing (exit 1 if work is due)

set -euo pipefail

DIR=${DIR:-img/tattoos}
MAX_EDGE=${MAX_EDGE:-1600}
QUALITY=${QUALITY:-82}
SRGB=${SRGB:-/usr/share/color/icc/sRGB.icc}

check_only=0
[[ ${1:-} == --check ]] && check_only=1

command -v convert  >/dev/null || { echo "::error::ImageMagick not installed"; exit 1; }
[[ -f $SRGB ]] || { echo "::error::sRGB profile missing at $SRGB (apt install icc-profiles-free)"; exit 1; }
[[ -d $DIR ]]  || { echo "Nothing to do: $DIR does not exist"; exit 0; }

broken=() ; changed=0 ; skipped=0 ; bytes_before=0 ; bytes_after=0

# Point every reference at a file's new name after a format change.
repoint() {
  local from=$1 to=$2
  # grep exits 1 when nothing references the file, which is the normal case
  # while the gallery is still on placeholders - not an error.
  local pages
  pages=$(grep -rlF "$from" --include='*.html' --include='*.css' --include='*.xml' . 2>/dev/null || true)
  [[ -z $pages ]] && return 0
  while read -r page; do
    [[ -n $page ]] || continue
    sed -i "s|$from|$to|g" "$page"
    echo "      referenced in $page - updated"
  done <<< "$pages"
}

while IFS= read -r -d '' f; do
  # A failed upload leaves a tiny text file wearing an image extension.
  if [[ $(file -b --mime-type "$f") != image/* ]]; then
    broken+=("$f")
    continue
  fi

  read -r w h opaque profiles < <(
    identify -format '%w %h %[opaque] [%[profiles]]\n' "$f" 2>/dev/null || echo "0 0 false []"
  )
  ext=${f##*.}
  long=$(( w > h ? w : h ))

  # Three independent reasons to touch a file. Each is cleared by processing,
  # which is what makes the script idempotent.
  oversized=0 ; tagged=0 ; heavy_png=0
  (( long > MAX_EDGE ))                            && oversized=1
  [[ $profiles != "[]" ]]                          && tagged=1
  [[ ${ext,,} == png && $opaque == true ]]         && heavy_png=1

  if (( ! oversized && ! tagged && ! heavy_png )); then
    skipped=$(( skipped + 1 ))
    continue
  fi

  # An opaque PNG is a photograph saved in the wrong format. Transparent PNGs
  # are artwork (logos, textures) and keep their format.
  target=$f
  if (( heavy_png )); then
    target="${f%.*}.jpg"
    if [[ -e $target ]]; then
      echo "::warning::$f would become $target, which already exists - left as PNG"
      target=$f
    fi
  fi

  size_before=$(stat -c%s "$f")
  reasons=""
  (( oversized ))        && reasons+="${w}x${h} "
  (( tagged ))           && reasons+="metadata "
  [[ $target != "$f" ]]  && reasons+="png->jpg "

  if (( check_only )); then
    echo "  would optimise $f  (${reasons% })"
    changed=$(( changed + 1 ))
    continue
  fi

  tmp=$(mktemp --suffix=".${target##*.}")
  # -auto-orient before -strip, or EXIF-rotated phone photos come out sideways.
  # -profile converts P3/Adobe RGB to sRGB properly; -strip alone would shift colour.
  convert "$f" \
    -auto-orient \
    -profile "$SRGB" \
    -resize "${MAX_EDGE}x${MAX_EDGE}>" \
    -interlace Plane \
    -sampling-factor 4:2:0 \
    -quality "$QUALITY" \
    -strip \
    "$tmp"

  size_after=$(stat -c%s "$tmp")
  mv "$tmp" "$target"
  chmod 644 "$target"   # mktemp makes 0600; keep checked-in files readable
  if [[ $target != "$f" ]]; then
    rm -f "$f"
    repoint "$f" "$target"
  fi

  bytes_before=$(( bytes_before + size_before ))
  bytes_after=$(( bytes_after + size_after ))
  changed=$(( changed + 1 ))
  printf '  %s -> %s  %s KB -> %s KB  (%s)\n' \
    "$f" "$target" "$(( size_before / 1024 ))" "$(( size_after / 1024 ))" "${reasons% }"
done < <(find "$DIR" -type f ! -name "*-400.*" ! -name "*-800.*" -print0 | sort -z)

# Companions for srcset. A 2x phone can only use about 340px, so the full file
# is wasted there; a desktop wants the full file because the gallery is a
# showcase. 800 covers 3x phones and tablets in between.
VARIANT_WIDTHS=${VARIANT_WIDTHS:-"400 800"}
variants=0
while IFS= read -r -d '' f; do
  [[ $(file -b --mime-type "$f") == image/* ]] || continue
  for vw in $VARIANT_WIDTHS; do
    small="${f%.*}-${vw}.${f##*.}"
    # Never upscale: a master narrower than the variant would gain nothing.
    src_w=$(identify -format '%w' "$f" 2>/dev/null || echo 0)
    (( src_w > vw )) || continue
    # Only rebuild when missing or older than its source, so reruns are cheap.
    if [[ ! -f $small || $f -nt $small ]]; then
      # Resize by WIDTH, not into a box: srcset "w" descriptors are widths, and
      # a portrait photo fitted into a box is narrower than its label claims,
      # which makes the browser pick it for slots it cannot fill.
      convert "$f" -resize "${vw}x>" -profile "$SRGB" -interlace Plane \
              -sampling-factor 4:2:0 -quality 82 -strip "$small"
      chmod 644 "$small"
      variants=$(( variants + 1 ))
    fi
  done
done < <(find "$DIR" -type f ! -name "*-400.*" ! -name "*-800.*" -print0 | sort -z)
(( variants )) && echo "Built $variants small variant(s) for srcset."

if (( ${#broken[@]} )); then
  echo
  echo "::error::${#broken[@]} file(s) in $DIR are not images. A GitHub web upload"
  echo "::error::most likely recorded the filename but not the contents. Re-upload them."
  for b in "${broken[@]}"; do echo "  not an image: $b ($(stat -c%s "$b") bytes)"; done
  exit 1
fi

echo
if (( check_only )); then
  (( changed )) && { echo "$changed file(s) need optimising."; exit 1; }
  echo "All $skipped image(s) already optimised."
  exit 0
fi
echo "Optimised $changed file(s), left $skipped already-optimised file(s) alone."
(( changed )) && printf 'Saved %s MB (%s MB -> %s MB).\n' \
  "$(( (bytes_before - bytes_after) / 1048576 ))" \
  "$(( bytes_before / 1048576 ))" "$(( bytes_after / 1048576 ))"
exit 0
