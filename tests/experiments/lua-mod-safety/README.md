# Lua mod-safety experiment and local guidance

This folder brings the relevant experiment material and skills into this repository so future work can be done here without relying on a separate drop-in or remote skill folder. Migrated on 2026-10-21 at the owner's request.

## Contents and provenance

- [`upstream/shotgun-king-anew/`](upstream/shotgun-king-anew/) is the complete eight-file payload unpacked from the root `shotgun-king-anew.zip`. Its files were verified against the byte-identical `shotgun-king-anew/` folder in `freeforall1932-design/dionysus` at commit `9b5e0e6a5a56ae407701650c728212dee7947f05`. The ZIP container was removed after migration and verification.
- [`skills/`](skills/) contains the complete relevant skill files copied from Dionysus commit `9b5e0e6a5a56ae407701650c728212dee7947f05`: `universal-agent-context` and its required references, plus `lua-game-modding`. The unrelated Qt/CMake skill was intentionally not imported. The universal guide's original provenance and SHA-256 are retained in `skills/universal-agent-context/PROVENANCE.md`.

No game binary, `data.sgr`, game assets, or duplicate mod source is included. The active Lua source remains [`modded/sk-rework/script.lua`](../../../modded/sk-rework/script.lua); project status and owner decisions remain in the root handoff, worklist, install instructions, and live-testing records.

## Evidence limits and current-tree distinction

The dated report in the upstream package targets historical project commit `4c4bf1bcc9e21c4b274736363e88e3f99065f157` and script SHA-256 `86b3e1a21c95aec3bc6f9d1ec847b54ae7eb78da406666124b10b8acf4eb2bb7`. At migration, the current script SHA-256 was `abd3e06f9d8eb6eb1cd87719b9cd1946526a7d2f8bb17b798a972cfd6f46eaca`; the smoke-test harness hash matches the historical report at `5597e88bb08a7dc89e98a41763eade7f6345a4284f11a9cdfa12513f50b6419a`. Therefore the archived results do **not** validate the current mod bytes.

The archive reports a 68/68 baseline in four fake-SUGAR/Lupa runtime-and-iterator variants and records zero of six obligations as verified. This is useful mutation-testing evidence, not proof of shipped SUGAR semantics, live-game behavior, or mod safety. Its iterator mutation also crashes the harness rather than producing a named failed assertion.

The current sandbox check during migration ran `python3 tools/mod_smoketest.py`: the parser self-test passed 49/49, but Lua checks were skipped because `lupa` is unavailable here; the command returned its documented skip status (2). Do not report that as a Lua pass. Repeat the current harness when the dev dependency is available, and keep live-game checks distinct from fake-engine results.

## Safe use of the historical runner

Read the upstream `README.md`, `MIGRATION.md`, and dated report before reproducing anything. `rea_mod_safety_experiment.py` calls `git checkout --` on the mod and smoke-test files at startup and after mutations; that can discard local edits. **Only run it against a disposable clean clone**, never this working checkout.

The archived reproduction guide's support path assumes a root-level `shotgun-king-anew/` folder. In this repository, if following that guide, set:

```sh
SUPPORT="$PROJECT/tests/experiments/lua-mod-safety/upstream/shotgun-king-anew"
```

Keep the project clone, Python/Lupa environment, Node/REA dependencies, and generated evidence outside this checkout. REA and Lupa are experiment/dev dependencies, not mod runtime dependencies. The optional `make-bundle.mjs` imports REA internal module paths; use the pinned dependency and its documented placement.

## Using the imported skills

The local [`AGENTS.md`](../../../AGENTS.md) loader makes these files discoverable to repository-reading agents. Load the universal process guidance first; load `lua-game-modding/SKILL.md` for Lua mod changes; read `universal-agent-context/references/ui-behaviour-contract.md` before UI behavior/design work. These are guidance, not executable gates. Current project evidence and the owner's latest explicit decisions outrank historical experiment notes and generic skill text.
