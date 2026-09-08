extends Node

## Run-wide slice state. Autoload name: Game.

signal banner_changed(text: String, duration: float)
signal prompt_changed(text: String)
signal hud_dirty
signal player_died
signal herald_felled
signal pocket_requested(pocket_id: String)

var ashpike_taken: bool = false
var ashpike_bound: bool = false
var herald_dead: bool = false
var player_dead: bool = false
var near_shrine: bool = false

var player: Node3D
var herald: Node3D
var shrine_pickup: Node3D
var current_pocket: String = "undercroft"
var undercroft_return: Vector3 = Vector3(-3.2, 1.05, -1.4)
var pocket_note_taken: bool = false
var pocket_kit_taken: bool = false

const RETURN_FROM_CASTLE := Vector3(-3.2, 1.05, -1.4)
const RETURN_FROM_POCKET := Vector3(6.4, 1.05, 14.2)


func _ready() -> void:
	_ensure_input_map()
	banner("LINE 7 — UNDERCROFT\nWake. Walk the flood. The Herald waits.", 4.5)
	if OS.get_cmdline_user_args().has("--slice-sim"):
		var sim := Node.new()
		sim.set_script(load("res://tools/play_sim.gd"))
		add_child(sim)
	if OS.get_cmdline_user_args().has("--pose-shots"):
		var shots := Node.new()
		shots.set_script(load("res://tools/pose_shots.gd"))
		add_child(shots)
	if OS.get_cmdline_user_args().has("--herald-shots"):
		var hshots := Node.new()
		hshots.set_script(load("res://tools/herald_shots.gd"))
		add_child(hshots)


func restart() -> void:
	ashpike_taken = false
	ashpike_bound = false
	herald_dead = false
	player_dead = false
	near_shrine = false
	pocket_note_taken = false
	pocket_kit_taken = false
	current_pocket = "undercroft"
	undercroft_return = RETURN_FROM_CASTLE
	get_tree().reload_current_scene()


func travel_to(pocket_id: String) -> void:
	if pocket_id == current_pocket:
		return
	match pocket_id:
		"fallen_castle":
			undercroft_return = RETURN_FROM_CASTLE
		"line7_pocket":
			undercroft_return = RETURN_FROM_POCKET
	current_pocket = pocket_id
	pocket_requested.emit(pocket_id)


func banner(text: String, duration: float = 3.2) -> void:
	banner_changed.emit(text, duration)


func set_prompt(text: String) -> void:
	prompt_changed.emit(text)


func take_ashpike() -> bool:
	if ashpike_taken:
		return false
	ashpike_taken = true
	ashpike_bound = false
	banner("Ashpike taken — unequipped until you bind.\nPress 1 to bind. Press 2 for fists.")
	set_prompt("")
	hud_dirty.emit()
	return true


func bind_ashpike() -> bool:
	if not ashpike_taken:
		banner("Ashpike is still in the shrine.")
		return false
	if ashpike_bound:
		banner("Ashpike already bound.")
		return true
	ashpike_bound = true
	banner("Ashpike bound.")
	hud_dirty.emit()
	return true


func bind_fists() -> void:
	if ashpike_bound:
		banner("Fists.")
	ashpike_bound = false
	hud_dirty.emit()


func stance_label() -> String:
	if ashpike_bound:
		return "ASHPIKE"
	if ashpike_taken:
		return "FISTS  ·  Ashpike unbound"
	return "FISTS"


func mark_herald_dead() -> void:
	if herald_dead:
		return
	herald_dead = true
	banner("The Herald falls. The shrine answers.")
	herald_felled.emit()
	hud_dirty.emit()


func mark_player_dead() -> void:
	if player_dead:
		return
	player_dead = true
	banner("Fallen. Press R to restart.")
	player_died.emit()
	hud_dirty.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		restart()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("debug_ruins"):
		if current_pocket == "fallen_castle":
			travel_to("undercroft")
		else:
			travel_to("fallen_castle")
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("debug_tunnel"):
		if current_pocket == "line7_pocket":
			travel_to("undercroft")
		else:
			travel_to("line7_pocket")
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("toggle_mouse"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_viewport().set_input_as_handled()


func _ensure_input_map() -> void:
	_action("move_forward", [_key(KEY_W)])
	_action("move_back", [_key(KEY_S)])
	_action("move_left", [_key(KEY_A)])
	_action("move_right", [_key(KEY_D)])
	_rebind("sprint", [_key(KEY_SHIFT)])
	_action("jump", [_key(KEY_SPACE)])
	_action("light_attack", [_mouse(MOUSE_BUTTON_LEFT), _key(KEY_J)])
	_action("heavy_attack", [_mouse(MOUSE_BUTTON_RIGHT), _key(KEY_K)])
	_rebind("roll", [_key(KEY_CTRL)])
	_unbind_key("roll", KEY_SPACE)
	_action("interact", [_key(KEY_E)])
	_action("bind_ashpike", [_key(KEY_1)])
	_action("bind_fists", [_key(KEY_2)])
	_action("restart", [_key(KEY_R)])
	_action("debug_ruins", [_key(KEY_8)])
	_action("debug_tunnel", [_key(KEY_9)])
	_action("toggle_mouse", [_key(KEY_ESCAPE)])


func _rebind(action_name: String, events: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	InputMap.action_erase_events(action_name)
	for event in events:
		InputMap.action_add_event(action_name, event)


func _unbind_key(action_name: String, physical: Key) -> void:
	if not InputMap.has_action(action_name):
		return
	for existing in InputMap.action_get_events(action_name):
		if existing is InputEventKey and existing.physical_keycode == physical:
			InputMap.action_erase_event(action_name, existing)


func _action(action_name: String, events: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for event in events:
		var exists := false
		for existing in InputMap.action_get_events(action_name):
			if existing.get_class() == event.get_class():
				if event is InputEventKey and existing is InputEventKey:
					if existing.physical_keycode == event.physical_keycode:
						exists = true
				elif event is InputEventMouseButton and existing is InputEventMouseButton:
					if existing.button_index == event.button_index:
						exists = true
		if not exists:
			InputMap.action_add_event(action_name, event)


func _key(physical: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = physical
	event.keycode = physical
	## Shift/Ctrl events arrive with their modifier flag set. A binding with
	## shift_pressed=false never matches a live Shift press.
	event.shift_pressed = physical == KEY_SHIFT
	event.ctrl_pressed = physical == KEY_CTRL
	event.alt_pressed = physical == KEY_ALT
	event.meta_pressed = physical == KEY_META
	return event


func _mouse(button: MouseButton) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button
	return event
