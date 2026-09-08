# Line 7

Godot **4.7.x** third-person combat slice. HE wakes in a flooded subway chapel, fights the Hollow Herald with bare fists, then takes the Ashpike from the angel-stone shrine — unequipped until it is bound.

Placeholder capsules are intentional. This is one room, not an MMO.

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

## Controls

| Action | Input |
| --- | --- |
| Walk | WASD (weighty) |
| Sprint | Shift (drains stamina) |
| Look | Mouse |
| Light jab | LMB or **J** |
| Heavy punch | RMB or **K** |
| Roll | Space or Ctrl |
| Take Ashpike | **E** at the shrine |
| Bind Ashpike | **1** (after take) |
| Fists | **2** |
| Restart slice | **R** |
| Free / recapture mouse | Esc |

Whiffing a punch spends extra stamina and locks a longer recovery. Reach is short on purpose.

## Folders

```
characters/he/                 protagonist
enemies/hollow_herald/         slow telegraph duel
ruins/line7_undercroft/        flooded subway + angel stone
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

No Unreal project, no multiplayer, no full MMO systems. One-room first-playable slice only.
