# Hollow Herald visual

`hollow_herald.tscn` is still the playable capsule body (`CharacterBody3D` + `hollow_herald.gd`). Do **not** swap that capsule for the mesh.

The humanoid blockout is a visual child only:

```
HollowHerald (CharacterBody3D)   collision / movement
├── CollisionShape3D             CapsuleShape3D  r=0.48 h=2.35
├── MeshRoot                     facing yaw only
│   ├── HeraldBlockout           instance of herald_blockout.glb
│   └── PosePlayer               AnimationPlayer hook (empty; poses are procedural)
├── Telegraph                    swipe (red) / lunge (gold) light — timings unchanged
├── Hitboxes / Hurtbox           still capsule-driven, same swipe/lunge reach
```

Hitboxes stay siblings of `MeshRoot`, not sockets on the GLB. Swipe **2.4** / lunge **1.4** and the wind-up clocks (swipe 1.15s, lunge 1.25s) are untouched.

## Rebuild the GLB

```bash
python3 enemies/hollow_herald/build_herald_blockout.py
```

That writes `herald_blockout.glb`: ~2.35 m transit-coat boxes, oversized gauntlets, named joints (`Hips`, `Torso`, `R_UpperArm`, `Crown`, …) so `hollow_herald.gd` can pose a loud swipe chamber and a crouch-coil lunge. The GLB has no clips yet; when it does, hook them on `MeshRoot/PosePlayer`.

The GLB is authored Godot-forward (−Z visor / lapels / fists) so it matches `MeshRoot` yaw and hitbox forward without rotating the capsule.
