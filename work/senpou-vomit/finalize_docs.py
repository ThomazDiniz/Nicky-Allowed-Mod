from pathlib import Path
p=Path('reports/ACTION-PLAN.md')
s=p.read_text(encoding='utf-8-sig')
start=s.index('**Current release:')
end=s.index('- [x] Complete',start)
s=s[:start]+'''**Current release: alpha 0.1.8, September 22.** The remaining s04092 texture properties in fifteen particle renderers were replaced with the existing splash donor s11606. This addresses a concrete remaining centipede texture reference in the monk effect chain after the reported vomit appearance. See [the correction report](SENPOU-VOMIT-ALPHA-0.1.8.md).

The complete 29-file release is installed with Sekiro closed and all installed hashes verified. Three effect packages and the menu version label changed from 0.1.7; the other 25 payload files are identical. Backup: `work/backups/before-alpha-018-20260922-185749/`. Installation record: `work/alpha-0.1.8-installation.json`. The new texture correction has not yet been tested in gameplay.

Current distribution: `releases/Nicky-Allowed-Invisible-Centipedes-alpha-0.1.8.zip`, with English instructions, VERSION and a SHA-256 manifest. Only the latest release is retained. The title-menu label reads `Nicky Allowed - Invisible Centipedes | alpha 0.1.8`. Hanbei's separate C1013 parasite remains hidden; see [the audit](HANBEI-FINAL-QUEST.md).

'''+s[end:]
s=s.replace('- [ ] Test remaining attacks,', '- [ ] Confirm the alpha 0.1.8 particle texture correction during monk vomit and grab attacks.\n- [ ] Test remaining attacks,')
p.write_text(s,encoding='utf-8')
p=Path('reports/SENPOU-VOMIT-ALPHA-0.1.8.md')
s=p.read_text(encoding='utf-8')+'\n## Installation and distribution\n\nInstalled on September 22, 2026 at 18:57 with Sekiro closed. All 29 installed files match the complete alpha 0.1.8 release. Four files changed: three SFX binders and the title-menu version label. Backup: `work/backups/before-alpha-018-20260922-185749/`. The ZIP passed entry-by-entry hash validation, and only this latest release is retained.\n'
p.write_text(s,encoding='utf-8')
