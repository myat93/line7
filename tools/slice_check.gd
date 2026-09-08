extends SceneTree

## Headless proof that the first-playable slice is wired: fists first, Herald pattern, shrine bind rules.

func _init() -> void:
	var failures: PackedStringArray = PackedStringArray()
	_check_layout(failures)
	_check_combat_rules(failures)
	_check_scenes(failures)
	if failures.size() > 0:
		for line in failures:
			push_error(line)
			print("FAIL: ", line)
		quit(1)
		return
	print("LINE7_SLICE_OK")
	quit(0)


func _check_layout(failures: PackedStringArray) -> void:
	var required := PackedStringArray([
		"res://project.godot",
		"res://main.tscn",
		"res://characters/he/he.tscn",
		"res://characters/he/he.gd",
		"res://characters/he/he_blockout.glb",
		"res://characters/he/he_realistic.glb",
		"res://characters/he/build_he_blockout.py",
		"res://enemies/hollow_herald/hollow_herald.tscn",
		"res://enemies/hollow_herald/hollow_herald.gd",
		"res://enemies/hollow_herald/hollow_herald_blockout.glb",
		"res://enemies/hollow_herald/hollow_herald_realistic.glb",
		"res://enemies/hollow_herald/build_hollow_herald_blockout.py",
		"res://ruins/guard_camp/meshes/palisade_log_realistic.glb",
		"res://ruins/guard_camp/meshes/lean_to_a_realistic.glb",
		"res://ruins/guard_camp/meshes/lean_to_b_realistic.glb",
		"res://ruins/guard_camp/meshes/tripod_realistic.glb",
		"res://ruins/guard_camp/meshes/crate_realistic.glb",
		"res://ruins/guard_camp/meshes/barrel_realistic.glb",
		"res://ruins/guard_camp/meshes/crate_loot_realistic.glb",
		"res://ruins/guard_camp/meshes/torch_post_realistic.glb",
		"res://ruins/guard_camp/meshes/mist_drop_realistic.glb",
		"res://ruins/line7_undercroft/line7_undercroft.tscn",
		"res://ruins/fallen_castle/fallen_castle.tscn",
		"res://ruins/fallen_castle/fallen_castle.gd",
		"res://ruins/fallen_castle/camp_kit.gd",
		"res://ruins/line7_pocket/line7_pocket.tscn",
		"res://ruins/line7_pocket/door_gap.tscn",
		"res://ruins/line7_pocket/tunnel_flood.tscn",
		"res://ruins/line7_pocket/tube_cluster.tscn",
		"res://ruins/line7_pocket/relief_wall.tscn",
		"res://ruins/line7_pocket/maint_locker.tscn",
		"res://ruins/guard_camp/guard_camp.tscn",
		"res://ruins/guard_camp/palisade_log.tscn",
		"res://ruins/guard_camp/palisade_enter.tscn",
		"res://ruins/guard_camp/tripod_central.tscn",
		"res://ruins/guard_camp/lean_to_a.tscn",
		"res://ruins/guard_camp/lean_to_b.tscn",
		"res://ruins/guard_camp/guard_plank.tscn",
		"res://ruins/guard_camp/crate_loot.tscn",
		"res://ruins/guard_camp/torch_post.tscn",
		"res://ruins/guard_camp/mist_drop.tscn",
		"res://core/area_gate.gd",
		"res://weapons/ashpike/ashpike.tscn",
		"res://weapons/ashpike/ashpike_pickup.tscn",
		"res://core/game.gd",
		"res://core/combat.gd",
		"res://core/mesh_pose_rig.gd",
		"res://tools/slice_check.gd",
	])
	for path in required:
		if not FileAccess.file_exists(path) and not ResourceLoader.exists(path):
			failures.append("Missing %s" % path)


