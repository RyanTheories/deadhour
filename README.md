# DEADHOUR

A top-down twin-stick shooter with bullet time. Neo-noir, rain-soaked city night, lone vigilante. Inspired by Max Payne 1–2.

## Play (Build 0 — proof of concept)

Open `index.html` in any modern browser. No build step, no dependencies.

### Controls

| Input | Action |
|---|---|
| WASD | Move |
| Mouse | Aim |
| LMB | Shoot |
| R | Reload |
| Space | Dive (directional lunge, harder to hit mid-air) |
| Q or RMB (hold) | Bullet time (~25% world speed, player keeps an edge) |
| Enter | Restart after win/lose |

### PoC scope

- One apartment lobby with pillars, crates, and cover objects
- 4 mobsters (advance + shoot AI)
- Bullet time with meter — refilled by kills and slowly over time
- Dive, magazine-based reload, 2 painkiller pickups (no health regen)
- Muzzle flashes, tracers, blood decals, rain, vignette
- Win: kill everyone. Lose: die → instant restart.

## Design

See the game design document in the repo history/issue tracker for the full vision, art direction, and iteration roadmap (Build 0 → Build 4).

## Godot prototype (third-person)

The project is moving to **Godot 4** for the third-person, early-2000s (Max Payne / FEAR / Deus Ex) direction.

First run: open the Godot **Project Manager** → **Import** → select `godot/project.godot` → **Import & Edit**, wait for the import to finish, then press **F5**. (Fresh-from-git projects always need this one-time import — the `.godot/` cache is not committed. If you see "Assets need to be imported first", you skipped this step.)

Tuned for low-end / integrated-GPU machines:
- GL Compatibility renderer, 640×360 internal resolution upscaled, CPU particles, simple meshes
- Third-person over-the-shoulder camera, mouse look (click to capture the mouse)
- Same controls as the Canvas PoC, plus: WASD move, mouse aim, LMB shoot, R reload, Space dive, Q/RMB bullet time, Enter restart
- Bullet time uses separate world (25%) and player (40%) timescales instead of `Engine.time_scale`, so the player keeps a deliberate edge
- Noir environment: near-black ambient, sodium streetlamp with shadows, cyan/orange neon spill, rain, fog

The original single-file Canvas PoC (`index.html`) stays in the repo root as the Build 0 reference.

## Tech

Single-file HTML5 Canvas + vanilla JavaScript. 60 fps loop with a global `timescale` that bullet time lerps. Iterate freely — everything is in `index.html`.
