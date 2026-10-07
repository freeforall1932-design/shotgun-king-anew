# Patch Documentation: Python Save Tools
**Target Files:** `tools/save_codec.py`, `tools/make_100pct_save.py`  

---

## 1. Syntax Verification in save_codec.py --pack (SEC-06)
Prevents packing corrupted PUNKCAKE syntax into `.sav` containers.

```diff
--- a/tools/save_codec.py
+++ b/tools/save_codec.py
@@ -236,3 +236,8 @@
     out = flags[flags.index("--pack") + 1]
     raw_text = open(path, "r", encoding="utf-8").read()
+    try:
+        parse(raw_text)
+    except Exception as e:
+        sys.exit(f"ERROR: Cannot pack '{path}' — invalid PUNKCAKE syntax: {e}")
     open(out, "wb").write(encode_text(raw_text))
-    print(f"packed -> {out}")
+    print(f"packed (validated) -> {out}")
```

---

## 2. Safe Endless Mode Schema Handling in make_100pct_save.py (SEC-07)

```diff
--- a/tools/make_100pct_save.py
+++ b/tools/make_100pct_save.py
@@ -160,2 +160,14 @@
-cur_endless = int(prog.get("endless", ("n", "0"))[1] or 0)
-prog["endless"] = n(max(ENDLESS_FLOOR, cur_endless))
+endless_val = prog.get("endless")
+cur_endless = 0
+if isinstance(endless_val, tuple) and len(endless_val) > 1:
+    try: cur_endless = int(endless_val[1] or 0)
+    except ValueError: cur_endless = 0
+elif isinstance(endless_val, dict):
+    lvl = endless_val.get("lvl") or endless_val.get("floor") or ("n", "0")
+    if isinstance(lvl, tuple) and len(lvl) > 1:
+        try: cur_endless = int(lvl[1] or 0)
+        except ValueError: cur_endless = 0
+    endless_val["lvl"] = n(max(ENDLESS_FLOOR, cur_endless))
+if not isinstance(endless_val, dict):
+    prog["endless"] = n(max(ENDLESS_FLOOR, cur_endless))
```
