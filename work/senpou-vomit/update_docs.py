from pathlib import Path
root=Path.cwd()
p=root/'docs/release/CHANGES-AND-TESTS.md'
s=p.read_text(encoding='utf-8-sig')
s=s.replace('## Title-menu label and version', '''## Senpou monk particle texture correction — 0.1.8

The user reported centipede shapes in the monks' vomit after the earlier grab-effect substitution. Alpha 0.1.8 replaces the remaining `s04092` texture property with `s11606`, the same splash texture selected from original effect 220505. Fifteen properties across nine FXR entries in the three existing effect packages were corrected. The earlier renderer settings are retained. Each change occupies one existing four-byte field; no effect components were deleted or reserialized.

The C1210 animation references include effect 612110, which calls corrected effect 612100. Original texture s04092 was visually confirmed to contain centipedes. This identifies a concrete remaining texture reference associated with the monk effects; the exact vomit appearance still needs gameplay confirmation.

A fresh scan of 2,913 original FXR files found these same nine entries using the identified texture property. The previous audit checked integer renderer settings and missed this floating-point texture property. All other mod payload files are unchanged from 0.1.7, except the title-menu version label. Package checks do not constitute an in-game crash test.

## Title-menu label and version''')
s=s.replace('All 28 earlier mod files are unchanged from alpha 0.1.6.', 'In alpha 0.1.7, all 28 earlier mod files were unchanged from alpha 0.1.6.')
s=s.replace('Existing timing, movement and other properties remain,', 'Existing timing, movement and unrelated properties remain,')
s=s.replace('The current substitution, introduced in 0.1.4, was confirmed', 'The earlier substitution, introduced in 0.1.4, was confirmed')
s=s.replace('- [x] Particle substitution confirmed by the user without a crash in the tested encounter.', '- [x] Alpha 0.1.4 particle substitution confirmed by the user without a crash in the tested encounter.\n- [ ] Alpha 0.1.8 texture-property correction: verify monk vomit and grab attacks in gameplay.')
s=s.replace('finding no additional confirmed targets under the known references.', 'finding no additional model targets under the known references. Its particle search missed floating-point texture properties; alpha 0.1.8 corrects the remaining s04092 references described above.')
p.write_text(s,encoding='utf-8')
report='''# Senpou monk particle texture correction — alpha 0.1.8

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
'''
(root/'reports/SENPOU-VOMIT-ALPHA-0.1.8.md').write_text(report,encoding='utf-8')
for name in ['REFERENCE-AUDIT-2026-09-21.md','BLOOD-PARTICLES-ALPHA-0.1.4.md']:
 p=root/'reports'/name;s=p.read_text(encoding='utf-8-sig');first,rest=s.split('\n',1)
 s=first+'\n\n**September 22 correction:** The earlier renderer-field substitution and integer-only audit missed the first floating-point texture property, which still referenced centipede atlas s04092. Alpha 0.1.8 addresses those fifteen properties using the same splash donor. See [the follow-up report](SENPOU-VOMIT-ALPHA-0.1.8.md). Historical gameplay confirmations below apply only to the encounters actually tested.\n'+rest
 p.write_text(s,encoding='utf-8')
