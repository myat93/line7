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

**Joints:** pose names live on the **Skeleton3D**. `MeshPoseRig` undoes the 0.01 armature so the authored 100× IBM skins `Body` at 1.8 m (do not replace binds with inverse(rest) — that explodes vertices). Bind-pose chest is Bip01 +X; the authored −90° Y leaves that on MeshRoot +Z, so the rig adds π (+90°) to match MeshRoot −Z / camera-relative WASD. Idle is a relaxed stand (arms down), not the authored A/T-pose. Jab / heavy fold the forearm and cap `aim_along_y` (a 90° upper-arm swing stretches the IBM sleeves — that is a pose/skin error, not a reach buff). Walk / sprint keep rest-relative local-Z thigh/shin extras every render tick (and on `frame_pre_draw`) while planar speed is above `LOCO_SPEED`; bind reset is skipped while locomoting so F5 cannot sample A-pose (thigh local X is MeshRoot forward, so Euler X abducts and reads as a planted F5 slide). Poses flush on the render tick. Hips-basis remaps explode the IBM skin.

Licenses: `ATTRIBUTION.md` + `LICENSE.rocketbox.md`. Not an Elden Ring / commercial rip.
