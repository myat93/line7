class_name MeshPoseRig
extends RefCounted

## Drives MeshRoot visuals that live on a Skeleton3D (Rocketbox) and still
## falls back to named Node3D joints (box blockout).
##
## Jake's GLBs parent a 100×-IBM Body under a 0.01 armature so coat/crown
## (authored in meters) shrink. Undo that scale — coat, crown, and the skinned
## Body then read at ~1.8 / 2.05 m. Keep the authored inverse binds; replacing
## them with inverse(rest) explodes vertices. Idle stays bind-pose (A-pose is
## the authored rest). Combat extras go through set_bone_pose_rotation.
##
## Rocketbox Bip01 faces Max +X. The armature is authored -90° Y, which turns
## that into Godot +Z. MeshRoot / hitboxes are Godot-forward (−Z). Adding PI
## yaw on the armature lines the chest up with movement without touching
## MeshRoot yaw or reach numbers.

var skeleton: Skeleton3D
var body: MeshInstance3D
var pos_scale: float = 1.0

var _bones: Dictionary = {}
var _nodes: Dictionary = {}
var _node_rest: Dictionary = {}
var _node_rest_pos: Dictionary = {}
var _rest_global: Dictionary = {}


func prepare_realistic(root: Node, _target_height: float) -> void:
	_unscale_cm_armature(root)
	_align_godot_forward(root)
	skeleton = _first_skeleton(root)
	body = root.find_child("Body", true, false) as MeshInstance3D
	if body:
		body.visible = true
	if skeleton:
		skeleton.reset_bone_poses()


func bind_parts(root: Node, part_names: PackedStringArray) -> void:
	_bones.clear()
	_nodes.clear()
	_node_rest.clear()
	_node_rest_pos.clear()
	_rest_global.clear()
	if root == null:
		return
	if skeleton == null:
		skeleton = _first_skeleton(root)
	if body == null:
		body = root.find_child("Body", true, false) as MeshInstance3D
	if skeleton:
		for part_name in part_names:
			var idx := skeleton.find_bone(part_name)
			if idx >= 0:
				_bones[part_name] = idx
		_cache_rest_globals()
	for part_name in part_names:
		if _bones.has(part_name):
			continue
		var node := root.find_child(part_name, true, false) as Node3D
		if node == null:
			continue
		_nodes[part_name] = node
		_node_rest[part_name] = node.rotation
		_node_rest_pos[part_name] = node.position


func reset_to_bind() -> void:
	if skeleton:
		skeleton.reset_bone_poses()


func set_rot(part_name: String, extra: Vector3) -> void:
	## Bone-local extras. Herald swipe/lunge still use this path.
	if skeleton and _bones.has(part_name):
		var idx: int = _bones[part_name]
		var rest_q := skeleton.get_bone_rest(idx).basis.get_rotation_quaternion()
		skeleton.set_bone_pose_rotation(idx, rest_q * Quaternion.from_euler(extra))
		return
	var node: Node3D = _nodes.get(part_name) as Node3D
	if node == null:
		return
	var rest: Vector3 = _node_rest.get(part_name, Vector3.ZERO)
	node.rotation = rest + extra


func set_char_rot(part_name: String, extra: Vector3) -> void:
	## Pitch / yaw / roll in skeleton space (X right, Y up, −Z forward).
	## Bip01 hips +X is character forward, so bone-local X extras rolled the
	## torso instead of leaning. Character-space extras keep sprint/jab readable.
	if skeleton and _bones.has(part_name):
		var idx: int = _bones[part_name]
		var parent_b := _parent_rest_basis(idx)
		var rest_global: Basis = _rest_global.get(part_name, skeleton.get_bone_rest(idx).basis)
		var extra_b := Basis.from_euler(extra)
		var new_local := parent_b.inverse() * extra_b * rest_global
		skeleton.set_bone_pose_rotation(idx, new_local.get_rotation_quaternion())
		return
	set_rot(part_name, extra)


