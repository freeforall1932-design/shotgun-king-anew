#!/usr/bin/env python3
"""Build 8 item 4 regression check for the vendored mod MODES' gun lists.

Loads each patched mode file from dist-overlay/mods/*/modes/ under LuaJIT
(lupa) with a fake mod bank and permissive stubs for everything else, then
checks:
  * the gun list is the full base-game Throne list (9 guns, same names and
    order as game/decoded/code/modes/throne.lua, firerange = 3 + throne's
    delta because the mod modes' `base` has no firerange);
  * no mode re-registers the 'weapons' sheet (the engine boot-loads the
    9-gun base sheet; the mods shipped stale 5-/7-gun copies);
  * Quartz / Fairy: initialize() unlocks every gun in the mod bank and
    flushes it with savbnk(); get_weapons_list() then offers all 9;
    Quartz also opens every rank (get_max_rank() == #ranks);
  * every other mod file with a Throne-style weapons={...} list (even ones
    the engine never loads) matches the Throne list too;
    save_preferences() flushes the bank too (Quartz used to never flush);
  * Nightmare / Card Lab: get_weapons_list() offers all 9 (as before).

Usage:  /tmp/skvenv/bin/python tools/mode_guns_check.py
(needs `pip install lupa`). Exit code 0 = all checks passed.
"""
import pathlib, re, sys

try:
    import lupa.luajit21 as lj
except ImportError:  # pragma: no cover
    sys.exit("needs lupa (pip install lupa)")

ROOT = pathlib.Path(__file__).resolve().parent.parent
MODS = ROOT / "dist-overlay" / "mods"
THRONE = ROOT / "game" / "decoded" / "code" / "modes" / "throne.lua"

MODES = {
    "Quartz Throne": ("the_magnificient_quartz_army/modes/Quartz Throne.lua", "bank"),
    "Fairy Endless": ("some_fairy_pieces/modes/Fairy Endless.lua", "bank"),
    "nightmare": ("nightmare/modes/nightmare.lua", "all"),
    "card lab": ("royal card lab/modes/card lab.lua", "all"),
}

STUB_LUA = r"""
local function mkstub(name)
  local s = {}
  return setmetatable(s, {
    __index = function(t, k) local v = mkstub(name .. "." .. tostring(k)); rawset(t, k, v); return v end,
    __call = function() return mkstub(name .. "()") end,
    __concat = function(a, b) return tostring(a) .. tostring(b) end,
    __tostring = function() return "<stub " .. name .. ">" end,
    __add = function() return 0 end, __sub = function() return 0 end,
    __lt = function() return false end, __le = function() return true end,
    __unm = function() return 0 end, __len = function() return 0 end,
  })
end

return function(src, chunkname)
  local bank, calls = {}, {savbnk = 0, newsrf = {}, log = {}}
  local env = {
    bget = function(x, y) return bank[y * 128 + x] or 0 end,
    bset = function(x, y, v) bank[y * 128 + x] = v end,
    savbnk = function() calls.savbnk = calls.savbnk + 1 end,
    newbnk = function() end, bank = function() return "mod" end,
    newsrf = function(name, path) calls.newsrf[#calls.newsrf + 1] = tostring(name) .. "|" .. tostring(path) end,
    log = function(s) calls.log[#calls.log + 1] = tostring(s) end,
    save = function() end,
    mid = function(a, b, c) if b < a then return a elseif b > c then return c end return b end,
    add = function(t, v) t[#t + 1] = v; return v end,
    all = function(t) local i = 0; return function() i = i + 1; return t[i] end end,
    MODS = {some_fairy_pieces = {env = mkstub("fairy_env")},
            the_magnificient_quartz_army = {env = mkstub("quartz_env")}},
    MODLIST = {}, mode = {}, DEV = false,
    type = type, tostring = tostring, tonumber = tonumber, pairs = pairs, ipairs = ipairs,
    math = math, string = string, table = table, select = select, unpack = unpack,
    setmetatable = setmetatable, getmetatable = getmetatable, rawget = rawget, rawset = rawset,
  }
  setmetatable(env, {__index = function(t, k) local v = mkstub(k); rawset(t, k, v); return v end})
  local f, err = loadstring(src, "=" .. chunkname)
  if not f then return nil, err end
  setfenv(f, env)
  local ok, e2 = pcall(f)
  if not ok then return nil, e2 end
  env.mode = env  -- modes refer to their own table as `mode`
  return env, calls, bank
end
"""


def throne_guns():
    src = THRONE.read_text(encoding="utf-8", errors="replace")
    block = re.search(r"^weapons\s*=\s*\{(.*?)^\}", src, re.S | re.M).group(1)
    guns = []
    for line in block.splitlines():
        m = re.search(r'name="([^"]+)"', line)
        if not m:
            continue
        fr = re.search(r"firerange=(-?\d+)", line)
        guns.append((m.group(1), 3 + (int(fr.group(1)) if fr else 0)))
    return guns


