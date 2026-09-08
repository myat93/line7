# Hollow Herald visual

`hollow_herald.tscn` is still the playable capsule body (`CharacterBody3D` + `hollow_herald.gd`). Do **not** swap that capsule for the mesh.

The official humanoid blockout is a visual child only:

```
HollowHerald (CharacterBody3D)   collision / movement
├── CollisionShape3D             CapsuleShape3D  r=0.48 h=2.35
├── MeshRoot                     facing yaw only
│   ├── HeraldBlockout           instance of hollow_herald_realistic.glb
│   └── PosePlayer               AnimationPlayer hook (empty; poses use Skeleton3D)
├── Telegraph                    swipe (red) / lunge (gold) light — timings unchanged
├── Hitboxes / Hurtbox           still capsule-driven, same swipe/lunge reach
```

Hitboxes stay siblings of `MeshRoot`, not sockets on the GLB. Swipe **2.4** / lunge **1.4** and the wind-up clocks (swipe 1.15s, lunge 1.25s) are untouched.

## Official blockout

`hollow_herald_blockout.glb` is the official ~2.05 m lesser-demon transit-coat blockout (origin at the feet, Y-up meters, clawed wind-up arms). Pose joints (`Hips`, `Torso`, `R_UpperArm`, `Crown`, …) stay the names `hollow_herald.gd` already looks up. The instance node stays named `HeraldBlockout`.

## Rebuild the GLB

```bash
python3 enemies/hollow_herald/build_hollow_herald_blockout.py
```

That writes `hollow_herald_blockout.glb`. It is Godot-forward (−Z visor / lapels / fists) so it matches `MeshRoot` yaw and hitbox forward without rotating the capsule. The GLB has no clips yet; when it does, hook them on `MeshRoot/PosePlayer`.

## Realistic mesh (Andrew — MeshRoot swap)

Drop-in file: **`res://enemies/hollow_herald/hollow_herald_realistic.glb`** (~2.05 m, origin at feet, Y-up meters, Godot-forward).

`hollow_herald.tscn` / `BLOCKOUT_SCENE` instance `hollow_herald_realistic.glb` under the existing `HeraldBlockout` MeshRoot node. Capsule `r=0.48 h=2.35`, swipe **2.4** / lunge **1.4**, and wind-up clocks (1.15s / 1.25s) are untouched.

**Joints:** swipe/lunge pose names are on the **Skeleton3D**. `MeshPoseRig` undoes the 0.01 armature so coat/crown stay meters, rebuilds IBM from rest so the Rocketbox `Body` is visible at 2.05 m, and drives swipe wind-up / lunge with `set_bone_pose_rotation`. **`Crown`** is still a `MeshInstance3D` (HP pulse). **`TransitCoat`** / `CoatLapels` ride the armature root (not skinned). Rest pose is A-pose.

Licenses: `ATTRIBUTION.md` + `LICENSE.rocketbox.md`. Coat/crown maps are Poly Haven CC0. Not an Elden Ring / commercial rip.
