# HE visual

`he.tscn` is still the playable capsule body (`CharacterBody3D` + `he.gd`). Do **not** swap that capsule for the mesh.

The human blockout is a visual child only:

```
HE (CharacterBody3D)          collision / movement
├── CollisionShape3D          CapsuleShape3D  r=0.32 h=1.8
├── MeshRoot                  facing yaw only
│   ├── HEBlockout            instance of he_blockout.glb
│   ├── PosePlayer            AnimationPlayer hook (empty; poses are procedural)
│   └── Ashpike
├── Hitboxes / Hurtbox        still capsule-driven, same locked reach
└── CameraPivot
```

There is no `he_body.gd`. The runtime capsule is authored in `he.tscn` and driven by `he.gd`. Hitboxes stay siblings of `MeshRoot`, not sockets on the GLB.

## Rebuild the GLB

```bash
python3 characters/he/build_he_blockout.py
```

That writes `he_blockout.glb`: ~1.8 m civilian boxes, oversized fists/forearms, named joints (`Hips`, `Torso`, `L_UpperArm`, …) so `he.gd` can pose jab snap, heavy commit, roll tuck, and sprint lean. The GLB has no clips yet; when it does, hook them on `MeshRoot/PosePlayer`.

The GLB is authored Godot-forward (−Z visor / chest / fists) so it matches `MeshRoot` yaw and hitbox forward without rotating the capsule.

## Realistic mesh (Andrew — MeshRoot swap)

Drop-in file: **`res://characters/he/he_realistic.glb`** (~1.8 m civilian, origin at feet, Y-up meters, Godot-forward).

`he.tscn` / `he.gd` still instance `he_blockout.glb`. Combat, capsule `r=0.32 h=1.8`, and locked fist reach are unchanged.

When you swap MeshRoot:

1. In `he.tscn`, point the `HEBlockout` instance at `he_realistic.glb` (keep the node name `HEBlockout`).
2. In `he.gd`, change `BLOCKOUT_SCENE` to the same path.
3. **Joint note:** pose names exist on the **Skeleton3D** (`Hips`, `Torso`, `Head`, `L_UpperArm`, `L_Forearm`, `L_Fist`, `R_*`, thighs/shins). Godot does **not** expose those as `Node3D` children, so `_cache_pose_nodes()` / `find_child` will miss them and jab/roll/sprint poses will no-op (A-pose rest). Drive `Skeleton3D.set_bone_pose_rotation` with the same names, or leave the blockout until clips exist on `MeshRoot/PosePlayer`.
4. Rest pose is A-pose, not hang-down. Euler offsets tuned for the box blockout will need a pass.

Licenses: `ATTRIBUTION.md` + `LICENSE.rocketbox.md`. Not an Elden Ring / commercial rip.
