# Proof and Verification Methodology
**Repository:** https://github.com/freeforall1932-design/shotgun-king-anew  
**Scope:** Formal Verification, Proof of Errors, and Validation of Solutions  

---

## 1. How the Defects Were Found

Our audit employed a multi-layered discovery methodology combining:
1. **Engine Contract Audit:** Comparing every game engine call in `script.lua` against the decoded game source (`game/decoded/code.lua`, `code/mods.lua`, `code/gamepad.lua`, `code/menu.lua`).
2. **Abstract Syntax Tree (AST) & Lexical Analysis:** Examining variable lifecycles, undefined table lookups, and uninitialized closures in Lua and PowerShell.
3. **Execution Boundary Simulation:** Modeling external process exit codes, file handle locks on Windows, and container compression invariants.
4. **Historical Live Log Differential Analysis:** Correlating bug reports from live test runs 4, 5, and 6 against specific lines of code.

---

## 2. Proofs by Component

### 2.1 Proof of SEC-01 (Robocopy Exit Code Failure)
- **Assertion:** In modern PowerShell environments with `$ErrorActionPreference = "Stop"`, `build-dist.ps1` line 112 throws a fatal terminating error whenever files are copied.
- **Proof:**
  Robocopy documentation defines return codes as a bitmask where bit 0 indicates files copied successfully.
  In PowerShell 7.3+, `$PSNativeCommandUseErrorActionPreference = $true` is enabled by default.
  When an external application returns non-zero, PowerShell evaluates:
  `if (LASTEXITCODE != 0 and ErrorAction == "Stop") => throw NativeCommandError`
  Because robocopy returns 1 on a successful copy, a terminating exception is thrown at line 112, preventing all downstream steps (steps 2, 3, 4) from executing.
- **Verification of Solution:**
  Wrapping the invocation and clearing `$global:LASTEXITCODE = 0` when `$LASTEXITCODE -le 7` guarantees that exit codes 0..7 are treated as successes without contaminating step 4/4.

---

### 2.2 Proof of SEC-02 (Mod Menu Back Button Failure)
- **Assertion:** On a pristine game boot with mods enabled, `modlist_changed()` evaluates to `true`, permanently displaying "Save and Reboot" instead of "Back".
- **Proof:**
  In `script.lua` line ~515:
  `if (mod.active and true or false) ~= (mod.loaded and true or false) then return true end`
  In `game/decoded/code/mods.lua`, lines 670-715 where mods are loaded:
  `MODS[d[1]] = mod`
  Notice that `mod.loaded` is **never set**.
  Therefore:
  `mod.loaded = nil => (mod.loaded and true or false) = false`
  For `sk-rework`, which boots pre-enabled (`active = true`):
  `(mod.active and true or false) = true`
  `true ~= false => modlist_changed() = true`
  Thus, `back.id` is overwritten with `"reboot"` on the initial menu frame without any user interaction!
- **Verification of Solution:**
  Capturing `boot_modlist[key] = { active = mod.active, pos = i }` at load time ensures the comparison evaluates `mod.active == boot_modlist[key].active`, which correctly returns `false` until the user genuinely changes a toggle.

---

### 2.3 Proof of SEC-03 (King Coordinate Desync)
- **Assertion:** Mutating `hero.sq.px` in the `dodge_king` fallback alters the physical position of the board square object rather than moving the King.
- **Proof:**
  In `game/decoded/code.lua`:
  The board array is populated as:
  `board[y][x] = { px = x, py = y, piece = nil }`
  When the King occupies square (4, 7):
  `hero.sq points to board[7][4]`
  When `dodge_king` executes:
  `hero.sq.px, hero.sq.py = sq.px, sq.py`
  It modifies:
  `board[7][4].px = sq.px, board[7][4].py = sq.py`
  This mutates the internal coordinates of tile (4, 7) to (3, 6).
  However:
  1. `hero.sq` still references `board[7][4]`.
  2. `board[6][3].piece` remains nil.
  3. `board[7][4].piece` still points to hero.
  This desynchronizes the game's spatial grid: the King appears visually at (3, 6) because drawing uses `hero.sq.px`, but game logic checking `board[6][3]` treats the square as empty!
- **Verification of Solution:**
  Calling `goto_sq(hero, sq)` directly (the confirmed engine signature) correctly updates piece pointers without touching tile coordinates.

---

### 2.4 Proof of SEC-05 (Card Filter Out-of-Bounds Blank Screen)
- **Assertion:** Toggling the Dev Panel card filter on higher pages renders a blank list.
- **Proof:**
  Total cards = 186 => 24 pages (8 per page).
  Piece cards = 14 => 2 pages (8 per page).
  Suppose user is on page p = 4.
  When user clicks FILT:ALL:
  `card_filter becomes "piece"`
  `card_page remains 4`
  In `draw_card_page()`:
  `start_index = (4 - 1) * 8 + 1 = 25`
  `end_index = 25 + 7 = 32`
  Since total piece cards is 14 < 25, the loop iterates over nil entries.
  Result: 0 buttons are drawn, stranding the player on an empty screen.
- **Verification of Solution:**
  Assigning `card_page = 1` inside the `filt` toggle handler guarantees `start_index = 1`, displaying the first 8 matching pieces immediately.