def file_guns(path):
    """(name, absolute firerange) per gun in a mod file's weapons={...} block,
    or None when the file has no Throne-style gun list."""
    src = path.read_bytes().decode("utf-8", errors="replace")
    m = re.search(r"^weapons\s*=\s*\{(.*?)^\}", src, re.S | re.M)
    if not m or 'name="Solomon"' not in m.group(1):
        return None
    guns = []
    for line in m.group(1).splitlines():
        n = re.search(r'name="([^"]+)"', line)
        fr = re.search(r"firerange=(-?\d+)", line)
        if n and not line.lstrip().startswith("--"):
            guns.append((n.group(1), int(fr.group(1)) if fr else None))
    return guns


def main():
    L = lj.LuaRuntime(unpack_returned_tuples=True)
    loader = L.execute(STUB_LUA)
    expected = throne_guns()
    fails, checks = [], 0

    def check(cond, msg):
        nonlocal checks
        checks += 1
        if not cond:
            fails.append(msg)

    check(len(expected) == 9, f"throne.lua gun count {len(expected)} != 9")
    # Owner: paste the Throne list over EVERY similar gun list - sweep all mod
    # files (also ones the engine never loads, e.g. Collection's hook.lua).
    swept = 0
    for path in sorted(MODS.rglob("*.lua")):
        guns = file_guns(path)
        if guns is None:
            continue
        swept += 1
        check(guns == expected,
              f"{path.relative_to(MODS)}: static gun list {guns} != throne {expected}")
    check(swept >= len(MODES) + 1, f"sweep found only {swept} gun lists")
    print(f"  sweep: {swept} mod files carry a gun list")
    for name, (rel, kind) in MODES.items():
        path = MODS / rel
        src = path.read_bytes().decode("utf-8")
        res = loader(src, rel)
        env, calls, bank = res[0], res[1], res[2] if len(res) > 2 else None
        if env is None:
            fails.append(f"{name}: load error {calls}")
            continue
        weapons = env["weapons"]
        got = []
        for i in range(1, len(weapons) + 1):
            w = weapons[i]
            got.append((w["name"], w["firerange"]))
        check(got == expected, f"{name}: gun list {got} != throne {expected}")
        # initialize must not override the weapons sheet (static + runtime)
        live = [l for l in src.splitlines() if "newsrf" in l and "weapons" in l
                and not l.strip().startswith("--")]
        check(not live, f"{name}: live newsrf weapons line(s): {live}")
        try:
            env["initialize"]()
        except lj.LuaError as e:
            # Nightmare/Card Lab initialize() read unrelated engine state the
            # stubs can't fake; their gun list does not depend on it.
            if kind == "bank":
                fails.append(f"{name}: initialize() error {e}")
                continue
        bad = [c for c in calls["newsrf"].values() if c.startswith("weapons|")]
        check(not bad, f"{name}: still re-registers the weapons sheet: {bad}")
        lst = env["get_weapons_list"]()
        n = len(lst)
        check(n == 9, f"{name}: get_weapons_list offers {n} guns, expected 9")
        if kind == "bank":
            check(calls["savbnk"] >= 1, f"{name}: initialize() unlocked guns but never called savbnk()")
            check(any("newly_unlocked=8" in s for s in calls["log"].values()),
                  f"{name}: no 'newly_unlocked=8' log line: {list(calls['log'].values())}")
            if name == "Quartz Throne":
                # Quartz also gates ranks: get_max_rank() = bget(0,1)+1
                nr = len(env["ranks"])
                check(env["get_max_rank"]() == nr,
                      f"{name}: get_max_rank() {env['get_max_rank']()} != {nr} (all ranks)")
                check(any(f"ranks={nr} max_rank_was=1 now={nr}" in s for s in calls["log"].values()),
                      f"{name}: no rank-unlock log line")
            before = calls["savbnk"]
            env["initialize"]()  # second boot: nothing new to unlock
            check(any("newly_unlocked=0" in s for s in calls["log"].values()),
                  f"{name}: second initialize() should unlock 0")
            check(calls["savbnk"] == before, f"{name}: second initialize() flushed with nothing to save")
            env["mode"]["ranks_index"] = 0
            env["mode"]["weapons_index"] = 8
            env["save_preferences"]()
            check(calls["savbnk"] == before + 1, f"{name}: save_preferences() did not flush the bank")
            check(bank[4 * 128 + 1] == 8, f"{name}: weapon preference not stored at (1,4)")
        print(f"  {name:14s} guns={len(got)} offered={n} savbnk={calls['savbnk']}")

    if fails:
        print(f"mode gun check: {checks - len(fails)}/{checks} passed")
        for f in fails:
            print("  FAIL:", f)
        return 1
    print(f"mode gun check: {checks}/{checks} checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
