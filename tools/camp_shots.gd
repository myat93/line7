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
	await _view(Vector3(0.0, 1.15, 37.2), PI, -0.08, "photo_camp_door_at_tunnel")
	Game.travel_to("guard_camp")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(3.4).timeout
	await _view(Vector3(0.0, 1.05, 1.7), PI, -0.10, "photo2_yard_from_enter")
	await _view(Vector3(1.4, 1.05, 2.4), PI + 0.55, -0.10, "photo2_lean_tos_left")
	await _view(Vector3(0.35, 1.05, 4.1), PI + 0.85, -0.16, "photo2_plank_left")
	await _view(Vector3(0.15, 1.05, 6.3), PI + 0.45, -0.12, "photo2_crate_loot")
	await _view(Vector3(0.0, 1.05, 7.6), PI, -0.06, "photo2_torch_and_mist")
	await _walk_view(Vector3(0.2, 1.05, 4.6), PI + 0.55, -0.12, PI * 0.5, "photo2_he_walk_stride")
	await _walk_view(Vector3(0.2, 1.05, 4.6), PI + 0.55, -0.12, 0.0, "photo2_he_walk_mid_cycle")
	print("LINE7_CAMP_SHOTS_OK")
	get_tree().quit(0)


func _walk_view(pos: Vector3, yaw: float, pitch: float, stride: float, shot_name: String) -> void:
	_he.set_physics_process(false)
	_he.state = HE.State.FREE
	_he._sprinting = false
	_he._moving = true
	_he.velocity = Vector3(0.0, 0.0, Combat.WALK_SPEED)
	_he._stride = stride
	_he.global_position = pos
	_he._look_yaw = yaw
	_he._look_pitch = pitch
	_he.camera_pivot.rotation = Vector3(pitch, yaw, 0.0)
	_he.mesh_root.rotation.y = yaw
	_he._update_visual_pose()
	await get_tree().process_frame
	_he._update_visual_pose()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	if img == null:
		push_error("CAMP_SHOTS: empty viewport for %s" % shot_name)
	else:
		var path := "%s/%s.png" % [OUT_DIR, shot_name]
		var err := img.save_png(path)
		print("WROTE ", path, " ", err, " ", img.get_width(), "x", img.get_height())
	_he._moving = false
	_he.velocity = Vector3.ZERO
	_he.set_physics_process(true)


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
