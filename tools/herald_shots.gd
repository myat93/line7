extends Node

## Launch with `-- --herald-shots`. Writes Herald idle / swipe / lunge stills.

const OUT_DIR := "/opt/cursor/artifacts/screenshots"

var _he: HE
var _herald: HollowHerald


func _ready() -> void:
	get_tree().create_timer(0.4).timeout.connect(_run)


func _run() -> void:
	_he = Game.player as HE
	_herald = Game.herald as HollowHerald
	if _he == null or _herald == null:
		push_error("HERALD_SHOTS: missing HE or Herald")
		get_tree().quit(1)
		return
	print("HERALD_SHOTS_BEGIN")
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	Game.player_dead = true
	_he.velocity = Vector3.ZERO
	_herald.velocity = Vector3.ZERO
	_herald.global_position = Vector3(0.0, 1.05, 18.5)
	_he.global_position = Vector3(-1.8, 1.05, 16.0)
	_he.state = HE.State.FREE
	_he._sprinting = false
	if _he.mesh_root.global_position.distance_to(_herald.global_position) > 0.2:
		_he.mesh_root.look_at(_herald.global_position, Vector3.UP)
	if _herald.mesh_root.global_position.distance_to(_he.global_position) > 0.2:
		_herald.mesh_root.look_at(_he.global_position, Vector3.UP)
	_he._update_visual_pose()
	var he_cam := _he.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	if he_cam:
		he_cam.current = false
	var shot_cam := Camera3D.new()
	shot_cam.name = "HeraldShotCam"
	shot_cam.fov = 50.0
	get_tree().current_scene.add_child(shot_cam)
	shot_cam.global_position = Vector3(3.6, 2.45, 15.4)
	shot_cam.look_at(Vector3(0.15, 1.35, 18.4), Vector3.UP)
	shot_cam.current = true
	print("HERALD_SHOTS_CAM ", shot_cam.global_position)
	_herald.phase = HollowHerald.Phase.WAIT
	_herald._time = 0.0
	_herald._update_visual_pose()
	await _grab("herald_and_he_readable")
	_herald.phase = HollowHerald.Phase.WAIT
	_herald._time = 0.0
	_herald.telegraph.light_energy = 0.25
	_herald._update_visual_pose()
	await _grab("herald_idle_readable")
	shot_cam.global_position = Vector3(4.1, 2.15, 18.2)
	shot_cam.look_at(Vector3(0.1, 1.55, 18.5), Vector3.UP)
	_herald.phase = HollowHerald.Phase.SWIPE_WIND
	_herald._time = 0.90
	_herald.telegraph.light_color = Color(0.85, 0.28, 0.18)
	_herald.telegraph.light_energy = 1.8
	_herald._update_visual_pose()
	await _grab("herald_swipe_wind_readable")
	_herald.phase = HollowHerald.Phase.SWIPE
	_herald._time = 0.18
	_herald._update_visual_pose()
	await _grab("herald_swipe_readable")
	shot_cam.global_position = Vector3(3.5, 1.85, 16.2)
	shot_cam.look_at(Vector3(0.0, 1.15, 18.5), Vector3.UP)
	_herald.phase = HollowHerald.Phase.LUNGE_WIND
	_herald._time = 0.95
	_herald.telegraph.light_color = Color(0.85, 0.78, 0.45)
	_herald.telegraph.light_energy = 2.0
	_herald._update_visual_pose()
	await _grab("herald_lunge_wind_readable")
	print("HERALD_POSE_SHOTS_OK")
	Game.player_dead = false
	get_tree().quit(0)
	OS.kill(OS.get_process_id())


func _grab(shot_name: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	if img == null:
		push_error("HERALD_SHOTS: empty viewport for %s" % shot_name)
		return
	var path := "%s/%s.png" % [OUT_DIR, shot_name]
	var err := img.save_png(path)
	print("WROTE ", path, " ", err, " ", img.get_width(), "x", img.get_height())
