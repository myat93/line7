# Line 7

Godot **4.7.x** third-person combat slice. HE wakes in a flooded subway chapel, fights the Hollow Herald with bare fists, then takes the Ashpike from the angel-stone shrine — unequipped until it is bound.

HE uses the civilian box blockout (`characters/he/he_blockout.glb`) as a visual under the existing capsule body. Collision, hurtboxes, and locked fist reach stay on the capsule. This is one room, not an MMO.

## Import and play

1. Install [Godot 4.7.x](https://godotengine.org/download) (4.7.1 or later).
2. In the Project Manager choose **Import**.
3. Select this folder — the one that contains `project.godot`.
4. Open the project and press **F5** (Run). The main scene is `main.tscn`.

If Godot asks to generate import files, accept. `.godot/` is local cache and is not committed.

## The loop

**Spawn wake → mid-platform duel → shrine.**

- HE starts at the glowing wake with **no weapon**.
- Walk the flooded Line 7 undercroft to the mid-platform.
- The Hollow Herald telegraphs a **swipe**, then a **lunge**. Roll the tells; punish with short-reach fists.
- Continue to the angel stone. **E** takes Ashpike into inventory. It stays **unequipped** until you bind.

## Fallen castle ruins

A second pocket sits beside the undercroft — a **wooden guard camp** (not CSG boxes): uneven sharpened palisade logs, cloth lean-tos, crates/barrels, a lashed-pole tripod, muddy path, torch posts, and three watch posts (gatehouse / west / east / keep). Same HE controls; no extra enemy.

Props and bark/cloth/mud textures are original (`ruins/fallen_castle/camp_kit.gd`). See `ruins/fallen_castle/ATTRIBUTION.md`.

**How to enter**

1. F5 still starts in the Line 7 undercroft.
2. From the **spawn wake**, turn left (away from the Herald). An angel-stone arch is labeled **RUINS BREACH**.
3. Press **E** to step into `ruins/fallen_castle/`.
4. Explore, jump the rubble climb, search the crate in the keep.
5. Press **E** at the **LINE 7** arch in the courtyard to return (combat/shrine state is kept).
6. Optional debug: press **8** to toggle pockets.

F5 never opens the castle as the main scene — it is instanced from `main.tscn`.

## Controls

| Action | Input |
| --- | --- |
| Walk | WASD (weighty) |
| Sprint | **Shift** (hold with WASD — clearly faster than walk) |
| Jump | Space |
| Look | Mouse |
| Light jab | LMB or **J** |
| Heavy punch | RMB or **K** |
| Roll | Ctrl |
| Take Ashpike | **E** at the shrine |
| Bind Ashpike | **1** (after take) |
| Fists | **2** |
| Restart slice | **R** |
| Free / recapture mouse | Esc |

Stamina gating and whiff punish are **off** for playtest (`Combat.STAMINA_GATING` / `Combat.WHIFF_PUNISH`). Reach is still the locked jab **1.32** / heavy **1.52**. Fist arcs, roll tuck, and sprint lean are procedural poses on the blockout joints — see `characters/he/README.md`.

## Folders

```
characters/he/                 protagonist + blockout GLB (visual only)
enemies/hollow_herald/         slow telegraph duel
ruins/line7_undercroft/        flooded subway + angel stone
ruins/fallen_castle/           fallen keep exploration pocket
weapons/                       stance table
weapons/ashpike/               shrine pickup + held mesh
core/                          Game autoload, combat, HUD, hit/hurt
tools/                         headless slice check
main.tscn                      F5 run scene
```

## Headless check

From this folder, with Godot 4.7 on `PATH`:

```bash
godot --headless --path . --script res://tools/slice_check.gd
godot --headless --path . -- --slice-sim
```

Prints `LINE7_SLICE_OK` / `LINE7_PLAY_SIM_OK` when the layout, fist-first rules, shrine bind contract, and `main.tscn` wiring hold.

## Out of scope

No Unreal project, no multiplayer, no full MMO systems. Undercroft combat slice plus one ruins exploration pocket.