func _check_combat_rules(failures: PackedStringArray) -> void:
	if WeaponProfile.is_starting_weapon() != WeaponProfile.FISTS:
		failures.append("HE must start on fists.")
	var jab := Combat.fists_light()
	var heavy := Combat.fists_heavy()
	var pike := Combat.ashpike_light()
	if not is_equal_approx(float(jab.reach), 1.32):
		failures.append("Locked jab reach is 1.32 — do not change for the mesh pass.")
	if not is_equal_approx(float(heavy.reach), 1.52):
		failures.append("Locked heavy reach is 1.52 — do not change for the mesh pass.")
	if float(jab.reach) >= float(pike.reach):
		failures.append("Fist reach must stay shorter than Ashpike.")
	if int(jab.damage) <= 0 or int(heavy.damage) <= int(jab.damage):
		failures.append("Heavy punch must out-damage the jab.")
	if Combat.attack_for(false, false).id != "jab":
		failures.append("Unbound stance is not fists.")
	if Combat.attack_for(true, true).id != "pike_thrust":
		failures.append("Bound Ashpike heavy is wrong.")
	if Combat.HERALD_SWIPE_DAMAGE <= 0 or Combat.HERALD_LUNGE_DAMAGE <= Combat.HERALD_SWIPE_DAMAGE:
		failures.append("Herald lunge must hit harder than the swipe.")
	if Combat.STAMINA_GATING:
		failures.append("Playtest default: STAMINA_GATING must be off.")
	if Combat.WHIFF_PUNISH:
		failures.append("Playtest default: WHIFF_PUNISH must be off.")
	if Combat.JUMP_VELOCITY <= 0.0:
		failures.append("Jump velocity must be set.")
	if Combat.SPRINT_SPEED < Combat.WALK_SPEED * 1.6:
		failures.append("Sprint must be clearly faster than walk.")
	var project := FileAccess.get_file_as_string("res://project.godot")
	if not project.contains("ctrl_pressed\":true"):
		failures.append("project.godot must bind Ctrl with ctrl_pressed=true (roll).")


