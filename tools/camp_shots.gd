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
	await _view(Vector3(0.0, 1.15, 37.2), 0.0, -0.08, "camp_door_at_tunnel_exit")
	Game.travel_to("guard_camp")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(3.4).timeout
	await _view(Vector3(0.0, 1.0, 2.6), 0.0, -0.1, "palisade_enter_looking_at_tripod")
	await _view(Vector3(-4.2, 1.0, 7.2), -0.6, -0.12, "lean_to_shelter_and_torch")
	await _view(Vector3(3.4, 1.0, 11.4), -1.1, -0.18, "guard_plank_raised_watch")
	await _view(Vector3(0.6, 1.0, 14.2), -0.35, -0.15, "optional_camp_crate")
	await _view(Vector3(0.0, 1.0, 21.4), 0.0, -0.08, "mist_exit_fog_wall")
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
