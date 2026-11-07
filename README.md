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

## Tech

Single-file HTML5 Canvas + vanilla JavaScript. 60 fps loop with a global `timescale` that bullet time lerps. Iterate freely — everything is in `index.html`.
