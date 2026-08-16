#!/bin/sh
# New Haven — one-time map migrator (Mac / Linux)
# Copies your explored New Haven map (Xaero world-map + minimap waypoints) from
# your OLD instance into the new auto-updating pack instance.
# Safe to run anytime — even after you've already joined on the new instance. It
# MERGES the old map in and never overwrites tiles you already have. Run it again
# whenever; it only ever adds what's missing.

SERVER="Multiplayer_mc.mzalea.com"

# 1. locate the Prism/MultiMC instances folder
INSTDIR=""
for d in \
  "$HOME/.local/share/PrismLauncher/instances" \
  "$HOME/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances" \
  "$HOME/Library/Application Support/PrismLauncher/instances" \
  "$HOME/.local/share/multimc/instances" \
  "$HOME/.local/share/PolyMC/instances"; do
  [ -d "$d" ] && INSTDIR="$d" && break
done
if [ -z "$INSTDIR" ]; then
  echo "Couldn't find your Prism instances folder (is Prism in the default location?)."
  exit 1
fi

# helper: echo an instance's game folder (.minecraft or minecraft)
gamedir() {
  [ -d "$1/.minecraft" ] && { echo "$1/.minecraft"; return; }
  [ -d "$1/minecraft" ]  && { echo "$1/minecraft"; return; }
}

# 2. target = the New Haven pack instance (the one with the packwiz bootstrap jar)
TARGET=""
for inst in "$INSTDIR"/*/; do
  gd=$(gamedir "$inst"); [ -z "$gd" ] && continue
  [ -f "$gd/packwiz-installer-bootstrap.jar" ] && { TARGET="$gd"; break; }
done
if [ -z "$TARGET" ]; then
  echo "Couldn't find the New Haven pack instance. Import it first, then run this again."
  exit 1
fi

# 3. source = the OTHER instance with the LARGEST mc.mzalea.com map (your old one)
SRC=""; BEST=-1
for inst in "$INSTDIR"/*/; do
  gd=$(gamedir "$inst"); [ -z "$gd" ] && continue
  [ "$gd" = "$TARGET" ] && continue
  wm="$gd/xaero/world-map/$SERVER"; [ -d "$wm" ] || continue
  sz=$(du -sk "$wm" 2>/dev/null | cut -f1); sz=${sz:-0}
  if [ "$sz" -gt "$BEST" ]; then BEST="$sz"; SRC="$gd"; fi
done
if [ -z "$SRC" ]; then
  echo "No old New Haven map found to copy — nothing to do."
  exit 0
fi

# 4. MERGE the server's world-map + minimap in (no-clobber: never overwrites)
mkdir -p "$TARGET/xaero/world-map/$SERVER" "$TARGET/xaero/minimap/$SERVER"
cp -Rn "$SRC/xaero/world-map/$SERVER/." "$TARGET/xaero/world-map/$SERVER/" 2>/dev/null
[ -d "$SRC/xaero/minimap/$SERVER" ] && cp -Rn "$SRC/xaero/minimap/$SERVER/." "$TARGET/xaero/minimap/$SERVER/" 2>/dev/null

echo "Done! Your New Haven map was merged into the pack instance."
echo "Launch New Haven and your explored areas will be there."
