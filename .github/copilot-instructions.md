<!-- Copilot instructions for this kOS scripts workspace -->
# Quick orientation (20–50 lines)

This repository contains kOS scripts (Kerbal Space Program autopilot scripts). There is no external build system — scripts run inside KSP via the kOS mod. Place files in a ship's Scripts folder or use the provided `boot/` helpers to run them from the in-game terminal.

Key files to scan first
- `LAUNCH.ks` — main high-level launch procedures (doToOrbitLaunch, doCountDown, doBoostUp, doOrbitalInsertion).
- `DISPLAY.ks` — terminal display library. Call `configureDisplay(headerList, dataTable)`; example usage in `CODE_TEST.ks`.
- `CODE_TEST.ks` and `boot/code_test_boot.ks` — minimal examples showing how to wire the scripts together at runtime.
- `boot/boot_template.ks` — starter template for boot scripts; call `main_()` to start.
- `MATH.ks`, `SHIP.ks`, `ORBITS.ks` — utility libraries. Note: `ORBITS.ks` contains transcribed/untested functions (TODOs).
- `VECTOR.ks` — currently empty; do not assume vector helpers exist unless added.

High-level architecture and flow
- Scripts are organized as libraries of GLOBAL functions and helper locals. Files import each other using RUNONCEPATH or runOncePath("0:/FILE.ks"). Typical boot sequence loads utility libs, then high-level modules (LAUNCH, DISPLAY).
- `LAUNCH.ks` orchestrates the mission: it sets globals like `launchApoapsis`, uses `WHEN ... THEN` monitors, and coordinates staging, pitch/roll programs, and maneuver node creation (`ADD NODE(...)`).
- `DISPLAY.ks` separates static layout (configure*) from dynamic updates (updateDisplay → updateHeaders/updateTable/updateLog). Use `configureDisplay` once, then call `updateDisplay` repeatedly.

Project-specific conventions
- Exported functions use the `GLOBAL function ...` pattern so other scripts can call them after RUNONCEPATH.
- Files are capitalized and named after the domain (e.g., `LAUNCH.ks`, `MATH.ks`).
- Use `parameter` for function args and `local`/`set` for variables. Globals are stored in GLOBAL variables. Example: `GLOBAL function doToOrbitLaunch { parameter targetAzimuth is 90. ... }`
- Use kOS primitives: `lock steering`, `lock throttle`, `stage.`, `ADD NODE`, `VECDRAW`, `PRESERVE`, `WHEN ... THEN`, `wait`, `print at(x,y)`, `SET TERMINAL:WIDTH TO ...`.

Notable patterns and gotchas for an agent
- Import pattern: scripts expect explicit runOncePath/RUNONCEPATH calls — emulate the same order when modifying or running code. Example from `DISPLAY.ks`: `runOncePath("0:/STRING.ks"). runOncePath("0:/LAUNCH.ks").`
- UI layout: `DISPLAY.ks` computes terminal size using `nColumns`, `colWidth`, `sMargin` and calls `SET TERMINAL:WIDTH/HEIGHT`. Changing these affects the entire terminal layout.
- Monitoring idioms: `LAUNCH.ks` relies on `WHEN AutoPilotOn then { monitorFlight(). updateTelemetry(). updateDisplay(). PRESERVE. }` — keep PRESERVE and WHEN semantics intact when refactoring.
- Untested/transcribed code: `ORBITS.ks` contains blocks copied from external sources and marked TODO; treat those as unverified: do not automatically assume correctness.
- Missing implementations: `VECTOR.ks` is empty. If you need vector helpers, add them and export via `GLOBAL`.

How to run / test (in-game)
1. In KSP (with kOS mod), open the kOS terminal for your ship.
2. If using boot scripts, copy `boot/code_test_boot.ks` into the ship's Scripts folder and run it (it follows `boot_template.ks`).
3. Or, from terminal: run `RUNONCEPATH("0:/CODE_TEST.ks").` — `CODE_TEST.ks` demonstrates `configureDisplay(headerList, dataTable)` and launching functions.
4. For debugging the display, set `debug` to `true` in `DISPLAY.ks:configureDisplay` to set larger terminal dimensions.

Integration & external dependencies
- No external package manager. The runtime dependency is the kOS mod inside KSP.
- `ORBITS.ks` references an external repo (orbit-nerd-scripts) in comments — treat as referenced code, not a package.

When editing or adding code
- Export reusable helpers as `GLOBAL function` so files loaded with RUNONCEPATH can see them.
- Preserve kOS control flow: `WHEN`/`PRESERVE`, locks, and `stage.` semantics are important for safe in-flight behavior.
- Add examples/tests by creating small boot scripts in `boot/` (see `boot/display_test.ks` and `boot/code_test_boot.ks`).

Files to review when changing behavior
- `DISPLAY.ks` — UI and terminal sizing.
- `LAUNCH.ks` — state machine for flight and staging.
- `SHIP.ks` — part/engine helpers (getPartsNamed, getStageTWR, etc.).
- `CODE_TEST.ks` and `boot/*` — runnable integration examples.

If something is unclear
- I focused only on patterns discoverable in the code (no external docs found). Tell me which runtime flows you want expanded (e.g., maneuver execution, staging safety) and I will extend these instructions with step-by-step in-game examples.

---
Path added: `.github/copilot-instructions.md`
