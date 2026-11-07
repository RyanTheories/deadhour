# DEADHOUR — Game Design Document

**Genre:** Top-down shooter (twin-stick style) with bullet time
**Mood:** Neo-noir, rain-soaked city night, lone vigilante
**Inspiration:** Max Payne 1–2 (2001–2003) — bullet-time dives, gritty urban setting, hard-boiled tone
**Scope strategy:** Minimal proof-of-concept first → iterate

## 1. Vision

A fast, brutal top-down shooter where one man tears through the criminal underworld of a rain-drenched city at night. The core fantasy is bullet time: the world slows to a crawl, muzzle flashes carve cones of light through the dark, and diving through a doorway while dual-wielding two .45s feels like directing your own noir action movie.

**One-sentence pitch:** John Woo gunplay meets a graphic-novel city at midnight — you are the last thing the underworld sees tonight.

### Design pillars

- **Bullet time is the game.** Every encounter should be solvable — and look spectacular — in slow motion.
- **The city is a character.** Wet asphalt, neon bleed, single hard light sources, long shadows.
- **Readable chaos.** Even at 20% speed, enemy positions, bullets, and cover must be legible at a glance.
- **Pure gameplay.** No cutscenes, no story panels — atmosphere is conveyed by the environment and sound alone.

## 2. Core Mechanics

### 2.1 Movement

- Twin-stick control: WASD to move, mouse to aim, LMB to shoot.
- Sprint (hold Shift): faster, but disables shooting briefly after stopping.
- Dive (Space): a directional lunge. During the dive the player is low (harder to hit), still fully controllable in the air, and lands behind cover. This is the Max Payne signature move.

### 2.2 Bullet Time

- Hold Q (or RMB) to activate. World runs at ~25% speed; player moves/aims at ~40% — a deliberate edge.
- Drains a meter; refills by killing enemies (the "adrenaline" loop) and slowly over time.
- Visual feedback: desaturated blue-grey filter, vignette, faint audio pitch-drop, bullet trails become visible tracers.
- Sound design cue: heartbeat thump while active.

### 2.3 Combat

- Hitscan pistols/rifle at PoC; bullets rendered as fast visible tracers (reads better in slow-mo).
- Ammo is magazine-based; reload (R) leaves a vulnerable beat — pressure moment.
- Painkillers (health): scattered pickups on the map, exactly like Max Payne. Health does not regenerate.
- Enemies: seek cover, lean out to fire, flank in pairs. PoC needs only one enemy type (mobster with pistol).

### 2.4 Death & Failure

- Quick deaths, instant restart of the room ("one more try" loop).
- Kill-cam flourish on the final enemy of a wave (slow-mo body ragdoll).

## 3. Proof-of-Concept Scope (Build 0)

The goal of the PoC: **prove the feel, not the content.** Everything below is one self-contained playable scene.

| System | PoC version | Deferred (iterate later) |
|---|---|---|
| Player | Move, aim, shoot pistol, dive | Dual wield, weapons swap, sprint |
| Bullet time | Full mechanic (meter, timescale, filter) | — keep it, it's the core |
| Enemies | 3–4 mobsters, dumb AI (advance + shoot) | Cover use, flanking, multiple types |
| Level | One apartment lobby: cover crates, pillars, doorways | Multi-room, multiple levels |
| Health | Painkiller pickups ×2 | Inventory |
| Effects | Muzzle flash, tracers, blood decals, rain | Explosions, destructibles |
| UI | Bullet-time meter, health, ammo counter | Menus, settings, scoring |
| Audio | Placeholder gunshots + rain loop | Full soundtrack |
| Win/lose | Kill all → win screen; die → restart | Progression, saves |

**Suggested tech:** single-file HTML5 Canvas + JavaScript (fast to iterate in the browser, zero setup), 60 fps game loop with a global timescale variable that bullet time lerps. No frameworks needed at PoC; sprites can be generated from the concept-art prompts below and cropped into a simple spritesheet.

## 4. Art Direction

Translate the reference board's cinematic noir into a top-down view:

- **Palette:** near-black asphalt (#0d0f14), sodium-orange window light, cyan neon accents, pale muzzle-flash white. 90% of the screen stays dark; light is earned.
- **Lighting:** single-source dramatic lighting — one streetlamp, one doorway, one neon sign per area. Long, hard shadows. Wet ground = specular streaks under lights.
- **Weather:** constant rain + occasional lightning flash that briefly reveals the whole scene.
- **Characters:** dark silhouettes with pale faces/hands and a rim light; enemies get a subtle red tie/glow detail so they read instantly in the dark.
- **Readability rules:** player = light rim; enemies = red accent; painkillers = soft white glow; bullet-time meter = amber. Nothing else glows.
- **Rendering style:** painterly, graphic-novel textures (per the reference board), not photoreal. High contrast, low saturation.

## 5. Concept Art Prompts

Ready-to-paste prompts, matched to the reference board's style (painterly, dark, atmospheric). Use them with any image generator; for game sprites add "flat lighting from above, orthographic top-down view" to keep perspective consistent.

### 5.1 Key art / mood

- "Painterly noir illustration, lone gunman in a long coat standing on a rooftop ledge at night, overlooking a rain-soaked city of dark skyscrapers with scattered lit windows, seen from behind, single cold light source, heavy atmosphere, cinematic, dark desaturated palette with orange window glow"
- "Dark narrow city alley at night in painterly noir style, wet asphalt reflecting a single streetlamp, a parked car silhouette at the far end, steam from a vent, deep shadows, rain, cinematic graphic-novel art"
- "Top-down view of a city block at night, noir painterly style, rain hitting wet rooftops, neon signs bleeding color into puddles, almost monochrome blue-grey with one orange lit window, atmospheric, graphic novel"

### 5.2 Environment / tileset (top-down)

- "Top-down orthographic tileable texture, rain-soaked dark asphalt with faded road markings and puddles reflecting dim orange light, painterly noir style, seamless, high contrast, low saturation"
- "Top-down orthographic view of a grimy apartment lobby at night, checkerboard marble floor, overturned sofa for cover, wooden crates, a single ceiling lamp casting a hard cone of light, painterly noir graphic-novel style, dark and moody"
- "Top-down orthographic street corner at night, brick wall, fire escape shadow, one neon sign 'BAR' in cyan, dumpster, wet ground with specular streaks, noir painterly, low saturation"

### 5.3 Characters & objects (top-down sprites)

- "Top-down orthographic game sprite, lone vigilante in black leather coat holding two pistols, seen from directly above, pale rim light, subtle blue tint, painterly noir style, dark silhouette with light accents, isolated on black"
- "Top-down orthographic game sprite, mobster in dark suit with red tie, aiming a pistol, seen from directly above, rim light plus red accent for readability, painterly noir style, isolated on black"
- "Top-down orthographic game asset, white pill bottle glowing softly (painkiller pickup), painterly noir style, isolated on black"
- "Top-down orthographic set of props: wooden crate, trash can, overturned table as cover objects, painterly noir style, dark with hard rim shadows, isolated on black"

### 5.4 Effects & UI

- "Bullet-time effect reference: top-down scene desaturated to cold blue-grey, visible bullet tracers as thin streaks of light, motion blur, heavy vignette, noir cinematic style"
- "Muzzle flash sprite: bright white-orange flash cone with smoke, on pure black background, painterly graphic style, top-down"
- "Minimal noir game UI kit: amber bullet-time meter styled like a film gauge, vintage health bar like a bottle label, worn white serif typography, on dark textured panel"

## 6. Iteration Roadmap

- **Build 0 — PoC (§3):** one room, one enemy type, bullet time, dive. Target: "does the 30-second loop feel great?" → then iterate.
- **Build 1 — Juice:** hit-stop, screen shake, ragdolls, decals, rain splash particles, kill-cam on last enemy, audio pass.
- **Build 2 — AI & weapons:** cover-seeking enemies, flanking pairs; add dual-wield and a second weapon (sawed-off).
- **Build 3 — Level flow:** 3 connected rooms per level, painkiller scarcity balancing, difficulty curve.
- **Build 4 — Identity:** score/streak system ("stylish kills" refill bullet time faster), game title screen, options.

Working title **"DEADHOUR"** — a one-night rampage through the city. Alternatives: Rain Protocol, Last Call, Slaughter Rain.
