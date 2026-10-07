# Patch Documentation: modded/sk-rework/script.lua
**Target File:** `modded/sk-rework/script.lua`  
**Build Version:** Build 9.1 (Audit Patch Release)  

---

## Summary of Changes
1. **Boot Modlist Snapshot (Fixes SEC-02):** Captures true initial mod active states and indices at boot time, eliminating the dependency on non-existent `mod.loaded`. Restores the "Back" button correctly.
2. **Spatial Pointer Fix (Fixes SEC-03):** Replaces destructive coordinate mutation with pointer-safe tile relocation: `goto_sq(hero, sq)` and safe pointer fallback.
3. **Pagination Reset (Fixes SEC-05):** Resets `card_page = 1` when `card_filter` toggles, preventing blank screens.
4. **Right-Click Ability Uncap (Fixes SEC-08):** Implements the owner's queued feature (§0.7.6) via an active `prepend("is_card_available")` hook.

---

## Unified Diff

```diff
--- a/modded/sk-rework/script.lua
+++ b/modded/sk-rework/script.lua
@@ -190,6 +190,17 @@
 local mod_index, mod = -1, nil
+-- SK-REWORK AUDIT FIX (SEC-02): Capture pristine boot-time mod state
+local boot_modlist = {}
 if type(MODLIST) == "table" then
     for i, v in ipairs(MODLIST) do
         if i > 40 then break end
+        if type(v) == "table" then
+            local key = v.title or v.folder or i
+            boot_modlist[key] = { active = v.active and true or false, pos = i }
+        end
         if type(v) == "table" and v.title == "SK Rework" then
             mod_index, mod = i, v
             break
         end
     end
 end
@@ -230,16 +241,17 @@
 local function dodge_king(reason)
     if not (hero and hero.sq) then return false end
     local sq, how = choose_spawn_square()
     if sq == nil then return false end
     local bx, by = sv(hero.sq.px), sv(hero.sq.py)
     local ok = false
     if type(goto_sq) == "function" then
-        ecall("goto_sq_sq", goto_sq, hero.sq, sq) -- GUESS #1
-        if hero.sq and hero.sq.px == sq.px and hero.sq.py == sq.py then ok = true end
-        if not ok then
-            ecall("goto_sq_hero", goto_sq, hero, sq) -- GUESS #2
-            if hero.sq and hero.sq.px == sq.px and hero.sq.py == sq.py then ok = true end
-        end
+        -- SK-REWORK AUDIT FIX (SEC-03): Confirmed signature from game/decoded/code.lua: goto_sq(piece, target_sq)
+        ecall("goto_sq", goto_sq, hero, sq)
+        if hero.sq == sq or (hero.sq and hero.sq.px == sq.px and hero.sq.py == sq.py) then
+            ok = true
+        end
     end
-    if not ok and hero.sq then
-        hero.sq.px, hero.sq.py = sq.px, sq.py
-        ok = hero.sq.px == sq.px
+    if not ok and hero and sq then
+        if hero.sq then hero.sq.piece = nil end
+        hero.sq = sq
+        sq.piece = hero
+        ok = true
     end
     log("SKUI|dodge|from=" .. bx .. "," .. by .. "|to=" .. sv(sq.px) .. "," .. sv(sq.py) .. "|route=" .. sv(how) .. "|moved=" .. sv(ok) .. "|reason=" .. sv(reason))
     return ok
 end
@@ -430,6 +442,7 @@
     elseif id == "filt" then
         card_filter = (card_filter == "all") and "piece" or "all"
+        card_page = 1 -- SK-REWORK AUDIT FIX (SEC-05): Reset page index on filter change
         log("SKUI|panel|action=card_filter|to=" .. sv(card_filter))
     end
 end
@@ -510,9 +523,13 @@
 local function modlist_changed()
     if type(MODLIST) ~= "table" then return false end
     for i, mod in ipairs(MODLIST) do
         if type(mod) == "table" then
-            if mod.num ~= nil and mod.num ~= i then return true end
-            if (mod.active and true or false) ~= (mod.loaded and true or false) then return true end
+            -- SK-REWORK AUDIT FIX (SEC-02): Compare against pristine boot snapshot
+            local key = mod.title or mod.folder or i
+            local snap = boot_modlist[key]
+            if snap then
+                if (mod.active and true or false) ~= snap.active then return true end
+                if i ~= snap.pos then return true end
+            end
         end
     end
     return false
 end
@@ -740,6 +757,16 @@
+-- SK-REWORK AUDIT FIX (SEC-08): Right-click ability cap removal (§0.7.6)
+local uncap_abilities = true
+if type(prepend) == "function" then
+    prepend("is_card_available", function(ca)
+        if uncap_abilities and type(ca) == "table" and ca.special ~= nil then
+            -- Allow multiple special ability cards in offers
+            return true
+        end
+    end, "sk-rework:uncap-abilities")
+end
+
 if known["is_card_available"] then
     hookf("is_card_available", function(ca, ...)
```
