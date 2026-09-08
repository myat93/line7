extends Node

## Added at runtime when launched with `-- --slice-sim`. Uses the live Game autoload.

var _failures: PackedStringArray = PackedStringArray()


func _ready() -> void:
	get_tree().create_timer(0.45).timeout.connect(_run)


func _run() -> void:
	var he := Game.player as HE
	var herald := Game.herald as HollowHerald
	if he == null or herald == null:
		_fail("Player or Herald was not registered.")
		_finish()
		return
	if he.global_position.y < 0.4:
		_fail("HE spawned in the flood (y=%.2f)." % he.global_position.y)
	if absf(he.global_position.z) > 3.0:
		_fail("HE is not at the spawn wake.")
	if herald.global_position.z < 12.0:
		_fail("Herald is not on the mid-platform.")
	if Game.ashpike_taken or Game.ashpike_bound:
		_fail("Ashpike must start unowned and unbound.")
	if he.hp != Combat.PLAYER_MAX_HP:
		_fail("HE did not start at full HP.")
	if Combat.STAMINA_GATING or Combat.WHIFF_PUNISH:
		_fail("Playtest stamina gating / whiff punish must default off.")
	if Combat.SPRINT_SPEED < Combat.WALK_SPEED * 1.6:
		_fail("Sprint must be clearly faster than walk.")
	if he.target_move_speed(true) <= he.target_move_speed(false) + 1.5:
		_fail("HE sprint target speed does not exceed walk.")
	var sprint_shift_ok := false
	if InputMap.has_action("sprint"):
		for event in InputMap.action_get_events("sprint"):
			if event is InputEventKey and event.physical_keycode == KEY_SHIFT and event.shift_pressed:
				sprint_shift_ok = true
	if not sprint_shift_ok:
		_fail("Sprint binding must match a live Shift press (shift_pressed=true).")
	if not InputMap.has_action("jump"):
		_fail("jump action is missing.")
	else:
		var jump_is_space := false
		for event in InputMap.action_get_events("jump"):
			if event is InputEventKey and event.physical_keycode == KEY_SPACE:
				jump_is_space = true
		if not jump_is_space:
			_fail("Space must be jump.")
	if InputMap.has_action("roll"):
		for event in InputMap.action_get_events("roll"):
			if event is InputEventKey and event.physical_keycode == KEY_SPACE:
				_fail("Space must not roll.")
	var roll_ctrl_ok := false
	if InputMap.has_action("roll"):
		for event in InputMap.action_get_events("roll"):
			if event is InputEventKey and event.physical_keycode == KEY_CTRL and event.ctrl_pressed:
				roll_ctrl_ok = true
	if not roll_ctrl_ok:
		_fail("Roll binding must match a live Ctrl press (ctrl_pressed=true).")
	he.state = HE.State.FREE
	var ctrl := InputEventKey.new()
	ctrl.keycode = KEY_CTRL
	ctrl.physical_keycode = KEY_CTRL
	ctrl.ctrl_pressed = true
	ctrl.pressed = true
	if not he.event_starts_roll(ctrl):
		_fail("Ctrl key event is not recognized as roll.")
	Input.parse_input_event(ctrl)
	Input.flush_buffered_events()
	he._poll_roll_edge()
	if he.state != HE.State.ROLL:
		_fail("Ctrl did not start a roll.")
	var ctrl_up := InputEventKey.new()
	ctrl_up.keycode = KEY_CTRL
	ctrl_up.physical_keycode = KEY_CTRL
	ctrl_up.pressed = false
	Input.parse_input_event(ctrl_up)
	Input.flush_buffered_events()
	he.state = HE.State.FREE
	he._roll_held = false
	he.stamina = 0.0
	he._try_attack(false)
	if he.state != HE.State.ATTACK:
		_fail("Jab should not be stamina-gated.")
	he.state = HE.State.FREE
	he._try_jump()
	if he.velocity.y < Combat.JUMP_VELOCITY * 0.9:
		_fail("Jump did not apply upward velocity.")
	he._face_direction(Vector3(0.0, 0.0, 1.0), 1.0)
	if absf(angle_difference(he.mesh_root.rotation.y, PI)) > 0.25:
		_fail("HE does not face movement direction (+Z).")
	var mesh_fwd := -he.mesh_root.global_transform.basis.z
	var chest_fwd := he._rig.character_forward()
	if chest_fwd.length() < 0.2 or chest_fwd.dot(mesh_fwd) < 0.85:
		_fail("HE realistic mesh does not face MeshRoot / move forward (moonwalk).")
	var realistic := he.mesh_root.find_child("HERealistic", true, false) as Node3D
	if realistic and absf(angle_difference(realistic.rotation.y, PI * 0.5)) > 0.08:
		_fail("HERealistic yaw must be +90° so Bip01 +X matches MeshRoot −Z (got y=%.3f)." % realistic.rotation.y)
	var blockout := he.mesh_root.get_node_or_null("HEBlockout")
	if blockout == null:
		_fail("HE realistic mesh is not instanced under MeshRoot.")
	elif not _has_named_bones(blockout, PackedStringArray(["Hips", "L_Fist"])):
		_fail("HE realistic Skeleton3D bones (Hips / L_Fist) were not imported.")
	else:
		_assert_visible_body(he, "HE")
		he.state = HE.State.FREE
		he._sprinting = false
		he._update_visual_pose()
		var idle_l := he._rig.bone_pose_rotation("L_UpperArm")
		var idle_r := he._rig.bone_pose_rotation("R_UpperArm")
		var idle_l_fwd := he._rig.bone_world_axis("L_UpperArm", 1).dot(mesh_fwd)
		var idle_r_fwd := he._rig.bone_world_axis("R_UpperArm", 1).dot(mesh_fwd)
		he.state = HE.State.ATTACK
		he._attack = Combat.fists_light()
		he._state_time = 0.12
		he._update_visual_pose()
		var jab_q := he._rig.bone_pose_rotation("L_UpperArm")
		if idle_l.is_equal_approx(jab_q):
			_fail("HE jab must rotate L_UpperArm off the A-pose rest.")
		var jab_fwd := he._rig.bone_world_axis("L_UpperArm", 1).dot(mesh_fwd)
		if jab_fwd < idle_l_fwd + 0.08:
			_fail("HE jab L_UpperArm must swing toward MeshRoot forward.")
		if _fist_span(he, "L_Fist") > 1.35:
			_fail("HE jab L_Fist spaghetti — bone pose exploded the IBM skin.")
		he._attack = Combat.fists_heavy()
		he._state_time = 0.40
		he._update_visual_pose()
		var heavy_q := he._rig.bone_pose_rotation("R_UpperArm")
		if idle_r.is_equal_approx(heavy_q):
			_fail("HE heavy must rotate R_UpperArm off the A-pose rest.")
		var heavy_fwd := he._rig.bone_world_axis("R_UpperArm", 1).dot(mesh_fwd)
		if heavy_fwd < idle_r_fwd + 0.08:
			_fail("HE heavy R_UpperArm must commit toward MeshRoot forward.")
		if _fist_span(he, "R_Fist") > 1.35:
			_fail("HE heavy R_Fist spaghetti — bone pose exploded the IBM skin.")
		he.state = HE.State.FREE
		he._sprinting = true
		he._stride = 0.6
		he._update_visual_pose()
		var sprint_up := he._rig.bone_world_axis("Torso", 1)
		if sprint_up.dot(mesh_fwd) < 0.08:
			_fail("HE sprint must lean the torso toward move forward.")
		if _fist_span(he, "L_Fist") > 1.35 or _fist_span(he, "R_Fist") > 1.35:
			_fail("HE sprint pose exploded an arm (IBM skin).")
		he._sprinting = false
		he._update_visual_pose()
	var body_col := he.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if body_col == null or not (body_col.shape is CapsuleShape3D):
		_fail("HE world collision must stay a capsule.")
	var hurt_col := he.hurt.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if hurt_col == null or not (hurt_col.shape is CapsuleShape3D):
		_fail("HE hurtbox must stay a capsule.")
	if not is_equal_approx(float(Combat.fists_light().reach), 1.32):
		_fail("Jab reach changed from locked 1.32.")
	if not is_equal_approx(float(Combat.fists_heavy().reach), 1.52):
		_fail("Heavy reach changed from locked 1.52.")
	var herald_blockout := herald.mesh_root.get_node_or_null("HeraldBlockout")
	if herald_blockout == null:
		_fail("Herald realistic mesh is not instanced under MeshRoot.")
	elif not _has_named_bones(herald_blockout, PackedStringArray(["Hips", "R_UpperArm"])):
		_fail("Herald realistic Skeleton3D bones (Hips / R_UpperArm) were not imported.")
	elif herald_blockout.find_child("Crown", true, false) == null:
		_fail("Herald Crown mesh was not imported.")
	else:
		_assert_visible_body(herald, "Herald")
		var herald_idle := herald._rig.bone_pose_rotation("R_UpperArm")
		herald.phase = HollowHerald.Phase.SWIPE_WIND
		herald._time = 0.90
		herald._update_visual_pose()
		var wind_q := herald._rig.bone_pose_rotation("R_UpperArm")
		if herald_idle.is_equal_approx(wind_q):
			_fail("Herald swipe wind-up must rotate R_UpperArm off the A-pose rest.")
		herald.phase = HollowHerald.Phase.WAIT
		herald._time = 0.0
		herald._update_visual_pose()
	var herald_col := herald.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if herald_col == null or not (herald_col.shape is CapsuleShape3D):
		_fail("Herald world collision must stay a capsule.")
	else:
		var herald_shape := herald_col.shape as CapsuleShape3D
		if not is_equal_approx(herald_shape.radius, 0.48) or not is_equal_approx(herald_shape.height, 2.35):
			_fail("Herald capsule size changed from r=0.48 h=2.35.")
	var herald_hurt := herald.hurt.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if herald_hurt == null or not (herald_hurt.shape is CapsuleShape3D):
		_fail("Herald hurtbox must stay a capsule.")
	if not ResourceLoader.exists("res://ruins/fallen_castle/fallen_castle.tscn"):
		_fail("Fallen castle scene missing.")
	var kit_script := load("res://ruins/fallen_castle/camp_kit.gd")
	if kit_script == null:
		_fail("camp_kit.gd failed to compile — camp will stay empty.")
	if not ResourceLoader.exists("res://ruins/line7_pocket/line7_pocket.tscn"):
		_fail("Tunnel pocket scene missing.")
	Game.travel_to("fallen_castle")
	await get_tree().process_frame
	await get_tree().process_frame
	if Game.current_pocket != "fallen_castle":
		_fail("travel_to did not enter fallen_castle.")
	if he.global_position.y < 0.4:
		_fail("HE spawned in the void at the castle (y=%.2f)." % he.global_position.y)
	if he.global_position.z < 1.5:
		_fail("HE did not teleport into the castle courtyard (z=%.2f)." % he.global_position.z)
	var camp := he.get_parent().get_node_or_null("FallenCastle")
	if camp == null:
		_fail("FallenCastle node missing after travel.")
	else:
		var geo: Node = camp.get_node_or_null("Geometry")
		if geo == null or geo.get_child_count() < 8:
			_fail("Guard camp geometry did not build (kit/script error).")
	Game.travel_to("undercroft")
	await get_tree().process_frame
	if Game.current_pocket != "undercroft":
		_fail("Return travel did not restore the undercroft.")

	Game.travel_to("line7_pocket")
	await get_tree().process_frame
	await get_tree().process_frame
	if Game.current_pocket != "line7_pocket":
		_fail("travel_to did not enter line7_pocket.")
	if he.global_position.y < 0.4:
		_fail("HE spawned in the void in the tunnel (y=%.2f)." % he.global_position.y)
	if he.global_position.z < 1.5:
		_fail("HE did not teleport into the service tunnel (z=%.2f)." % he.global_position.z)
	if herald.visible or herald.process_mode != Node.PROCESS_MODE_DISABLED:
		_fail("Herald must stay disabled in the tunnel pocket.")
	var extra_enemies := 0
	for node in get_tree().get_nodes_in_group("enemy"):
		if node != herald:
			extra_enemies += 1
	if extra_enemies > 0:
		_fail("Tunnel pocket must not add a new enemy.")
	var lockers := get_tree().get_nodes_in_group("maint_locker")
	if lockers.is_empty():
		_fail("Maintenance locker missing.")
	else:
		var locker: Node = lockers[0]
		he.global_position = (locker as Node3D).global_position
		if not locker.has_method("interact") or not locker.interact():
			_fail("Locker E did not give stub loot.")
		if locker.has_method("can_interact") and locker.can_interact():
			_fail("Locker should be one-shot.")
		if not Game.pocket_note_taken and not Game.pocket_kit_taken:
			_fail("Locker interact did not record stub loot.")
	if not ResourceLoader.exists("res://ruins/guard_camp/guard_camp.tscn"):
		_fail("Guard camp scene missing.")
	Game.travel_to("guard_camp")
	await get_tree().process_frame
	await get_tree().process_frame
	if Game.current_pocket != "guard_camp":
		_fail("travel_to did not enter guard_camp.")
	if he.global_position.y < 0.4:
		_fail("HE spawned in the void at the camp (y=%.2f)." % he.global_position.y)
	if he.global_position.z < 1.5 or he.global_position.z > 5.0:
		_fail("HE did not teleport into the palisade enter (z=%.2f)." % he.global_position.z)
	if herald.visible or herald.process_mode != Node.PROCESS_MODE_DISABLED:
		_fail("Herald must stay disabled in the guard camp.")
	extra_enemies = 0
	for node in get_tree().get_nodes_in_group("enemy"):
		if node != herald:
			extra_enemies += 1
	if extra_enemies > 0:
		_fail("Guard camp must not add a new enemy.")
	if get_tree().get_nodes_in_group("tripod_central").is_empty():
		_fail("Camp tripod landmark missing.")
	if get_tree().get_nodes_in_group("guard_plank").is_empty():
		_fail("Guard plank missing.")
	if get_tree().get_nodes_in_group("mist_drop").is_empty():
		_fail("Mist drop missing.")
	if get_tree().get_nodes_in_group("lean_to_a").is_empty() or get_tree().get_nodes_in_group("lean_to_b").is_empty():
		_fail("Cloth lean-tos missing.")
	if get_tree().get_nodes_in_group("torch_post").is_empty():
		_fail("Torch post missing.")
	for stand in [
		Vector3(0.0, 1.0, 1.85),
		Vector3(0.0, 1.0, 4.45),
		Vector3(2.2, 1.0, 3.3),
		Vector3(1.55, 1.85, 4.75),
		Vector3(1.45, 1.2, 7.25),
		Vector3(0.0, 1.0, 8.55),
	]:
		he.global_position = stand
		he.velocity = Vector3.ZERO
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		if he.global_position.y < 0.4:
			_fail("Camp path dropped HE at %s (y=%.2f)." % [stand, he.global_position.y])
	var crates := get_tree().get_nodes_in_group("crate_loot")
	if crates.is_empty():
		_fail("Camp crate missing.")
	else:
		var crate: Node = crates[0]
		he.global_position = (crate as Node3D).global_position
		if not crate.has_method("interact") or not crate.interact():
			_fail("Camp crate E did not give stub loot.")
		if crate.has_method("can_interact") and crate.can_interact():
			_fail("Camp crate should be one-shot.")
		if not Game.camp_loot_taken:
			_fail("Camp crate interact did not record stub loot.")
	Game.travel_to("line7_pocket")
	await get_tree().process_frame
	if Game.current_pocket != "line7_pocket":
		_fail("Return from the camp did not restore the tunnel.")
	if he.global_position.z < 35.0:
		_fail("Camp return must land at the tunnel far end (z > 35), got z=%.2f." % he.global_position.z)
	if he.global_position.y < 0.4:
		_fail("Camp return dropped HE in the tunnel void (y=%.2f)." % he.global_position.y)
	Game.travel_to("undercroft")
	await get_tree().process_frame
	if Game.current_pocket != "undercroft":
		_fail("Return from the tunnel did not restore the undercroft.")
	if he.global_position.z <= 8.0:
		_fail("Tunnel return must land south of the Herald leash (z > 8), got z=%.2f." % he.global_position.z)
	if he.global_position.y < 0.4:
		_fail("Tunnel return dropped HE in the flood (y=%.2f)." % he.global_position.y)

	he.global_position = Vector3(0.0, 1.05, 17.2)
	await get_tree().create_timer(1.6).timeout
	if herald.phase == HollowHerald.Phase.WAIT:
		_fail("Herald never left WAIT after HE entered the duel floor.")
	if herald.phase != HollowHerald.Phase.DEAD and herald.phase < HollowHerald.Phase.SWIPE_WIND:
		## APPROACH is acceptable if still closing; swipe wind+ is the tell.
		if herald.phase != HollowHerald.Phase.APPROACH:
			_fail("Herald is not in the swipe/lunge loop (phase %s)." % herald.phase)
	herald.velocity = Vector3.ZERO
	herald._begin(HollowHerald.Phase.SWIPE_WIND)
	var swipe_wait := 0.0
	while herald.phase == HollowHerald.Phase.SWIPE_WIND and swipe_wait < 2.4:
		await get_tree().physics_frame
		swipe_wait += get_process_delta_time()
	if herald.phase != HollowHerald.Phase.SWIPE and herald.phase != HollowHerald.Phase.PAUSE:
		_fail("Herald swipe wind did not enter swipe (phase %s)." % herald.phase)
	var lunge_wait := 0.0
	while herald.phase < HollowHerald.Phase.LUNGE_WIND and herald.phase != HollowHerald.Phase.DEAD and lunge_wait < 2.8:
		await get_tree().physics_frame
		lunge_wait += get_process_delta_time()
	if herald.phase < HollowHerald.Phase.LUNGE_WIND:
		_fail("Herald swipe did not continue into lunge wind (phase %s)." % herald.phase)

	if Game.bind_ashpike():
		_fail("Bind succeeded before the shrine take.")
	if Game.ashpike_bound:
		_fail("Ashpike bound without a take.")

	var pickup: Node = Game.shrine_pickup
	if pickup == null or not pickup.has_method("interact"):
		_fail("Shrine pickup missing.")
	else:
		he.global_position = (pickup as Node3D).global_position
		if not pickup.interact():
			_fail("Shrine take failed.")
	if not Game.ashpike_taken:
		_fail("Ashpike was not taken.")
	if Game.ashpike_bound:
		_fail("Ashpike equipped itself on take.")
	if not Game.bind_ashpike():
		_fail("Bind after take failed.")
	if not Game.ashpike_bound:
		_fail("Ashpike did not stay bound.")
	Game.bind_fists()
	if Game.ashpike_bound:
		_fail("Stance 2 did not return to fists.")

	herald.take_hit(Combat.HERALD_MAX_HP, 0.0, he.global_position)
	if not Game.herald_dead:
		_fail("Herald did not fall after lethal damage.")

	_finish()


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


