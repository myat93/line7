# HE visual

`he.tscn` is still the playable capsule body (`CharacterBody3D` + `he.gd`). Do **not** swap that capsule for the mesh.

The human blockout is a visual child only:

```
HE (CharacterBody3D)          collision / movement
├── CollisionShape3D          CapsuleShape3D  r=0.32 h=1.8
├── MeshRoot                  facing yaw only
│   ├── HEBlockout            instance of he_realistic.glb
│   ├── PosePlayer            AnimationPlayer hook (empty; poses use Skeleton3D)
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

`he.tscn` / `he.gd` instance `he_realistic.glb` under the existing `HEBlockout` MeshRoot node. Combat, capsule `r=0.32 h=1.8`, and locked fist reach are unchanged.

**Joints:** pose names live on the **Skeleton3D**. `MeshPoseRig` (`core/mesh_pose_rig.gd`) rebuilds the Skin IBM from rest (the 0.01 armature × 100× binds collapse in Godot), scales `Body` to 1.8 m, and drives jab / heavy / roll / sprint with `Skeleton3D.set_bone_pose_rotation`. Rest pose is A-pose; extras are local deltas on that bind.

Licenses: `ATTRIBUTION.md` + `LICENSE.rocketbox.md`. Not an Elden Ring / commercial rip.
