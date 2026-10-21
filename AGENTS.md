# Agent guidance for this repository

This file loads relevant local guidance; it does not replace project records or owner decisions.

## Authority and current project state

- The owner's latest explicit instructions govern intent. Current source and tests plus the relevant project records (`HANDOFF.md`, `WORKLIST.md`, `INSTALL.md`, and live-testing records) provide project context; prefer the latest dated evidence and verify mutable facts such as branch/HEAD against Git.
- The imported bundle under `tests/experiments/lua-mod-safety/upstream/` is historical evidence. Do not treat it as a current source snapshot or as proof of live-game behavior.
- For changes to the mod, inspect the real entrypoint `modded/sk-rework/script.lua`, relevant engine notes, and the current tests before editing. Do not replace the active Build 9 / Run 6 state with the older experiment snapshot.

## Local skill loading

For coding work, read `tests/experiments/lua-mod-safety/skills/universal-agent-context/SKILL.md` and follow its references, including the versioned guide and session protocol. Read project records before applying any generalized guidance.

For Lua game-mod changes, also read `tests/experiments/lua-mod-safety/skills/lua-game-modding/SKILL.md`. For UI design or behavior changes, read `tests/experiments/lua-mod-safety/skills/universal-agent-context/references/ui-behaviour-contract.md` before editing. Skip the Lua workload skill for unrelated stacks.

## Testing and safety boundaries

- Use the current repository's tests and tools. Report exactly which runtimes ran, which were skipped, and whether evidence is fake-engine or live-game. A model/harness pass does not establish shipped SUGAR or real-game behavior.
- The historical mutation runner restores tracked files with destructive Git commands. Run it only in a disposable clean clone with explicit paths; never point it at this working checkout.
- The imported Lua skill is experimental guidance, not a certified framework. Project facts and the owner's latest decisions outrank it.
