extends Node

## Launch with `-- --pocket-shots`. Writes tunnel-pocket stills for playtest.

const OUT_DIR := "/opt/cursor/artifacts/screenshots"

var _he: HE


func _ready() -> void:
	get_tree().create_timer(0.4).timeout.connect(_run)


func _run() -> void:
	_he = Game.player as HE
	if _he == null:
		push_error("POCKET_SHOTS: no HE")
		get_tree().quit(1)
		return
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	## Door on the duel-platform +X edge. Herald stays in frame behind.
	await _view(Vector3(4.6, 1.05, 14.4), -0.55, -0.12, "service_door_on_duel_platform")
	Game.travel_to("line7_pocket")
	await get_tree().process_frame
	await get_tree().process_frame
	## Let the enter banner clear so landmarks read.
	await get_tree().create_timer(3.4).timeout
	await _view(Vector3(0.0, 1.15, 2.4), PI, -0.08, "pocket_entrance_looking_in")
	await _view(Vector3(0.0, 1.15, 10.4), PI, -0.22, "flood_corridor_jump_gap")
	await _view(Vector3(0.0, 1.15, 20.6), PI, -0.22, "flicker_tube_cluster")
	await _view(Vector3(-0.35, 1.15, 28.6), PI + 0.85, -0.06, "angel_stone_relief_wall")
	await _view(Vector3(0.0, 1.15, 34.6), PI, -0.1, "maintenance_locker_closed")
	var lockers := get_tree().get_nodes_in_group("maint_locker")
	if lockers.size() > 0 and lockers[0].has_method("interact"):
		_he.global_position = (lockers[0] as Node3D).global_position
		lockers[0].interact()
	await _view(Vector3(0.0, 1.15, 34.4), PI, -0.12, "locker_stub_loot_note")
	Game.travel_to("undercroft")
	await get_tree().process_frame
	await get_tree().process_frame
	await _view(Game.undercroft_return, -0.2, -0.1, "return_to_duel_platform")
	print("LINE7_POCKET_SHOTS_OK")
	get_tree().quit(0)


func _view(pos: Vector3, yaw: float, pitch: float, shot_name: String) -> void:
	_he.global_position = pos
	_he.velocity = Vector3.ZERO
	_he._look_yaw = yaw
	_he._look_pitch = pitch
	_he.camera_pivot.rotation = Vector3(pitch, yaw, 0.0)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	if img == null:
		push_error("POCKET_SHOTS: empty viewport for %s" % shot_name)
		return
	var path := "%s/%s.png" % [OUT_DIR, shot_name]
	var err := img.save_png(path)
	print("WROTE ", path, " ", err, " ", img.get_width(), "x", img.get_height())
