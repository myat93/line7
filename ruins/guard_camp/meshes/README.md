# Guard camp realistic props

Godot 4.7 glTF/GLB, Y-up, meters. Tiny yard — instance these, do not scale the pocket.

| Piece | Path | Notes |
| --- | --- | --- |
| Palisade stake | `palisade_log_realistic.glb` | Origin at the butt. ~2.6 m × 0.25 m. Rotate Y per stake. |
| Lean-to A | `lean_to_a_realistic.glb` | Darker cloth. Origin on the mud under the shelter. |
| Lean-to B | `lean_to_b_realistic.glb` | Weathered cloth tint. |
| Tripod | `tripod_realistic.glb` | ~3.2 m apex. |
| Crate | `crate_realistic.glb` | Single crate, ~0.55 m. |
| Barrel | `barrel_realistic.glb` | ~0.62 m. |
| Crate loot | `crate_loot_realistic.glb` | Crate + barrel for the **E** search pile. |
| Torch post | `torch_post_realistic.glb` | Add your OmniLight in the scene (lantern is unlit mesh). |
| Mist / drop | `mist_drop_realistic.glb` | Timber gap + translucent fog. No collision in the GLB. |

`guard_camp/*.gd` pieces now instance these under the same node names. Capsule / interact spheres / palisade collision boxes are unchanged.

Licenses: `../ATTRIBUTION.md`.
