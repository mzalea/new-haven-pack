# New Haven — Client Modpack (packwiz)

This is the **auto-updating client modpack**. Players install it once; every launch
their launcher re-syncs against the hosted index and pulls only what changed.

It mixes three mod sources in one pack:

- **Modrinth mods** — referenced by CDN URL + hash (`mods/*.pw.toml`, `[update.modrinth]`).
- **CurseForge mods** — same, `[update.curseforge]`, for mods with no Modrinth build.
- **Custom New Haven jars** — `gooddog`, `hearthfolk`, `tempo`, `newhaven-core`,
  `newhaven-trees`, `sleepatdusk`. These are **raw files** committed into `mods/`
  and served straight from the pack host (indexed in `index.toml`, no `.pw.toml`).

## Update workflow (your side)

1. Build any changed custom mod: `cd mods/<name> && ./gradlew jar`, then copy the new
   jar into `client/modpack/mods/` (replace the old one).
2. Add / bump a Modrinth or CurseForge mod:
   - `packwiz modrinth add <slug>` / `packwiz curseforge add <slug>`
   - `packwiz update <name>` (or `packwiz update --all`) to bump.
   - `packwiz remove <name>` to drop one.
3. `packwiz refresh` — regenerates `index.toml` with new hashes.
4. Publish: push the `client/modpack/` tree to the host (see Hosting).

Every client picks up the change on next launch. No player action needed.

## Hosting

Served by **GitHub Pages** from the public `mzalea/new-haven-pack` repo at the custom
domain **`pack.mzalea.com`** (Cloudflare DNS, `CNAME pack → mzalea.github.io`, DNS-only).
The index is a few KB of TOML plus the custom jars (~1.8 MB), so load is trivial.

The client bootstrap fetches `https://pack.mzalea.com/pack.toml`.

This tree is generated — do not edit files here by hand. To publish an update, run
`scripts/publish-client-pack.sh` in the private `new-haven` repo: it regenerates this
tree from the server mod set and pushes it to `new-haven-pack`; Pages redeploys in
~1 min and every client picks up the change on next launch.

## Player install (one-time, handed out via Discord)

Players use **Prism Launcher** (or MultiMC):

1. Add an instance on Minecraft 1.21.1 + NeoForge 21.1.235.
2. Edit instance → add a **pre-launch command** running `packwiz-installer-bootstrap.jar`
   pointed at `<host>/pack.toml`. (Shipped as a ready-made instance zip in Discord so
   players don't hand-configure this.)
3. Launch. The bootstrap syncs all mods + configs and keeps them current every launch.

Shaders ship **off** by default (see `../settings.md`).
