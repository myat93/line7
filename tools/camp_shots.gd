extends Node

## Launch with `-- --camp-shots`. Writes guard-camp stills for playtest.

const OUT_DIR := "/opt/cursor/artifacts/screenshots"

var _he: HE


func _ready() -> void:
	get_tree().create_timer(0.4).timeout.connect(_run)


func _run() -> void:
	_he = Game.player as HE
	if _he == null:
		push_error("CAMP_SHOTS: no HE")
		get_tree().quit(1)
		return
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	Game.travel_to("line7_pocket")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(3.4).timeout
	## PI looks +Z (same as tunnel pocket_shots).
	await _view(Vector3(0.0, 1.15, 37.2), PI, -0.08, "camp_door_facing_plaque")
	Game.travel_to("guard_camp")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(3.4).timeout
	await _view(Vector3(0.0, 1.0, 2.1), PI, -0.12, "tight_yard_from_enter_to_tripod")
	await _view(Vector3(-2.4, 1.0, 4.2), PI + 0.4, -0.12, "cloth_lean_to_a_and_brazier")
	await _view(Vector3(1.8, 1.0, 5.8), PI - 0.55, -0.18, "raised_plank_and_lean_to_b")
	await _view(Vector3(0.2, 1.0, 7.8), PI - 0.35, -0.12, "crate_loot_in_clutter")
	await _view(Vector3(0.0, 1.0, 12.2), PI, -0.06, "mist_drop_forest_tease")
	print("LINE7_CAMP_SHOTS_OK")
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
		push_error("CAMP_SHOTS: empty viewport for %s" % shot_name)
		return
	var path := "%s/%s.png" % [OUT_DIR, shot_name]
	var err := img.save_png(path)
	print("WROTE ", path, " ", err, " ", img.get_width(), "x", img.get_height())
