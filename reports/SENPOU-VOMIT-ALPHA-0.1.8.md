# Senpou monk particle texture correction — alpha 0.1.8

The user reported centipede shapes in Senpou monks' vomit after the earlier grab-effect substitution.

## Finding

The original `s04092` atlas visibly contains centipedes. Alpha 0.1.7 had the replacement `11606` in Action 603 Fields1, but still retained `4092` in the first Properties1 property. The original donor effect 220505 uses `11606` in both locations. The prior integer-only reference search missed the floating-point property.

C1210 animation entries 3002, 3003 and 3004 call effect 612110. That effect calls 612100, one of the affected entries. This is evidence of the monk effect chain, not a recorded gameplay identification of every animation.

## Changes

Starting from the verified alpha 0.1.7 packages, replace only the remaining four-byte floating-point texture properties from 4092 to 11606:

| Package | Effects | Properties |
| --- | --- | --- |
| Common effects | 612010, 612100, 612101 | 1, 1, 3 |
| m15 | 650010, 650011, 650012 | 1, 1, 3 |
| m25 | 650010, 650011, 650012 | 1, 1, 3 |

The replacement retains the earlier splash renderer configuration, timing, movement, hierarchy and offsets. No components are removed. Existing model edits, including the protected Long-arm family, are unaffected.

## Validation

`work/senpou-vomit/build.ps1` scans all 2,913 original FXR entries for the identified property, finding nine entries and fifteen renderers. It verifies the original donor, requires the earlier splash configuration, rejects ambiguous byte matches, and compares parsed XML to an expected document containing only the intended texture-property changes. It checks unchanged FXR lengths and bytes outside the selected fields. Repacked binders are reopened and all entries, metadata and compression checked; unrelated entries remain identical to alpha 0.1.7.

Evidence: `work/senpou-vomit/reference-audit.json` and `work/senpou-vomit/validation.json`. Release and installation checks are recorded separately in `work/alpha-0.1.8-release-validation.json` and `work/alpha-0.1.8-installation.json`.

The user confirmed the earlier grab substitution worked without a crash. This new texture-property correction has not yet been tested in gameplay. Verify vomit and grab attacks before describing the new behavior as gameplay-confirmed.

## Installation and distribution

Installed on September 22, 2026 at 18:57 with Sekiro closed. All 29 installed files match the complete alpha 0.1.8 release. Four files changed: three SFX binders and the title-menu version label. Backup: `work/backups/before-alpha-018-20260922-185749/`. The ZIP passed entry-by-entry hash validation, and only this latest release is retained.
