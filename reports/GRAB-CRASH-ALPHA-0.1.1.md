# Monk grab crash — recovery 0.1.2

Historical record from September 20, 2026. With alpha 0.1.1 installed, the user reported `0xC0000005` at `0x141DAB06B` during a monk grab. The log was preserved at `work/senpou-effects/alpha-011-grab-crash.log`.

The main suspect was the FXR change that removed Effect 1004 elements. The log did not conclusively establish the cause. Successful parsing and equality checks on remaining data were insufficient to guarantee runtime compatibility.

## Recovery performed

- Packaged and installed alpha 0.1.2 with Sekiro closed.
- Restored the common, m15 and m25 SFX packages byte-for-byte from the game originals. Included these files in the recovery ZIP to overwrite the suspect 0.1.1 effects.
- Retained all other 23 packages, including four Senpou floor fixes.
- Verified all 26 installed hashes and all ZIP entries.
- Preserved backup `work/backups/before-alpha-012-install-20260920-212106/`.
- Marked 0.1.1 unsuitable for use or distribution.

## Follow-up at the time

The user needed to repeat the grab to assess recovery and test the floor. Centipede particles could reappear with the original effects restored. If the crash persisted, the next investigation would isolate C1200/C1210 edits and conflicts with other mods.

Texture s04093 remained visually confirmed as centipedes; the discovery was valid even though the component-deletion method was reverted. Further work was to preserve effect nodes and avoid reconstructing complete FXR files.

## Subsequent outcome

Alpha 0.1.4 replaced only fixed visual-field blocks with a splash configuration. The user confirmed that this worked without a crash in the tested encounter on September 21. This is not proof of the precise 0.1.1 crash cause or validation of all attacks. See [the particle report](BLOOD-PARTICLES-ALPHA-0.1.4.md).

Only alpha 0.1.6 is now retained for distribution; use a verified personal backup for rollback, not a deleted historical ZIP.
