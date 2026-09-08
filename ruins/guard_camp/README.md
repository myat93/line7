# Wooden guard camp

Separate exploration pocket off the service-tunnel far end. Not part of the fallen-castle ruins pocket (that pocket is also a camp on `main`).

Props come from Jake’s **`CampKit`** (`ruins/fallen_castle/camp_kit.gd`) — generated bark/cloth/mud/rope meshes. Named pieces live in this folder: `palisade_log` / `palisade_ring`, `lean_to_a` / `lean_to_b`, `guard_plank`, `tripod_central`, `crate_loot`, `torch_post`, `mist_drop`.

Kenney Survival Kit / Fantasy Town Kit are **not** on `main` and are not vendored here (cartoon town read vs the locked camp still). Same CampKit, photo-matched layout.

**Enter:** tunnel past the locker → sealed **CAMP** door → **E**.

**Loop (~45–60s, no fight)** — photo match: cramped ring, shelters on the left, torch at the mist gap.

1. `palisade_log` / `palisade_ring` — jagged rope-lashed stakes with horizontal rails, enter gap
2. `tripod_central` — thin-pole cook tripod in the mud
3. Check A / B — `lean_to_a` + `lean_to_b` (dark cloth) on the **left of the enter view**, `guard_plank` between them
4. Optional `crate_loot` — **E** wrap / scrap under the left clutter
5. `torch_post` at the **mist exit** (warm brazier)
6. `mist_drop` — purple forest fog beyond the ring. No softlock.

**E** at **TUNNEL** returns to the service corridor far end. No new enemy. Combat / HE untouched.

Debug: **0** camp · **9** tunnel · **8** ruins camp.

**Mesh vs placeholder:** named pieces instance PBR GLBs under `meshes/` (Poly Haven photogrammetry + Line 7 cloth/tripod). Palisade **collision boxes** stay CampKit so the ring does not change size. Ground is still `Kit.mud_ground`. See `ATTRIBUTION.md` / `meshes/README.md`. No CSG grey cubes. No Elden Ring rips.

Andrew: camp scenes already point at the new GLBs. Character MeshRoot is still the blockout — swap paths in the HE / Herald READMEs.
