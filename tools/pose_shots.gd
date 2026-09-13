extends Node

## Launch with `-- --pose-shots`. Writes idle / jab / heavy / roll / sprint stills.
## Herald stills: `-- --herald-shots` (tools/herald_shots.gd).

const OUT_DIR := "/opt/cursor/artifacts/screenshots"

var _he: HE
var _cam: Camera3D


func _ready() -> void:
	get_tree().create_timer(0.35).timeout.connect(_run)


func _run() -> void:
	_he = Game.player as HE
	if _he == null:
		push_error("POSE_SHOTS: no HE")
		get_tree().quit(1)
		return
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	_cam = _he.get_node("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	_he.global_position = Vector3(0.0, 1.05, 0.0)
	_he.velocity = Vector3.ZERO
	_he.set_physics_process(false)
	_he.mesh_root.rotation.y = PI
	## Directly behind HE, looking along MeshRoot −Z / +Z travel so facing is
	## unambiguous (three-quarter hid the 90° chest error as "over-shoulder").
	_he._look_yaw = PI
	_he._look_pitch = -0.16
	_he.camera_pivot.rotation = Vector3(_he._look_pitch, _he._look_yaw, 0.0)
	if _cam:
		_cam.h_offset = 0.08
	var spring := _he.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	if spring:
		spring.spring_length = 3.0
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
	await _shot("he_walk_mid_cycle", func() -> void:
		_he.state = HE.State.FREE
		_he._sprinting = false
		_he._moving = true
		_he.velocity = Vector3(0.0, 0.0, Combat.WALK_SPEED)
		_he._stride = 0.0
		_he._update_visual_pose()
	)
	await _shot("he_walk_left_pass", func() -> void:
		_he.state = HE.State.FREE
		_he._sprinting = false
		_he._moving = true
		_he.velocity = Vector3(0.0, 0.0, Combat.WALK_SPEED)
		_he._stride = PI * 0.5
		_he._update_visual_pose()
	)
	await _shot("he_walk_right_pass", func() -> void:
		_he.state = HE.State.FREE
		_he._sprinting = false
		_he._moving = true
		_he.velocity = Vector3(0.0, 0.0, Combat.WALK_SPEED)
		_he._stride = PI * 1.5
		_he._update_visual_pose()
	)
	await _shot("he_sprint_lean_readable", func() -> void:
		_he.state = HE.State.FREE
		_he._sprinting = true
		_he._moving = true
		_he.velocity = Vector3(0.0, 0.0, Combat.SPRINT_SPEED)
		_he._stride = 0.85
		_he._update_visual_pose()
	)
	await _shot("he_run_stop_idle", func() -> void:
		_he.state = HE.State.FREE
		_he._sprinting = true
		_he._stride = 0.85
		_he._update_visual_pose()
		_he._sprinting = false
		_he._moving = false
		_he._update_visual_pose()
	)
	## Three-quarter so jab / heavy fists read; facing already proven from behind.
	_he._look_yaw = PI + 0.55
	_he._look_pitch = -0.14
	_he.camera_pivot.rotation = Vector3(_he._look_pitch, _he._look_yaw, 0.0)
	if spring:
		spring.spring_length = 2.7
	await _shot("he_idle_three_quarter", func() -> void:
		_he.state = HE.State.FREE
		_he._sprinting = false
		_he._moving = false
		_he.velocity = Vector3.ZERO
		_he._update_visual_pose()
	)
	await _shot("he_walk_three_quarter", func() -> void:
		_he.state = HE.State.FREE
		_he._sprinting = false
		_he._moving = true
		_he.velocity = Vector3(0.0, 0.0, Combat.WALK_SPEED)
		_he._stride = PI * 0.5
		_he._update_visual_pose()
	)
	await _shot("he_jab_three_quarter", func() -> void:
		_he.state = HE.State.ATTACK
		_he._attack = Combat.fists_light()
		_he._state_time = 0.12
		_he._update_visual_pose()
	)
	await _shot("he_heavy_three_quarter", func() -> void:
		_he.state = HE.State.ATTACK
		_he._attack = Combat.fists_heavy()
		_he._state_time = 0.40
		_he._update_visual_pose()
	)
	print("HE_POSE_SHOTS_OK")
	get_tree().quit(0)


func _shot(name: String, setup: Callable) -> void:
	_he.global_position = Vector3(0.0, 1.05, 0.0)
	_he.velocity = Vector3.ZERO
	_he.state = HE.State.FREE
	setup.call()
	await get_tree().process_frame
	_he.global_position = Vector3(0.0, 1.05, 0.0)
	_he.velocity = Vector3.ZERO
	await get_tree().process_frame
	_he.global_position = Vector3(0.0, 1.05, 0.0)
	_he.velocity = Vector3.ZERO
	await get_tree().create_timer(0.05).timeout
	var img: Image = get_viewport().get_texture().get_image()
	if img == null:
		push_error("POSE_SHOTS: empty viewport for %s" % name)
		return
	DirAccess.make_dir_recursive_absolute("/tmp/he_pose_shots")
	var path := "%s/%s.png" % [OUT_DIR, name]
	var err := img.save_png(path)
	var tmp := "/tmp/he_pose_shots/%s.png" % name
	img.save_png(tmp)
	print("WROTE ", path, " ", err, " ", img.get_width(), "x", img.get_height())
