# Hollow Herald visual

`hollow_herald.tscn` is still the playable capsule body (`CharacterBody3D` + `hollow_herald.gd`). Do **not** swap that capsule for the mesh.

The humanoid blockout is a visual child only:

```
HollowHerald (CharacterBody3D)   collision / movement
├── CollisionShape3D             CapsuleShape3D  r=0.48 h=2.35
├── MeshRoot                     facing yaw only
│   ├── HeraldBlockout           instance of herald_blockout.glb  (temp, still wired)
│   └── PosePlayer               AnimationPlayer hook (empty; poses are procedural)
├── Telegraph                    swipe (red) / lunge (gold) light — timings unchanged
├── Hitboxes / Hurtbox           still capsule-driven, same swipe/lunge reach
```

Hitboxes stay siblings of `MeshRoot`, not sockets on the GLB. Swipe **2.4** / lunge **1.4** and the wind-up clocks (swipe 1.15s, lunge 1.25s) are untouched.

## Official Jake blockout (not wired yet)

`hollow_herald_blockout.glb` is the official ~2.05 m lesser-demon transit-coat blockout (origin at the feet, Y-up meters, clawed wind-up arms). It uses the same pose joints as the temp (`Hips`, `Torso`, `R_UpperArm`, `Crown`, …) so Andrew can swap the preload without pose rework.

**Andrew:** point `hollow_herald.tscn` and the `BLOCKOUT_SCENE` preload in `hollow_herald.gd` at `res://enemies/hollow_herald/hollow_herald_blockout.glb`. Leave swipe/lunge clocks, reach, and the capsule alone. The instance node can stay named `HeraldBlockout`.

## Rebuild the GLBs

```bash
python3 enemies/hollow_herald/build_herald_blockout.py
python3 enemies/hollow_herald/build_hollow_herald_blockout.py
```

The first writes the temp `herald_blockout.glb` (~2.35 m, still instanced). The second writes the official `hollow_herald_blockout.glb`. Both are Godot-forward (−Z visor / lapels / fists) so they match `MeshRoot` yaw and hitbox forward without rotating the capsule. Neither GLB has clips yet; when they do, hook them on `MeshRoot/PosePlayer`.
