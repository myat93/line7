# Wooden guard camp

Separate exploration pocket. Linked off the service-tunnel far end — not part of `ruins/fallen_castle/`.

Cramped palisade ring (Elden Ring roadside-camp scale). Authored wood/cloth meshes — cylinder logs, sagging canvas, rope wraps. Kenney/Quaternius packs are CC0 but cartoon-lowpoly, so they were not dropped in.

**Enter:** walk the tunnel past the locker. Sealed **CAMP** door on the far wall. **E** to travel.

**Loop (~45–60s, no fight)**

1. `palisade_log` ring / `palisade_enter` — jagged rope-lashed gap
2. `tripod_central` — cook tripod orients the yard
3. Check A — `lean_to_a` (cloth) + `torch_post` (look / walk-through)
4. Check B — `guard_plank` (short jump or roll from the step). `lean_to_b` sits beside it. Slow on the plank is an exposed silhouette; cones later.
5. Optional `crate_loot` — **E** stub loot (linen wrap / watch scrap). Skip = faster exit.
6. `mist_drop` — far gap, look-only fog / forest silhouettes. No softlock.

Same path back. **E** at **TUNNEL**. Combat / shrine state is kept. No new enemy. No live guards.

Same HE controls: Shift sprint, Space jump, Ctrl roll.

Debug: **0** toggles this pocket. **9** still toggles the tunnel. **8** still toggles the castle.

**Mesh vs placeholder:** every prop is a `MeshInstance3D` (tapered `CylinderMesh`, board `BoxMesh`, `TorusMesh` rope, `SurfaceTool` cloth sail). No CSG. No imported Kenney GLB. Ground is a dirt/mud mesh slab, not a grey cube.