func aim_along_y(part_name: String, char_dir: Vector3, weight: float = 1.0) -> void:
	## Swing the bone so rest +Y (Bip01 along-bone) points at char_dir.
	if skeleton == null or not _bones.has(part_name):
		return
	if char_dir.length() < 0.05 or weight <= 0.001:
		return
	var idx: int = _bones[part_name]
	var rest_global: Basis = _rest_global.get(part_name, skeleton.get_bone_rest(idx).basis)
	var current_y := rest_global.y.normalized()
	var want := char_dir.normalized()
	var swing := Basis.IDENTITY
	var align := current_y.dot(want)
	if align < 0.999:
		var axis := current_y.cross(want)
		if axis.length() < 0.001:
			axis = rest_global.x
		else:
			axis = axis.normalized()
		swing = Basis(axis, current_y.angle_to(want))
	var parent_b := _parent_rest_basis(idx)
	var aimed := swing * rest_global
	var blended := rest_global.slerp(aimed, clampf(weight, 0.0, 1.0))
	var new_local := parent_b.inverse() * blended
	skeleton.set_bone_pose_rotation(idx, new_local.get_rotation_quaternion())


func set_pos(part_name: String, extra: Vector3) -> void:
	if skeleton and _bones.has(part_name):
		var idx: int = _bones[part_name]
		var rest_p := skeleton.get_bone_rest(idx).origin
		skeleton.set_bone_pose_position(idx, rest_p + extra * pos_scale)
		return
	var node: Node3D = _nodes.get(part_name) as Node3D
	if node == null:
		return
	var rest: Vector3 = _node_rest_pos.get(part_name, node.position)
	node.position = rest + extra


func has_bone(part_name: String) -> bool:
	return _bones.has(part_name)


func bone_pose_rotation(part_name: String) -> Quaternion:
	if skeleton == null or not _bones.has(part_name):
		return Quaternion.IDENTITY
	return skeleton.get_bone_pose_rotation(int(_bones[part_name]))


func bone_world_axis(part_name: String, axis: int) -> Vector3:
	if skeleton == null or not _bones.has(part_name):
		return Vector3.ZERO
	var idx: int = _bones[part_name]
	var pose := skeleton.get_bone_global_pose(idx)
	var local := pose.basis.x
	if axis == 1:
		local = pose.basis.y
	elif axis == 2:
		local = pose.basis.z
	return (skeleton.global_transform.basis * local).normalized()


func character_forward() -> Vector3:
	## Bip01 hips +X is the authored chest/face direction.
	if skeleton == null or not _bones.has("Hips"):
		return Vector3.ZERO
	return bone_world_axis("Hips", 0)


func _cache_rest_globals() -> void:
	_rest_global.clear()
	if skeleton == null:
		return
	for part_name in _bones.keys():
		var idx: int = _bones[part_name]
		_rest_global[part_name] = _compute_rest_global(idx).basis


func _compute_rest_global(idx: int) -> Transform3D:
	var xform := Transform3D.IDENTITY
	var chain: Array[int] = []
	var cursor := idx
	while cursor >= 0:
		chain.push_front(cursor)
		cursor = skeleton.get_bone_parent(cursor)
	for bone_idx in chain:
		xform *= skeleton.get_bone_rest(bone_idx)
	return xform


func _parent_rest_basis(idx: int) -> Basis:
	var parent := skeleton.get_bone_parent(idx)
	if parent < 0:
		return Basis.IDENTITY
	return _compute_rest_global(parent).basis


func _unscale_cm_armature(root: Node) -> void:
	var nodes: Array[Node3D] = []
	if root is Node3D:
		nodes.append(root as Node3D)
	for node_name in ["HERealistic", "HeraldRealistic"]:
		var visual := root.find_child(node_name, true, false) as Node3D
		if visual:
			nodes.append(visual)
	for visual in nodes:
		if visual.scale.x > 0.0 and visual.scale.x < 0.05:
			visual.scale = Vector3.ONE
		if visual.position.y > 0.4 and visual.position.y < 1.2:
			visual.position.y = 0.0


func _align_godot_forward(root: Node) -> void:
	for node_name in ["HERealistic", "HeraldRealistic"]:
		var visual := root.find_child(node_name, true, false) as Node3D
		if visual == null:
			continue
		## Authored −90° Y (Max +X → Godot +Z). Flip to +90° so Max +X → −Z.
		if absf(angle_difference(visual.rotation.y, -PI * 0.5)) < 0.25:
			visual.rotation.y += PI


func _first_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for child in node.get_children():
		var found := _first_skeleton(child)
		if found:
			return found
	return null
