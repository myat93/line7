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
	if he.mesh_root.get_node_or_null("Visor") == null:
		_fail("Facing visor missing.")
	if not ResourceLoader.exists("res://ruins/fallen_castle/fallen_castle.tscn"):
		_fail("Fallen castle scene missing.")
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
