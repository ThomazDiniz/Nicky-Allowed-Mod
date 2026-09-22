"""Build a complete local release from a verified base and the central VERSION file."""
from pathlib import Path
import argparse
import csv
from datetime import datetime, timezone
import hashlib
import json
import re
import shutil
import sys
import zipfile

ROOT = Path(__file__).resolve().parent.parent
RELEASES = ROOT / 'releases'
PREFIX = 'Nicky-Allowed-Invisible-Centipedes-alpha-'
VERSION_RE = r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)'
FIELDS = ['File', 'Bytes', 'SHA256', 'Compression', 'Models']
sys.path.insert(0, str(ROOT / 'work/title-menu'))
from build_title_label import main as build_menu


def version_tuple(value):
    if not re.fullmatch(VERSION_RE, value):
        raise ValueError('Version must be major.minor.patch, without a prefix or leading zeros')
    return tuple(map(int, value.split('.')))


def bump(value, level):
    parts = list(version_tuple(value))
    index = {'major': 0, 'minor': 1, 'patch': 2}[level]
    parts[index] += 1
    parts[index + 1:] = [0] * (2 - index)
    return '.'.join(map(str, parts))


def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest().upper()


def payload_path(folder, relative):
    path = (folder / relative).resolve()
    if not path.is_relative_to((folder / 'mods').resolve()) or not path.is_file():
        raise ValueError(f'Invalid or missing payload path: {relative}')
    return path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--bump', choices=['major', 'minor', 'patch'])
    group.add_argument('--version')
    parser.add_argument('--overlay', type=Path, help='Reviewed package directory containing mods/')
    parser.add_argument('--preview', action='store_true', help='Show next version without writing files')
    args = parser.parse_args()
    current = (ROOT / 'VERSION').read_text(encoding='utf-8-sig').strip()
    version_tuple(current)
    target_version = args.version or (bump(current, args.bump) if args.bump else current)
    if version_tuple(target_version) < version_tuple(current):
        raise ValueError('Refusing to lower the central version')
    base_candidates = []
    for folder in RELEASES.iterdir():
        match = re.fullmatch(re.escape(PREFIX) + '(' + VERSION_RE + ')', folder.name)
        if folder.is_dir() and match:
            base_candidates.append((version_tuple(match[1]), folder))
    if not base_candidates:
        raise ValueError('A complete local base release is required; clone-only builds are not supported')
    base_version, base = max(base_candidates)
    if version_tuple(target_version) <= base_version:
        raise ValueError('Target must be newer than the existing release; use -Bump patch')
    target = RELEASES / (PREFIX + target_version)
    archive_path = target.with_name(target.name + '.zip')
    if any(path.exists() for path in [target, archive_path, Path(str(archive_path) + '.sha256')]):
        raise FileExistsError('Target release already exists; choose a new version')
    if args.preview:
        print(json.dumps({'Current': current, 'Next': target_version, 'Base': str(base)}))
        return

    with (base / 'FILES-SHA256.csv').open(encoding='utf-8-sig', newline='') as stream:
        old_rows = list(csv.DictReader(stream))
    old_by_name = {row['File']: row for row in old_rows}
    actual_names = {p.relative_to(base).as_posix() for p in (base / 'mods').rglob('*') if p.is_file()}
    if len(old_by_name) != len(old_rows) or actual_names != set(old_by_name):
        raise ValueError('Base manifest does not exactly cover the base payload')
    for row in old_rows:
        path = payload_path(base, row['File'])
        if sha(path) != row['SHA256'] or path.stat().st_size != int(row['Bytes']):
            raise ValueError(f'Base hash/size mismatch: {row["File"]}')
    overlay_files = []
    if args.overlay:
        overlay = args.overlay.resolve() / 'mods'
        if not overlay.is_dir():
            raise ValueError('Overlay must contain a mods directory')
        for path in overlay.rglob('*'):
            if path.is_file():
                relative = path.relative_to(overlay)
                if not path.resolve().is_relative_to(overlay.resolve()):
                    raise ValueError('Overlay file escapes its mods directory')
                if relative.parts[0] not in {'chr', 'obj', 'map', 'sfx', 'menu'} or path.suffix not in {'.dcx', '.gfx', '.tpf'}:
                    raise ValueError(f'Unexpected overlay file: {relative}')
                overlay_files.append((path, Path('mods') / relative))

    # Stage outside releases so interrupted builds cannot be selected as valid bases.
    staging = ROOT / 'work/release-staging' / target.name
    if staging.exists():
        raise FileExistsError(f'Previous staging folder exists; inspect it before retrying: {staging}')
    shutil.copytree(base / 'mods', staging / 'mods')
    for source, relative in overlay_files:
        dest = staging / relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, dest)
    menu = build_menu(target_version, staging / 'mods/menu/05_000_title.gfx', quiet=True)
    rows = []
    for path in sorted((staging / 'mods').rglob('*')):
        if not path.is_file():
            continue
        name = path.relative_to(staging).as_posix()
        old = old_by_name.get(name, {})
        same = sha(path) == old.get('SHA256')
        rows.append({'File': name, 'Bytes': path.stat().st_size, 'SHA256': sha(path),
                     'Compression': old.get('Compression', '') if same else ('None' if path.suffix == '.gfx' else 'See source validation'),
                     'Models': old.get('Models', '') if same else ('0' if path.suffix == '.gfx' else '')})
    allowed_changes = {'mods/menu/05_000_title.gfx'} | {relative.as_posix() for _, relative in overlay_files}
    for row in rows:
        old = old_by_name.get(row['File'])
        if row['File'] not in allowed_changes and (old is None or old['SHA256'] != row['SHA256']):
            raise ValueError(f'Unrequested payload change: {row["File"]}')
    with (staging / 'FILES-SHA256.csv').open('w', encoding='utf-8', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(rows)
    (staging / 'VERSION').write_text(target_version + '\n', encoding='ascii')
    for name in ['README.md', 'CHANGES-AND-TESTS.md']:
        text = (ROOT / 'docs/release' / name).read_text(encoding='utf-8')
        text = text.replace('{{VERSION}}', target_version).replace('{{PAYLOAD_COUNT}}', str(len(rows)))
        if re.search(r'\{\{[^}]+\}\}', text):
            raise ValueError('Unresolved release documentation placeholder')
        (staging / name).write_text(text, encoding='utf-8')
    temporary_zip = staging.parent / (target.name + '.zip')
    if temporary_zip.exists():
        raise FileExistsError(temporary_zip)
    with zipfile.ZipFile(temporary_zip, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
        for path in sorted(staging.rglob('*')):
            if path.is_file():
                archive.write(path, path.relative_to(staging).as_posix())
    with zipfile.ZipFile(temporary_zip) as archive:
        assert archive.testzip() is None
        assert len(archive.namelist()) == len(rows) + 4
        for name in archive.namelist():
            assert hashlib.sha256(archive.read(name)).hexdigest().upper() == sha(staging / name)
    # Copy only after verification; recursive cleanup is handled by the PowerShell wrapper.
    shutil.copytree(staging, target)
    shutil.copy2(temporary_zip, archive_path)
    archive_hash = sha(archive_path)
    Path(str(archive_path) + '.sha256').write_text(f'{archive_hash}  {archive_path.name}\n', encoding='ascii')
    (ROOT / 'VERSION').write_text(target_version + '\n', encoding='ascii')
    project_readme = ROOT / 'README.md'
    text = project_readme.read_text(encoding='utf-8')
    status = f'**Invisible alpha {target_version}** contains {len(rows)} mod files, including the versioned title-menu label. The complete release was packaged and verified locally.\n\n'
    status += f'The local distribution is `releases/{target.name}.zip`, with a matching `.zip.sha256` checksum. Release binaries are ignored by Git and must be distributed separately.\n\n'
    status += 'The ZIP contains the complete `mods/` folder, `VERSION`, English `README.md`, `CHANGES-AND-TESTS.md` and `FILES-SHA256.csv`.\n\n'
    text = re.sub(r'(?<=## Current release\n\n).*?(?=## Coverage)', lambda _: status, text, flags=re.S)
    text = re.sub(r'Alpha \d+\.\d+\.\d+ is a complete package', f'Alpha {target_version} is a complete package', text)
    project_readme.write_text(text, encoding='utf-8')
    evidence = {'Version': target_version, 'Release': str(target), 'Zip': str(archive_path),
                'ZipSHA256': archive_hash, 'PayloadFiles': len(rows), 'AllZipHashesMatch': True,
                'UnchangedBaseFiles': sum(row['SHA256'] == old_by_name.get(row['File'], {}).get('SHA256') for row in rows),
                'BaseRelease': str(base), 'MenuLabel': menu['Label'], 'InstalledByBuild': False,
                'Staging': str(staging), 'StagingZip': str(temporary_zip), 'Date': datetime.now(timezone.utc).isoformat()}
    (ROOT / 'work' / f'alpha-{target_version}-release-validation.json').write_text(json.dumps(evidence, indent=2), encoding='utf-8')
    print(json.dumps(evidence))


if __name__ == '__main__':
    main()
