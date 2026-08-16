#!/bin/sh
# New Haven — one-time map migrator (Mac / Linux)
# Copies your explored New Haven map (Xaero world-map + minimap waypoints) from
# your OLD instance into the new auto-updating pack instance. Run it once.
# Safe: it never overwrites an existing map, and does nothing if there's none to copy.

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

# 3. already have the map there? then we're done
if [ -d "$TARGET/xaero/world-map/$SERVER" ]; then
  echo "Your map is already in the New Haven instance — nothing to do."
  exit 0
fi

# 4. source = any OTHER instance that has the mc.mzalea.com map
SRC=""
for inst in "$INSTDIR"/*/; do
  gd=$(gamedir "$inst"); [ -z "$gd" ] && continue
  [ "$gd" = "$TARGET" ] && continue
  [ -d "$gd/xaero/world-map/$SERVER" ] && { SRC="$gd"; break; }
done
if [ -z "$SRC" ]; then
  echo "No old New Haven map found to copy — nothing to do."
  exit 0
fi

# 5. copy the server's world-map + minimap into the new instance
mkdir -p "$TARGET/xaero/world-map" "$TARGET/xaero/minimap"
cp -r "$SRC/xaero/world-map/$SERVER" "$TARGET/xaero/world-map/"
[ -d "$SRC/xaero/minimap/$SERVER" ] && cp -r "$SRC/xaero/minimap/$SERVER" "$TARGET/xaero/minimap/"

echo "Done! Your New Haven map was copied into the pack instance."
echo "Launch New Haven and it'll be there."
