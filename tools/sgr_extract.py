#!/usr/bin/env python3
"""
sgr_extract.py — decode SUGAR's data.sgr package (Shotgun King v1.623b).

Reverse-engineered in session 10 from shotgun_king.exe (32-bit MinGW build):

  loader  0x4aa050 : fopen/fread the whole file
                     -> 0x49d550 decrypt in place
                     -> BE u32 uncompressed length at [0:4]
                     -> zlib uncompress(src = [4 : len-4])
  decrypt 0x49d550 : seed = BE u32 of the LAST 4 bytes ^ 0x550f0f55
                     srand(seed) (0x4181a0), r = rand(), skip (r & 15) draws,
                     then for EVERY EVEN index i < len-4:  buf[i] ^= rand() & 0xff
  rand    0x4181f0 : xorwow-style (5 x u32 state, see class XorWow)

Inner container (after uncompress), all big-endian:
  str title, str developer, str main_file           (str = u16 len + bytes)
  repeat: str path, u8 flag, u32 size, size bytes   (flag 1 = glob manifest)
Every entry's bytes are encrypted again with the SAME scheme (own trailing
4-byte seed) — strip the last 4 bytes after decrypting.

Usage (works from any folder):
  python tools/sgr_extract.py game/data.sgr game/decoded            # code/lang/libs/gfx/shaders
  python tools/sgr_extract.py game/data.sgr /tmp/full --all         # + fonts, sfx, music (~92 MB)
  python tools/sgr_extract.py game/data.sgr --list                  # list entries only
Pure Python, ~1 min (the outer XOR runs over 83 MB).
"""
import argparse
import os
import struct
import sys
import zlib

M = 0xFFFFFFFF


class XorWow:
    """Exact port of the engine's srand (0x4181a0) / rand (0x4181f0)."""

    def __init__(self, v):
        self.s0 = v & M
        self.s1 = ((v >> 1) + 0x159A55E5) & M
        self.s2 = ((v >> 3) + 0x1F123BB5) & M
        self.s3 = ((v >> 5) + 0x05491333) & M
        self.s4 = ((v >> 7) + 0x34DAD465) & M

    def next(self):
        x, c, b = self.s0, self.s2, self.s4
        t = (x ^ (x >> 7)) & M
        self.s0, self.s1 = self.s1, c
        self.s2, self.s3 = self.s3, b
        v = ((b << 6) & M) ^ b ^ t ^ ((t << 13) & M)
        self.s4 = v
        return ((2 * c + 1) * v) & M


def decrypt(blob):
    """Undo the engine's in-place XOR (0x49d550). Returns the full buffer
    (the trailing 4 seed bytes are left untouched)."""
    if len(blob) < 4:
        return bytes(blob)
    d = bytearray(blob)
    n = len(d) - 4
    r = XorWow(struct.unpack(">L", bytes(d[-4:]))[0] ^ 0x550F0F55)
    for _ in range(r.next() & 15):
        r.next()
    nxt = r.next
    for i in range(0, n, 2):
        d[i] ^= nxt() & 0xFF
    return bytes(d)


def unpack_outer(path):
    data = decrypt(open(path, "rb").read())
    ulen = struct.unpack(">L", data[:4])[0]
    raw = zlib.decompress(data[4:len(data) - 4])
    if len(raw) != ulen:
        raise SystemExit("length mismatch: header %d, got %d" % (ulen, len(raw)))
    return raw


def entries(raw):
    p = 0

    def rs():
        nonlocal p
        n = struct.unpack(">H", raw[p:p + 2])[0]
        s = raw[p + 2:p + 2 + n].decode("utf8")
        p += 2 + n
        return s

    header = (rs(), rs(), rs())
    out = []
    while p < len(raw):
        name = rs()
        flag = raw[p]
        size = struct.unpack(">L", raw[p + 1:p + 5])[0]
        p += 5
        out.append((name, flag, raw[p:p + size]))
        p += size
    return header, out


# default subset: everything a modder reads; skip the big audio/fonts
DEFAULT_SKIP = ("assets/music/", "assets/sfx/", "assets/fonts/")


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("sgr")
    ap.add_argument("out", nargs="?")
    ap.add_argument("--all", action="store_true", help="also write fonts/sfx/music")
    ap.add_argument("--list", action="store_true", help="only list the entries")
    a = ap.parse_args(argv)
    raw = unpack_outer(a.sgr)
    (title, dev, main_file), items = entries(raw)
    print("%s | %s | main=%s | %d entries" % (title, dev, main_file, len(items)))
    if a.list or not a.out:
        for name, flag, blob in items:
            print("%9d  %s%s" % (len(blob), name, "  [manifest]" if flag else ""))
        return 0
    written = 0
    for name, flag, blob in items:
        rel = name
        while rel.startswith("../"):
            rel = rel[3:]
        if flag or "*" in rel:
            continue  # glob manifests (assets/gfx/*.png …)
        if not a.all and rel.startswith(DEFAULT_SKIP):
            continue
        dst = os.path.join(a.out, rel)
        os.makedirs(os.path.dirname(dst) or a.out, exist_ok=True)
        with open(dst, "wb") as f:
            f.write(decrypt(blob)[:-4])
        written += 1
    print("wrote %d files -> %s" % (written, a.out))
    return 0


if __name__ == "__main__":
    sys.exit(main())