func _check_scenes(failures: PackedStringArray) -> void:
	## Don't instantiate play scripts here — --script SceneTree has no Game autoload yet.
	for path in [
		"res://main.tscn",
		"res://characters/he/he.tscn",
		"res://enemies/hollow_herald/hollow_herald.tscn",
		"res://ruins/line7_undercroft/line7_undercroft.tscn",
		"res://ruins/fallen_castle/fallen_castle.tscn",
		"res://ruins/line7_pocket/line7_pocket.tscn",
		"res://ruins/guard_camp/guard_camp.tscn",
		"res://weapons/ashpike/ashpike.tscn",
		"res://weapons/ashpike/ashpike_pickup.tscn",
		"res://core/hud.tscn",
	]:
		if not ResourceLoader.exists(path):
			failures.append("Scene missing or unloadable: %s" % path)

	var main_text := FileAccess.get_file_as_string("res://main.tscn")
	for needle in ["Line7Undercroft", "HE", "HollowHerald", "HUD"]:
		if not main_text.contains(needle):
			failures.append("main.tscn does not reference %s." % needle)
	var he_text := FileAccess.get_file_as_string("res://characters/he/he.tscn")
	if not he_text.contains("Ashpike"):
		failures.append("HE is missing the hidden Ashpike visual.")
	if not he_text.contains("he_realistic.glb"):
		failures.append("he.tscn must instance characters/he/he_realistic.glb under MeshRoot.")
	if he_text.contains("he_blockout.glb"):
		failures.append("he.tscn must not instance the box blockout as the live MeshRoot.")
	if not he_text.contains("CapsuleShape3D"):
		failures.append("HE capsule collision/hurtbox must remain.")
	if he_text.contains("CapsuleMesh"):
		failures.append("HE visual must not be a capsule mesh; instance the realistic GLB.")
	var he_script := FileAccess.get_file_as_string("res://characters/he/he.gd")
	if not he_script.contains("res://characters/he/he_realistic.glb"):
		failures.append("he.gd BLOCKOUT_SCENE must preload he_realistic.glb.")
	if not he_script.contains("prepare_realistic"):
		failures.append("he.gd must call MeshPoseRig.prepare_realistic so the Rocketbox body is visible.")
	var glb := load("res://characters/he/he_realistic.glb") as PackedScene
	if glb == null:
		failures.append("he_realistic.glb did not import as a PackedScene.")
	else:
		var visual: Node = glb.instantiate()
		if not _has_named_bones(visual, PackedStringArray(["Hips", "L_Fist"])):
			failures.append("he_realistic.glb is missing Skeleton3D pose bones (Hips / L_Fist).")
		if visual.find_child("Body", true, false) == null:
			failures.append("he_realistic.glb is missing the Rocketbox Body mesh.")
		visual.free()
	if load("res://ruins/fallen_castle/camp_kit.gd") == null:
		failures.append("camp_kit.gd failed to compile.")
	var castle_src := FileAccess.get_file_as_string("res://ruins/fallen_castle/fallen_castle.gd")
	if castle_src.contains("CSGBox") or castle_src.contains("CSGCylinder"):
		failures.append("Guard camp must not be CSG greybox.")
	var herald_text := FileAccess.get_file_as_string("res://enemies/hollow_herald/hollow_herald.tscn")
	if not herald_text.contains("hollow_herald_realistic.glb"):
		failures.append("hollow_herald.tscn must instance enemies/hollow_herald/hollow_herald_realistic.glb under MeshRoot.")
	if herald_text.contains("hollow_herald_blockout.glb"):
		failures.append("hollow_herald.tscn must not instance the box blockout as the live MeshRoot.")
	if herald_text.contains("res://enemies/hollow_herald/herald_blockout.glb"):
		failures.append("hollow_herald.tscn must not instance the temp herald_blockout.glb.")
	if not herald_text.contains("CapsuleShape3D"):
		failures.append("Herald capsule collision/hurtbox must remain.")
	if herald_text.contains("CapsuleMesh"):
		failures.append("Herald visual must not be a capsule mesh; instance the realistic GLB.")
	if not herald_text.contains("radius = 0.48") or not herald_text.contains("height = 2.35"):
		failures.append("Herald body capsule must stay r=0.48 h=2.35.")
	var herald_script := FileAccess.get_file_as_string("res://enemies/hollow_herald/hollow_herald.gd")
	if not herald_script.contains("res://enemies/hollow_herald/hollow_herald_realistic.glb"):
		failures.append("hollow_herald.gd BLOCKOUT_SCENE must preload hollow_herald_realistic.glb.")
	if herald_script.contains("res://enemies/hollow_herald/herald_blockout.glb"):
		failures.append("hollow_herald.gd must not preload the temp herald_blockout.glb.")
	if not herald_script.contains("_place_and_arm(swipe_box, Combat.HERALD_SWIPE_DAMAGE, 2.4, 1.6, 2.2)"):
		failures.append("Herald swipe reach/width/knock must stay 2.4 / 1.6 / 2.2.")
	if not herald_script.contains("_place_and_arm(lunge_box, Combat.HERALD_LUNGE_DAMAGE, 1.4, 0.8, 2.6)"):
		failures.append("Herald lunge reach/width/knock must stay 1.4 / 0.8 / 2.6.")
	if not herald_script.contains("_time >= 1.15") or not herald_script.contains("_time >= 0.38"):
		failures.append("Herald swipe wind/active clocks must stay 1.15 / 0.38.")
	if not herald_script.contains("_time >= 1.25") or not herald_script.contains("_time >= 0.42"):
		failures.append("Herald lunge wind/active clocks must stay 1.25 / 0.42.")
	if herald_script.contains("body.visible = false"):
		failures.append("Herald Rocketbox Body must stay visible (IBM follow-up, do not hide).")
	if not herald_script.contains("_apply_realistic_meters"):
		failures.append("Herald must keep _apply_realistic_meters so coat/crown stay meter-scaled.")
	var pose_rig := FileAccess.get_file_as_string("res://core/mesh_pose_rig.gd")
	if not pose_rig.contains("set_bone_pose_rotation") or not pose_rig.contains("_unscale_cm_armature"):
		failures.append("MeshPoseRig must unscale the 0.01 armature and pose via set_bone_pose_rotation.")
	if not pose_rig.contains("_align_godot_forward") or not pose_rig.contains("aim_along_y"):
		failures.append("MeshPoseRig must align Bip01 +Z to Godot −Z and aim punch bones in character space.")
	if not pose_rig.contains("swing_along_y"):
		failures.append("MeshPoseRig must keep swing_along_y for signed along-bone extras.")
	var he_pose := FileAccess.get_file_as_string("res://characters/he/he.gd")
	if not he_pose.contains("_pose_stride_legs") or not he_pose.contains("Local Z is sagittal"):
		failures.append("he.gd walk/sprint must drive a sagittal (local Z) thigh/shin stride.")
	var official_glb := load("res://enemies/hollow_herald/hollow_herald_realistic.glb") as PackedScene
	if official_glb == null:
		failures.append("hollow_herald_realistic.glb did not import as a PackedScene.")
	else:
		var official_visual: Node = official_glb.instantiate()
		if not _has_named_bones(official_visual, PackedStringArray(["Hips", "R_UpperArm"])):
			failures.append("hollow_herald_realistic.glb is missing Skeleton3D pose bones (Hips / R_UpperArm).")
		if official_visual.find_child("Crown", true, false) == null:
			failures.append("hollow_herald_realistic.glb is missing the Crown mesh.")
		if official_visual.find_child("Body", true, false) == null:
			failures.append("hollow_herald_realistic.glb is missing the Rocketbox Body mesh.")
		official_visual.free()
	var under_text := FileAccess.get_file_as_string("res://ruins/line7_undercroft/line7_undercroft.gd")
	if not under_text.contains("line7_pocket") or not under_text.contains("door_gap"):
		failures.append("Undercroft does not link the service-tunnel door_gap.")
	var pocket_text := FileAccess.get_file_as_string("res://ruins/line7_pocket/line7_pocket.gd")
	for piece in ["door_gap", "tunnel_flood", "tube_cluster", "relief_wall", "maint_locker"]:
		if not pocket_text.contains(piece):
			failures.append("line7_pocket does not place named piece %s." % piece)
	if not pocket_text.contains("guard_camp") or not pocket_text.contains("CAMP"):
		failures.append("line7_pocket does not link the guard-camp door.")
	if FileAccess.file_exists("res://ruins/line7_pocket/README.md") == false:
		failures.append("ruins/line7_pocket/README.md is missing.")
	var camp_text := FileAccess.get_file_as_string("res://ruins/guard_camp/guard_camp.gd")
	for piece in ["palisade_log", "palisade_ring", "lean_to_a", "lean_to_b", "guard_plank", "tripod_central", "crate_loot", "torch_post", "mist_drop"]:
		if not camp_text.contains(piece):
			failures.append("guard_camp does not place named piece %s." % piece)
	if FileAccess.file_exists("res://ruins/guard_camp/README.md") == false:
		failures.append("ruins/guard_camp/README.md is missing.")
	for camp_mesh in [
		"palisade_log_realistic.glb",
		"lean_to_a_realistic.glb",
		"lean_to_b_realistic.glb",
		"tripod_realistic.glb",
		"crate_realistic.glb",
		"crate_loot_realistic.glb",
		"barrel_realistic.glb",
		"torch_post_realistic.glb",
		"mist_drop_realistic.glb",
	]:
		var found_mesh := false
		for script_name in ["guard_camp.gd", "palisade_log.gd", "palisade_enter.gd", "lean_to_a.gd", "lean_to_b.gd", "tripod_central.gd", "crate_loot.gd", "guard_plank.gd", "torch_post.gd", "mist_drop.gd"]:
			var script_text := FileAccess.get_file_as_string("res://ruins/guard_camp/%s" % script_name)
			if script_text.contains(camp_mesh):
				found_mesh = true
				break
		if not found_mesh:
			failures.append("guard camp scripts must instance meshes/%s." % camp_mesh)
	var combat_text := FileAccess.get_file_as_string("res://core/combat.gd")
	if not combat_text.contains("\"reach\": 1.32") or not combat_text.contains("\"reach\": 2.35"):
		failures.append("Combat reach numbers must stay 1.32 (jab) / 2.35 (pike).")


func _first_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for child in node.get_children():
		var found := _first_skeleton(child)
		if found:
			return found
	return null


func _has_named_bones(root: Node, names: PackedStringArray) -> bool:
	var skel := _first_skeleton(root)
	if skel == null:
		return false
	for bone_name in names:
		if skel.find_bone(bone_name) < 0:
			return false
	return true
