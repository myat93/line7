extends Node

## Launch with `-- --pose-shots`. Writes HE and Herald stills.

const OUT_DIR := "/opt/cursor/artifacts/screenshots"

var _he: HE
var _herald: HollowHerald
var _cam: Camera3D


func _ready() -> void:
	get_tree().create_timer(0.35).timeout.connect(_run)


func _run() -> void:
	_he = Game.player as HE
	_herald = Game.herald as HollowHerald
	if _he == null:
		push_error("POSE_SHOTS: no HE")
		get_tree().quit(1)
		return
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	_cam = _he.get_node("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	_he.global_position = Vector3(0.0, 1.05, 0.0)
	_he.velocity = Vector3.ZERO
	_he.mesh_root.rotation.y = PI
	## Three-quarter over the shoulder so fist arcs and the roll tuck read.
	_he._look_yaw = PI + 0.72
	_he._look_pitch = -0.18
	_he.camera_pivot.rotation = Vector3(_he._look_pitch, _he._look_yaw, 0.0)
	if _cam:
		_cam.h_offset = 0.05
	var spring := _he.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	if spring:
		spring.spring_length = 2.6
	await _shot("he_idle_readable", func() -> void:
		_he.state = HE.State.FREE
		_he._sprinting = false
		_he._update_visual_pose()
	)
	await _shot("he_jab_snap_readable", func() -> void:
		_he.state = HE.State.ATTACK
		_he._attack = Combat.fists_light()
		_he._state_time = 0.12
		_he._update_visual_pose()
	)
	await _shot("he_heavy_commit_readable", func() -> void:
		_he.state = HE.State.ATTACK
		_he._attack = Combat.fists_heavy()
		_he._state_time = 0.40
		_he._update_visual_pose()
	)
	await _shot("he_roll_tuck_readable", func() -> void:
		_he.state = HE.State.ROLL
		_he._state_time = 0.12
		_he._update_visual_pose()
	)
	await _shot("he_sprint_lean_readable", func() -> void:
		_he.state = HE.State.FREE
		_he._sprinting = true
		_he._update_visual_pose()
	)
	print("HE_POSE_SHOTS_OK")
	if _herald:
		await _herald_shots(spring)
	print("HERALD_POSE_SHOTS_OK")
	get_tree().quit(0)


func _herald_shots(spring: SpringArm3D) -> void:
	Game.player_dead = true
	_herald.velocity = Vector3.ZERO
	_herald.global_position = Vector3(0.8, 1.05, 3.6)
	_herald.mesh_root.look_at(_he.global_position, Vector3.UP)
	_he.global_position = Vector3(0.0, 1.05, 0.0)
	_he.state = HE.State.FREE
	_he._sprinting = false
	_he.mesh_root.rotation.y = 0.0
	_he._look_yaw = 0.42
	_he._look_pitch = -0.10
	_he.camera_pivot.rotation = Vector3(_he._look_pitch, _he._look_yaw, 0.0)
	_he._update_visual_pose()
	if _cam:
		_cam.h_offset = 0.15
	if spring:
		spring.spring_length = 3.4
	await _shot("herald_idle_readable", func() -> void:
		_herald.phase = HollowHerald.Phase.WAIT
		_herald._time = 0.0
		_herald._update_visual_pose()
	)
	await _shot("herald_swipe_wind_readable", func() -> void:
		_herald.phase = HollowHerald.Phase.SWIPE_WIND
		_herald._time = 0.85
		_herald.telegraph.light_color = Color(0.85, 0.28, 0.18)
		_herald.telegraph.light_energy = 1.8
		_herald._update_visual_pose()
	)
	await _shot("herald_swipe_readable", func() -> void:
		_herald.phase = HollowHerald.Phase.SWIPE
		_herald._time = 0.18
		_herald.telegraph.light_color = Color(0.85, 0.28, 0.18)
		_herald.telegraph.light_energy = 1.2
		_herald._update_visual_pose()
	)
	await _shot("herald_lunge_wind_readable", func() -> void:
		_herald.phase = HollowHerald.Phase.LUNGE_WIND
		_herald._time = 0.90
		_herald.telegraph.light_color = Color(0.85, 0.78, 0.45)
		_herald.telegraph.light_energy = 2.0
		_herald._update_visual_pose()
	)
	Game.player_dead = false


func _shot(name: String, setup: Callable) -> void:
	setup.call()
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	if img == null:
		push_error("POSE_SHOTS: empty viewport for %s" % name)
		return
	var path := "%s/%s.png" % [OUT_DIR, name]
	var err := img.save_png(path)
	print("WROTE ", path, " ", err, " ", img.get_width(), "x", img.get_height())
