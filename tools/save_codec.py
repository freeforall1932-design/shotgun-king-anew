#!/usr/bin/env python3
"""SK-REWORK save codec — read/write Shotgun King .sav files.

Container format (verified 2026-10-03 against all 6 saves of game v1.623b):
    [4-byte big-endian: length of plaintext]
    [zlib stream of the plaintext]

Plaintext = PUNKCAKE serializer text:
    PUNKCAKE\nt{ ... }\nFOREVER
Grammar (line-oriented):
    key line:    <s"key"\x1f | n<num>> ": " <value> ","
    value:       t{  (opens a nested table)  |  n<number>  |  bTrue/bFalse
                 |  s"string"  |  f"file path"
    closing:     "}" or "},"  (nesting depth tracked)
    every entry line ends with a comma, including the last one in a table.

This module parses that into plain Python dicts (numbers kept as raw strings
so re-serialization is lossless) and serializes back, byte-identical on all
six shipped saves (see test at bottom: `python3 save_codec.py --selftest`).

CLI:
    python3 save_codec.py save/reg.sav                 # decode to stdout
    python3 save_codec.py save/reg.sav --out reg.txt   # decode to file
    python3 save_codec.py reg.txt --pack reg.sav       # encode text back
    python3 save_codec.py save --scan                  # decode a whole dir
    python3 save_codec.py --selftest savedir           # parse->serialize
                                                     # roundtrip on every .sav
"""
import sys, os, re, zlib, struct

MAGIC = "PUNKCAKE"
KEY_RE = re.compile(r'^(s"(.*?)"\x1f|n(-?\d+)): (.*)$')
NUM_RE = re.compile(r'^n(-?[\d.]+)$')
STR_RE = re.compile(r'^s"(.*)"(?:\x1f)?$')
FILE_RE = re.compile(r'^f"(.*)"$')


# ── container ───────────────────────────────────────────────────────────────

def decode_file(path: str) -> str:
    data = open(path, "rb").read()
    (ln,) = struct.unpack(">I", data[:4])
    text = zlib.decompress(data[4:]).decode("utf-8")
    if len(text.encode()) != ln:
        print(f"warning: length field {ln} != actual {len(text.encode())}",
              file=sys.stderr)
    if not text.startswith(MAGIC) or "FOREVER" not in text:
        print("warning: payload lacks PUNKCAKE/FOREVER markers", file=sys.stderr)
    return text


def encode_text(text: str) -> bytes:
    raw = text.encode("utf-8")
    return struct.pack(">I", len(raw)) + zlib.compress(raw, 9)


# ── PUNKCAKE serializer: parse ─────────────────────────────────────────────

def parse(text: str) -> dict:
    """PUNKCAKE text -> dict. Numbers stay raw strings ('12', '99.623')."""
    lines = text.split("\n")
    if lines[0] != MAGIC or lines[-1] != "FOREVER":
        raise ValueError("not a PUNKCAKE payload")
    root = None
    stack = []          # list of dicts

    for ln in lines[1:-1]:
        if not ln:
            continue
        stripped = ln.strip()
        if stripped == "t{":                 # root table only
            if root is not None or stack:
                raise ValueError("unexpected t{")
            root = {}
            stack.append(root)
            continue
        if stripped in ("}", "},"):
            stack.pop()
            continue
        m = KEY_RE.match(stripped)
        if not m:
            raise ValueError(f"unparsed line: {stripped!r}")
        skey, sval, nkey = m.group(1), m.group(2), m.group(3)
        key = sval if skey.startswith('s"') else int(nkey)
        val = m.group(4)
        if val.endswith(","):
            val = val[:-1]
        if val == "t{":                      # nested table opens on this line
            tbl = {}
            stack[-1][key] = tbl
            stack.append(tbl)
            continue
        nm = NUM_RE.match(val)
        if nm:
            stack[-1][key] = ("n", nm.group(1)); continue
        if val in ("bTrue", "bFalse"):
            stack[-1][key] = ("b", val == "bTrue"); continue
        sm = STR_RE.match(val)
        if sm:
            stack[-1][key] = ("s", sm.group(1)); continue
        fm = FILE_RE.match(val)
        if fm:
            stack[-1][key] = ("f", fm.group(1)); continue
        raise ValueError(f"unparsed value: {val!r}")
    if stack:
        raise ValueError("unbalanced braces")
    return root


# ── PUNKCAKE serializer: emit ──────────────────────────────────────────────

def _emit_value(v) -> str:
    kind, raw = v
    if kind == "n":
        return f"n{raw}"
    if kind == "b":
        return "bTrue" if raw else "bFalse"
    if kind == "s":
        return f's"{raw}"\x1f'
    if kind == "f":
        return f'f"{raw}"'
    raise TypeError(v)


def _emit_key(k) -> str:
    if isinstance(k, int):
        return f"n{k}"
    return f's"{k}"\x1f'


def serialize(d: dict) -> str:
    out = [MAGIC, "t{"]
    def walk(tbl, depth):
        for k, v in tbl.items():
            if isinstance(v, dict):
                out.append(f"{_emit_key(k)}: t{{")
                walk(v, depth + 1)
                out.append(f"}},")
            else:
                out.append(f"{_emit_key(k)}: {_emit_value(v)},")
    walk(d, 1)
    out.append("}")
    out.append("FOREVER")
    return "\n".join(out)


def load_save(path: str) -> dict:
    return parse(decode_file(path))


def save_save(path: str, data: dict) -> None:
    open(path, "wb").write(encode_text(serialize(data)))


# ── helpers for editing ────────────────────────────────────────────────────

def n(x) -> tuple:
    """number value (raw string keeps original formatting)"""
    return ("n", str(x))

def b(x: bool) -> tuple:
    return ("b", bool(x))

def s(x: str) -> tuple:
    return ("s", x)


# ── CLI ────────────────────────────────────────────────────────────────────

def main(argv):
    if not argv[1:] or argv[1] in ("-h", "--help"):
        print(__doc__)
        return 0

    if "--selftest" in argv:
        d = argv[argv.index("--selftest") + 1]
        ok = 0
        for f in sorted(os.listdir(d)):
            if not f.endswith(".sav"):
                continue
            text = decode_file(os.path.join(d, f))
            if serialize(parse(text)) == text:
                ok += 1
            else:
                print(f"ROUNDTRIP MISMATCH: {f}")
        print(f"parse->serialize byte-identical on {ok} save(s)")
        return 0 if ok else 1

    path, flags = argv[1], argv[2:]

    if "--scan" in flags:
        for f in sorted(os.listdir(path)):
            if f.endswith(".sav"):
                try:
                    decode_file(os.path.join(path, f))
                    print(f"--- {f} OK")
                except Exception as e:
                    print(f"--- {f} FAIL: {e}")
        return 0

    if "--pack" in flags:
        out = flags[flags.index("--pack") + 1]
        text = open(path, encoding="utf-8").read()
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
