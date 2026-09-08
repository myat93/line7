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
		"res://enemies/hollow_herald/hollow_herald.tscn",
		"res://enemies/hollow_herald/hollow_herald.gd",
		"res://ruins/line7_undercroft/line7_undercroft.tscn",
		"res://ruins/fallen_castle/fallen_castle.tscn",
		"res://ruins/fallen_castle/fallen_castle.gd",
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
	var pike := Combat.ashpike_light()
	if float(jab.reach) >= float(pike.reach):
		failures.append("Fist reach must stay shorter than Ashpike.")
	if int(jab.damage) <= 0 or int(Combat.fists_heavy().damage) <= int(jab.damage):
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
	var under_text := FileAccess.get_file_as_string("res://ruins/line7_undercroft/line7_undercroft.gd")
	if not under_text.contains("line7_pocket") or not under_text.contains("door_gap"):
		failures.append("Undercroft does not link the service-tunnel door_gap.")
	var pocket_text := FileAccess.get_file_as_string("res://ruins/line7_pocket/line7_pocket.gd")
	for piece in ["door_gap", "tunnel_flood", "tube_cluster", "relief_wall", "maint_locker"]:
		if not pocket_text.contains(piece):
			failures.append("line7_pocket does not place named piece %s." % piece)
	if FileAccess.file_exists("res://ruins/line7_pocket/README.md") == false:
		failures.append("ruins/line7_pocket/README.md is missing.")
