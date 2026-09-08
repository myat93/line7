# Wooden guard camp

Separate exploration pocket off the service-tunnel far end. Not part of the fallen-castle ruins pocket (that pocket is also a camp on `main`).

Props come from Jake’s **`CampKit`** (`ruins/fallen_castle/camp_kit.gd`) — generated bark/cloth/mud/rope meshes. Kenney CC0 kits were evaluated on main and not used (cartoon town pieces). Same kit, named pieces here.

**Enter:** tunnel past the locker → sealed **CAMP** door → **E**.

**Loop (~45–60s, no fight)**

1. `palisade_log` / `palisade_ring` — jagged rope-lashed stakes, enter gap
2. `tripod_central` — cook tripod orients the yard
3. Check A — `lean_to_a` (cloth) + `torch_post`
4. Check B — `guard_plank` (short jump). `lean_to_b` beside it.
5. Optional `crate_loot` — **E** wrap / scrap. Skip = faster exit.
6. `mist_drop` — look-only fog / forest. No softlock.

**E** at **TUNNEL** returns to the service corridor far end. No new enemy. Combat / HE untouched.

Debug: **0** camp · **9** tunnel · **8** ruins camp.

**Mesh vs placeholder:** every prop is a CampKit `MeshInstance3D` (tapered logs, cloth planes, plank boxes, rope bands). No CSG. Ground is `Kit.mud_ground`.
