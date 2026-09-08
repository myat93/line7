extends Node

## Launch with `-- --pose-dump`. Prints HE facing + bone axes + attack fist placement.

var _parts: PackedStringArray = PackedStringArray([
	"Hips", "Torso", "Head",
	"L_UpperArm", "L_Forearm", "L_Fist",
	"R_UpperArm", "R_Forearm", "R_Fist",
	"L_Thigh", "L_Shin", "R_Thigh", "R_Shin",
])


func _ready() -> void:
	get_tree().create_timer(0.35).timeout.connect(_run)


func _run() -> void:
	var he := Game.player as HE
	if he == null:
		push_error("POSE_DUMP: no HE")
		get_tree().quit(1)
		return
	he.global_position = Vector3(0.0, 1.05, 0.0)
	he.velocity = Vector3.ZERO
	he._look_yaw = PI
	he.mesh_root.rotation.y = PI
	var visual := he.mesh_root.find_child("HERealistic", true, false) as Node3D
	print("MESHROOT_YAW ", he.mesh_root.rotation.y)
	if visual:
		print("HERealistic rot ", visual.rotation, " scale ", visual.scale, " pos ", visual.position)
	print("CHAR_FWD ", he._rig.character_forward(), " MESH_FWD ", -he.mesh_root.global_transform.basis.z)
	he.state = HE.State.FREE
	he._sprinting = false
	he._update_visual_pose()
	_dump_bones(he, "idle")
	_print_forward(he, "idle")
	he._face_direction(Vector3(0, 0, 1), 1.0)
	print("AFTER_+Z_FACE mesh_root.y=", he.mesh_root.rotation.y)
	_print_forward(he, "after_+Z")
	he.state = HE.State.ATTACK
	he._attack = Combat.fists_light()
	he._state_time = 0.12
	he._update_visual_pose()
	_dump_bones(he, "jab")
	_print_forward(he, "jab")
	he._attack = Combat.fists_heavy()
	he._state_time = 0.40
	he._update_visual_pose()
	_dump_bones(he, "heavy")
	_print_forward(he, "heavy")
	he.state = HE.State.FREE
	he._sprinting = false
	he._moving = true
	he._stride = PI * 0.5
	he._update_visual_pose()
	_dump_bones(he, "walk_left")
	_print_forward(he, "walk_left")
	he._stride = PI * 1.5
	he._update_visual_pose()
	_dump_bones(he, "walk_right")
	_print_forward(he, "walk_right")
	he._sprinting = true
	he._moving = true
	he._stride = PI * 0.5
	he._update_visual_pose()
	_dump_bones(he, "sprint")
	_print_forward(he, "sprint")
	he.state = HE.State.ROLL
	he._state_time = 0.12
	he._update_visual_pose()
	_dump_bones(he, "roll")
	_print_forward(he, "roll")
	print("POSE_DUMP_OK")
	get_tree().quit(0)


func _print_forward(he: HE, label: String) -> void:
	var mesh_fwd := -he.mesh_root.global_transform.basis.z
	var skel := he._rig.skeleton
	var head_idx := skel.find_bone("Head")
	var hips_idx := skel.find_bone("Hips")
	var nose := skel.to_global(skel.get_bone_global_pose(head_idx).origin)
	var hips := skel.to_global(skel.get_bone_global_pose(hips_idx).origin)
	var to_head := nose - hips
	to_head.y = 0.0
	var lf := _bone_global(he, "L_Fist")
	var rf := _bone_global(he, "R_Fist")
	print("%s mesh_fwd=%s hips=%s head=%s head_along_fwd=%.3f L_Fist=%s R_Fist=%s fistL_fwd=%.3f fistR_fwd=%.3f" % [
		label, mesh_fwd, hips, nose, (nose - he.global_position).dot(mesh_fwd),
		lf, rf,
		(lf - he.global_position).dot(mesh_fwd),
		(rf - he.global_position).dot(mesh_fwd),
	])


func _bone_global(he: HE, name: String) -> Vector3:
	var skel := he._rig.skeleton
	var idx := skel.find_bone(name)
	return skel.to_global(skel.get_bone_global_pose(idx).origin)


func _dump_bones(he: HE, label: String) -> void:
	print("--- ", label, " ---")
	var skel := he._rig.skeleton
	for part in _parts:
		var idx := skel.find_bone(part)
		if idx < 0:
			continue
		var rest := skel.get_bone_rest(idx)
		var pose := skel.get_bone_global_pose(idx)
		var world := skel.to_global(pose.origin)
		var rest_e := rest.basis.get_euler()
		var pose_e := skel.get_bone_pose_rotation(idx).get_euler()
		var gx := (skel.to_global(pose.origin + pose.basis.x) - world).normalized()
		var gy := (skel.to_global(pose.origin + pose.basis.y) - world).normalized()
		var gz := (skel.to_global(pose.origin + pose.basis.z) - world).normalized()
		print("%s pos=%s rest_e=%s pose_e=%s axisX=%s axisY=%s axisZ=%s" % [
			part, world, rest_e, pose_e, gx, gy, gz
		])
