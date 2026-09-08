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
		"res://characters/he/build_he_blockout.py",
		"res://enemies/hollow_herald/hollow_herald.tscn",
		"res://enemies/hollow_herald/hollow_herald.gd",
		"res://enemies/hollow_herald/herald_blockout.glb",
		"res://enemies/hollow_herald/build_herald_blockout.py",
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
		"res://core/area_gate.gd",
		"res://weapons/ashpike/ashpike.tscn",
		"res://weapons/ashpike/ashpike_pickup.tscn",
		"res://core/game.gd",
		"res://core/combat.gd",
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
	if not he_text.contains("he_blockout.glb"):
		failures.append("he.tscn must instance characters/he/he_blockout.glb under MeshRoot.")
	if not he_text.contains("CapsuleShape3D"):
		failures.append("HE capsule collision/hurtbox must remain.")
	if he_text.contains("CapsuleMesh"):
		failures.append("HE visual must not be a capsule mesh; instance the blockout GLB.")
	var glb := load("res://characters/he/he_blockout.glb") as PackedScene
	if glb == null:
		failures.append("he_blockout.glb did not import as a PackedScene.")
	else:
		var visual: Node = glb.instantiate()
		if visual.find_child("Hips", true, false) == null or visual.find_child("L_Fist", true, false) == null:
			failures.append("he_blockout.glb is missing pose joints (Hips / L_Fist).")
		visual.free()
	if load("res://ruins/fallen_castle/camp_kit.gd") == null:
		failures.append("camp_kit.gd failed to compile.")
	var castle_src := FileAccess.get_file_as_string("res://ruins/fallen_castle/fallen_castle.gd")
	if castle_src.contains("CSGBox") or castle_src.contains("CSGCylinder"):
		failures.append("Guard camp must not be CSG greybox.")
	var herald_text := FileAccess.get_file_as_string("res://enemies/hollow_herald/hollow_herald.tscn")
	if not herald_text.contains("herald_blockout.glb"):
		failures.append("hollow_herald.tscn must instance enemies/hollow_herald/herald_blockout.glb under MeshRoot.")
	if not herald_text.contains("CapsuleShape3D"):
		failures.append("Herald capsule collision/hurtbox must remain.")
	if herald_text.contains("CapsuleMesh"):
		failures.append("Herald visual must not be a capsule mesh; instance the blockout GLB.")
	if not herald_text.contains("radius = 0.48") or not herald_text.contains("height = 2.35"):
		failures.append("Herald body capsule must stay r=0.48 h=2.35.")
	var herald_script := FileAccess.get_file_as_string("res://enemies/hollow_herald/hollow_herald.gd")
	if not herald_script.contains("_place_and_arm(swipe_box, Combat.HERALD_SWIPE_DAMAGE, 2.4, 1.6, 2.2)"):
		failures.append("Herald swipe reach/width/knock must stay 2.4 / 1.6 / 2.2.")
	if not herald_script.contains("_place_and_arm(lunge_box, Combat.HERALD_LUNGE_DAMAGE, 1.4, 0.8, 2.6)"):
		failures.append("Herald lunge reach/width/knock must stay 1.4 / 0.8 / 2.6.")
	if not herald_script.contains("_time >= 1.15") or not herald_script.contains("_time >= 0.38"):
		failures.append("Herald swipe wind/active clocks must stay 1.15 / 0.38.")
	if not herald_script.contains("_time >= 1.25") or not herald_script.contains("_time >= 0.42"):
		failures.append("Herald lunge wind/active clocks must stay 1.25 / 0.42.")
	var herald_glb := load("res://enemies/hollow_herald/herald_blockout.glb") as PackedScene
	if herald_glb == null:
		failures.append("herald_blockout.glb did not import as a PackedScene.")
	else:
		var herald_visual: Node = herald_glb.instantiate()
		if herald_visual.find_child("Hips", true, false) == null or herald_visual.find_child("R_UpperArm", true, false) == null:
			failures.append("herald_blockout.glb is missing pose joints (Hips / R_UpperArm).")
		if herald_visual.find_child("Crown", true, false) == null:
			failures.append("herald_blockout.glb is missing the Crown joint.")
		herald_visual.free()
	var under_text := FileAccess.get_file_as_string("res://ruins/line7_undercroft/line7_undercroft.gd")
	if not under_text.contains("line7_pocket") or not under_text.contains("door_gap"):
		failures.append("Undercroft does not link the service-tunnel door_gap.")
	var pocket_text := FileAccess.get_file_as_string("res://ruins/line7_pocket/line7_pocket.gd")
	for piece in ["door_gap", "tunnel_flood", "tube_cluster", "relief_wall", "maint_locker"]:
		if not pocket_text.contains(piece):
			failures.append("line7_pocket does not place named piece %s." % piece)
	if FileAccess.file_exists("res://ruins/line7_pocket/README.md") == false:
		failures.append("ruins/line7_pocket/README.md is missing.")
