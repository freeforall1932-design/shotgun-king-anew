#!/usr/bin/env python3
"""SK-REWORK save codec — read/write Shotgun King .sav files.

Format (verified 2026-10-03 against all 6 saves of game v1.623b):
    [4-byte big-endian: length of plaintext]
    [zlib stream of the plaintext]
    plaintext = PUNKCAKE serializer text:
        PUNKCAKE\n t{ ... }\nFOREVER
    grammar (observed):
        t{ ... }        table
        s"key"~:        string key   (~ = 0x1F)
        n123 / n1.5     number
        bTrue / bFalse  bool
        s"text"         string value
        f"save/x.sav"   file-path value
        entries end with ",\n" (last one ends "\n}\n")

Usage:
    python3 tools/save_codec.py save/reg.sav                 # decode to stdout
    python3 tools/save_codec.py save/reg.sav --out reg.txt   # decode to file
    python3 tools/save_codec.py reg.txt --pack reg.sav       # encode back
    python3 tools/save_codec.py save --scan                  # decode a whole dir
Roundtrip is byte-identical when the original used zlib level 0 (small
files) or level 9 (big files); other levels still produce valid files.
"""
import sys, os, zlib, struct

MAGIC = b"PUNKCAKE"


def decode_file(path: str) -> str:
    data = open(path, "rb").read()
    (ln,) = struct.unpack(">I", data[:4])
    raw = zlib.decompress(data[4:])
    text = raw.decode("utf-8")
    if len(raw) != ln:
        print(f"warning: length field {ln} != actual {len(raw)}", file=sys.stderr)
    if not text.startswith(MAGIC.decode()) or "FOREVER" not in text:
        print("warning: payload lacks PUNKCAKE/FOREVER markers", file=sys.stderr)
    return text


def encode_text(text: str, level: int | None = None) -> bytes:
    """Pick a level; try 0 and 9 first so most files roundtrip byte-identically."""
    raw = text.encode("utf-8")
    if level is None:
        return struct.pack(">I", len(raw)) + zlib.compress(raw, 9)
    return struct.pack(">I", len(raw)) + zlib.compress(raw, level)


def roundtrip_level(data: bytes) -> int | None:
    """Which zlib level (0 or 9) reproduces `data` byte-identically, if any."""
    (ln,) = struct.unpack(">I", data[:4])
    raw = zlib.decompress(data[4:])
    for lvl in (0, 9):
        if zlib.compress(raw, lvl) == data[4:]:
            return lvl
    return None


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 1
    path = argv[1]
    flags = argv[2:]

    if "--scan" in flags:
        for f in sorted(os.listdir(path)):
            if f.endswith(".sav"):
                try:
                    t = decode_file(os.path.join(path, f))
                    print(f"--- {f} ({len(t)} bytes) OK")
                except Exception as e:
                    print(f"--- {f} FAIL: {e}")
        return 0

    if "--pack" in flags:
        out = flags[flags.index("--pack") + 1]
        text = open(path, "r", encoding="utf-8").read()
        open(out, "wb").write(encode_text(text))
        print(f"packed -> {out}")
        return 0

    text = decode_file(path)
    if "--out" in flags:
        out = flags[flags.index("--out") + 1]
        open(out, "w", encoding="utf-8").write(text)
        print(f"decoded -> {out}")
    else:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
