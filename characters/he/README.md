# HE visual

`he.tscn` is still the playable capsule body (`CharacterBody3D` + `he.gd`). Do **not** swap that capsule for the mesh.

The civilian human mesh is a visual child only:

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

That writes `he_blockout.glb`: ~1.8 m civilian human (capsule limbs, faced head, wrapped fists) with named joints (`Hips`, `Torso`, `L_UpperArm`, …) so `he.gd` can pose jab snap, heavy commit, roll tuck, and sprint lean. Embedded cloth/skin textures are original. No Mixamo or ripped game mesh. The GLB has no clips yet; when it does, hook them on `MeshRoot/PosePlayer`.

The GLB is authored Godot-forward (−Z visor / chest / fists) so it matches `MeshRoot` yaw and hitbox forward without rotating the capsule.
