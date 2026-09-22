"""Inspect the original Scaleform tag stream without changing game files."""
from pathlib import Path
import json
import struct


class Bits:
    def __init__(self, data, pos=0):
        self.data = data
        self.pos = pos * 8

    def read(self, count, signed=False):
        value = 0
        for _ in range(count):
            value = (value << 1) | ((self.data[self.pos // 8] >> (7 - self.pos % 8)) & 1)
            self.pos += 1
        return value - (1 << count) if signed and count and value & (1 << (count - 1)) else value

    def rect(self):
        width = self.read(5)
        result = [self.read(width, True) for _ in range(4)]
        self.pos = (self.pos + 7) // 8 * 8
        return result


def tags(data, start, end=None):
    end = len(data) if end is None else end
    while start < end:
        origin = start
        header = struct.unpack_from('<H', data, start)[0]
        code, length = header >> 6, header & 63
        start += 2
        if length == 63:
            length = struct.unpack_from('<I', data, start)[0]
            start += 4
        assert start + length <= end
        yield code, data[start:start + length], origin, start + length
        start += length
        if code == 0:
            assert not any(data[start:end]), 'Nonzero data after End tag'
            break


def edit_text(data):
    reader = Bits(data, 2)
    bounds = reader.rect()
    offset = reader.pos // 8
    flags = struct.unpack_from('<H', data, offset)[0]
    return {'Id': struct.unpack_from('<H', data)[0], 'Bounds': bounds,
            'Flags': hex(flags), 'AfterFlagsHex': data[offset + 2:].hex()}


if __name__ == '__main__':
    path = Path(r'C:\Program Files (x86)\Steam\steamapps\common\Sekiro\menu\05_000_title.gfx')
    data = path.read_bytes()
    reader = Bits(data, 8)
    rect = reader.rect()
    start = reader.pos // 8 + 4
    result = {'Signature': data[:3].decode(), 'DeclaredLength': struct.unpack_from('<I', data, 4)[0],
              'ActualLength': len(data), 'StageTwips': rect, 'Tags': []}
    for code, payload, begin, end in tags(data, start):
        item = {'Code': code, 'Offset': begin, 'Length': len(payload)}
        if code == 37:
            item.update(edit_text(payload))
        if code in (26, 70):
            item['Hex'] = payload.hex()
        if code == 39:
            item['SpriteId'], item['Frames'] = struct.unpack_from('<HH', payload)
        result['Tags'].append(item)
    output = Path(__file__).parent / 'original-gfx-structure.json'
    output.write_text(json.dumps(result, indent=2), encoding='utf-8')
    print(json.dumps(result, indent=2))