func _fist_span(he: HE, bone_name: String) -> float:
	var skel: Skeleton3D = he._rig.skeleton
	if skel == null:
		return 0.0
	var fist_idx := skel.find_bone(bone_name)
	var hips_idx := skel.find_bone("Hips")
	if fist_idx < 0 or hips_idx < 0:
		return 0.0
	var fist := skel.to_global(skel.get_bone_global_pose(fist_idx).origin)
	var hips := skel.to_global(skel.get_bone_global_pose(hips_idx).origin)
	return fist.distance_to(hips)


func _assert_visible_body(host: Node, label: String) -> void:
	var body := host.find_child("Body", true, false) as MeshInstance3D
	if body == null:
		_fail("%s Rocketbox Body mesh is missing." % label)
		return
	if not body.visible:
		_fail("%s Rocketbox Body is hidden." % label)
	var armature := host.find_child("HERealistic", true, false) as Node3D
	if armature == null:
		armature = host.find_child("HeraldRealistic", true, false) as Node3D
	if armature and armature.scale.x < 0.05:
		_fail("%s armature is still cm-scaled (%.4f) — Body will spec." % [label, armature.scale.x])


func _fail(message: String) -> void:
	_failures.append(message)


func _finish() -> void:
	if _failures.size() > 0:
		for line in _failures:
			push_error(line)
			print("FAIL: ", line)
		get_tree().quit(1)
		return
	print("LINE7_PLAY_SIM_OK")
	get_tree().quit(0)
