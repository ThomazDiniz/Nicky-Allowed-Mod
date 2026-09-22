# Nicky Allowed — Invisible Centipedes — alpha {{VERSION}}

A visual accessibility mod for Sekiro: Shadows Die Twice on PC, made for a friend who is afraid of centipedes. This complete release hides selected models and scenery layers and replaces identified centipede particles with splash rendering from the game.

**Long-arm Centipede and its C1030/C1040 variants are intentionally preserved.** Some worm and other insect layers were also removed by explicit request. This alpha does not guarantee that every centipede appearance has been covered.

## Installation and upgrading

1. Close Sekiro completely.
2. Back up your existing mod folder and `modengine.ini`, if present.
3. Install [Sekiro Mod Engine](https://www.nexusmods.com/sekiro/mods/6) if needed, following its author's instructions. The loader is not included in this ZIP. Its files belong beside `sekiro.exe`.
4. Check these options in the `[files]` section of `modengine.ini`:

   ```ini
   loadUXMFiles=0
   useModOverrideDirectory=1
   modOverrideDirectory="\mods"
   ```

5. Extract this ZIP, then copy its entire `mods` folder into the game directory, beside `sekiro.exe`. Replace this mod's older files when upgrading. Do not create `mods/mods`.
6. If Mod Engine uses a different override directory, copy the contents of `mods` into that directory instead.
7. Launch Sekiro normally through Steam. You do not need Yabber, FLVER Editor or DSMapStudio to play with the mod. Restart the game after changing mod files.

Expected folder layout:

```text
Sekiro/
  sekiro.exe
  dinput8.dll
  modengine.ini
  mods/
    chr/
    obj/
    map/
    sfx/
    menu/
```

Alpha {{VERSION}} is a complete package; no earlier release is required. Other mods that replace the same files need a compatible merge. Copying one mod over another does not combine their changes.

## What is included

- {{PAYLOAD_COUNT}} mod files: six character packages, five object packages, fourteen scenery packages, three effect packages and one title-menu file.
- `CHANGES-AND-TESTS.md`: coverage, changes and test status.
- `FILES-SHA256.csv`: relative paths, sizes, SHA-256 checksums, compression and model counts for the {{PAYLOAD_COUNT}} mod files.

## Latest changes

- The title menu displays `Nicky Allowed - Invisible Centipedes | alpha {{VERSION}}`.
- The included `VERSION` file records this release number.

- Worm layers on the Dungeon bodies in `m13_00_00_00_001200` are hidden while the bodies, clothing and hair are preserved.
- The additional individual insect/worm layer in Senpou scenery `m20_00_00_00_502001` and its distance variant is hidden. Wood and the previously completed changes are preserved.
- Earlier animated/static floor corrections and the centipede-to-splash particle substitution remain included.
- Objects `o116050` and `o116051` remain unchanged: the user inspected them and found no centipedes. Their generic material name `Material #337` refers to charcoal textures.

## Credits

Tools used: FLVER Editor, SoulsFormats, Yabber and DSMapStudio. Loading through Sekiro Mod Engine by Katalash. Original game assets belong to their respective rights holders. This is an unofficial fan project.

Distribute the complete ZIP so that the instructions and limitations accompany the mod.

