"""Add one independent title-screen label, preserving all original GFX tags."""
from pathlib import Path
import hashlib
import json
import re
import struct
from inspect_gfx import Bits, edit_text, tags

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path(r'C:\Program Files (x86)\Steam\steamapps\common\Sekiro\menu\05_000_title.gfx')
OUTPUT = ROOT / 'dist/title-label-test/mods/menu/05_000_title.gfx'
LABEL = 'Nicky Allowed - Invisible Centipedes'


def pack_bits(fields):
    bits = ''.join(format(value & ((1 << width) - 1), f'0{width}b') for value, width in fields)
    bits += '0' * (-len(bits) % 8)
    return int(bits, 2).to_bytes(len(bits) // 8, 'big')


def rectangle(values):
    width = max(abs(value).bit_length() + 1 for value in values)
    return pack_bits([(width, 5)] + [(value, width) for value in values])


def translation(x, y):
    width = max(abs(x).bit_length(), abs(y).bit_length()) + 1
    return pack_bits([(0, 1), (0, 1), (width, 5), (x, width), (y, width)])


def tag(code, payload):
    return struct.pack('<HI', code << 6 | 63, len(payload)) + payload


def main(version=None, output=None, quiet=False):
    version = version or (ROOT / 'VERSION').read_text(encoding='utf-8-sig').strip()
    if not re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)', version):
        raise ValueError('VERSION must contain a numeric major.minor.patch version')
    label = f'{LABEL} | alpha {version}'
    output = Path(output) if output else OUTPUT
    original = SOURCE.read_bytes()
    assert original[:4] == b'GFX\x0b', 'Unexpected source format/version'
    declared = struct.unpack_from('<I', original, 4)[0]
    assert not any(original[declared:]), 'Unexpected nonzero alignment padding'
    reader = Bits(original, 8)
    assert reader.rect() == [0, 38400, 0, 21600], 'Unexpected stage size'
    start = reader.pos // 8 + 4
    old_tags = list(tags(original, start, declared))
    definitions = {2, 6, 7, 10, 11, 14, 20, 21, 22, 32, 33, 34, 35, 36,
                   37, 39, 46, 48, 60, 75, 83, 84, 87, 90, 91, 1009}
    ids = [struct.unpack_from('<H', payload)[0] for code, payload, *_ in old_tags if code in definitions]
    character_id = max(ids) + 1
    depths = [struct.unpack_from('<H', payload, 1 if code == 26 else 2)[0]
              for code, payload, *_ in old_tags if code in (26, 70)]
    depth = max(depths) + 1
    # Reuse the original plain-text style and font-class mechanism, not game-bound field names.
    sample = next(payload for code, payload, *_ in old_tags
                  if code == 37 and struct.unpack_from('<H', payload)[0] == 58)
    assert edit_text(sample)['Flags'] == '0xa18c'
    assert b'MenuFont_01\0' in sample
    flags = 0xA18C | 0x1000  # Original flags plus NoSelect; already ReadOnly.
    payload = struct.pack('<H', character_id) + rectangle([0, 18000, 0, 900])
    payload += struct.pack('<H', flags) + b'MenuFont_01\0' + struct.pack('<H', 480)
    payload += bytes([230, 220, 200, 255])  # Warm white, 24 px on the 1920x1080 stage.
    payload += struct.pack('<BHHhh', 0, 0, 0, 0, 0)  # Left-aligned layout.
    payload += b'\0' + label.encode('ascii') + b'\0'  # Empty variable binding.
    define = tag(37, payload)
    # An unnamed placement avoids script/game text replacement and input bindings.
    place = tag(26, bytes([0x06]) + struct.pack('<HH', depth, character_id) + translation(1280, 1000))
    insertion = next(begin for code, _, begin, _ in old_tags if code == 1)
    body = original[:insertion] + define + place + original[insertion:declared]
    body = body[:4] + struct.pack('<I', len(body)) + body[8:]
    modified = body + bytes(-len(body) % 16)
    new_tags = list(tags(modified, start, len(body)))
    retained = [modified[begin:end] for code, data, begin, end in new_tags
                if not (code == 37 and data == payload) and not (code == 26 and modified[begin:end] == place)]
    assert retained == [original[begin:end] for _, _, begin, end in old_tags]
    assert len(new_tags) == len(old_tags) + 2
    assert modified.count(label.encode()) == 1
    assert edit_text(payload)['Bounds'] == [0, 18000, 0, 900]
    assert character_id not in ids and depth not in depths
    assert modified[:4] == original[:4] and modified[8:start] == original[8:start]
    # Decode the new placement matrix independently of its bit writer.
    matrix = Bits(place[11:])
    assert matrix.read(1) == 0 and matrix.read(1) == 0
    width = matrix.read(5)
    assert [matrix.read(width, True), matrix.read(width, True)] == [1280, 1000]
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(modified)
    evidence = {'Source': str(SOURCE), 'Output': str(output), 'Label': label, 'Version': version,
                'SourceSHA256': hashlib.sha256(original).hexdigest().upper(),
                'OutputSHA256': hashlib.sha256(modified).hexdigest().upper(),
                'OriginalTagsUnchanged': len(old_tags), 'AddedTags': 2,
                'CharacterId': character_id, 'Depth': depth,
                'PositionPixels': [64, 50], 'FontPixels': 24,
                'BaseLabelUserValidated': True, 'VersionSuffixGameTested': False,
                'AdditionalUserTestRequired': False, 'Result': 'PASS'}
    (ROOT / 'work/title-menu/validation.json').write_text(json.dumps(evidence, indent=2), encoding='utf-8')
    if not quiet:
        print(json.dumps(evidence, indent=2))
    return evidence


if __name__ == '__main__':
    main()
