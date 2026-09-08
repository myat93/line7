class_name MeshPoseRig
extends RefCounted

## Drives MeshRoot visuals that live on a Skeleton3D (Rocketbox) and still
## falls back to named Node3D joints (box blockout).
##
## Jake's GLBs keep a 0.01 armature with 100× inverse binds. Godot then either
## specks the skinned Body or explodes it when that scale is undone for the
## meter-authored coat/crown. Rebuild IBM from rest and scale Body to meters.

var skeleton: Skeleton3D
var body: MeshInstance3D
var pos_scale: float = 1.0

var _bones: Dictionary = {}
var _nodes: Dictionary = {}
var _node_rest: Dictionary = {}
var _node_rest_pos: Dictionary = {}


func prepare_realistic(root: Node, target_height: float) -> void:
	_unscale_cm_armature(root)
	skeleton = _first_skeleton(root)
	body = root.find_child("Body", true, false) as MeshInstance3D
	if body:
		body.visible = true
		_rebuild_skin_from_rest()
		_fit_body_height(target_height)
	if skeleton:
		skeleton.reset_bone_poses()


func bind_parts(root: Node, part_names: PackedStringArray) -> void:
	_bones.clear()
	_nodes.clear()
	_node_rest.clear()
	_node_rest_pos.clear()
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
	for part_name in part_names:
		if _bones.has(part_name):
			continue
		var node := root.find_child(part_name, true, false) as Node3D
		if node == null:
			continue
		_nodes[part_name] = node
		_node_rest[part_name] = node.rotation
		_node_rest_pos[part_name] = node.position


func set_rot(part_name: String, extra: Vector3) -> void:
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


func _unscale_cm_armature(root: Node) -> void:
	var nodes: Array[Node3D] = []
	if root is Node3D:
		nodes.append(root as Node3D)
	for node_name in ["HERealistic", "HeraldRealistic"]:
		var visual := root.find_child(node_name, true, false) as Node3D
		if visual:
			nodes.append(visual)
	var skel := _first_skeleton(root)
	if skel:
		nodes.append(skel)
	for visual in nodes:
		if visual.scale.x > 0.0 and visual.scale.x < 0.05:
			visual.scale = Vector3.ONE
		## Leftover hip-height translation from the cm→m wrap. Origin is feet.
		if visual.position.y > 0.4 and visual.position.y < 1.2:
			visual.position.y = 0.0


func _rebuild_skin_from_rest() -> void:
	if skeleton == null or body == null or body.skin == null:
		return
	var skin := body.skin.duplicate() as Skin
	body.skin = skin
	if body.skeleton.is_empty() and skeleton:
		body.skeleton = body.get_path_to(skeleton)
	for i in range(skin.get_bind_count()):
		var bone_idx := skin.get_bind_bone(i)
		if bone_idx < 0:
			bone_idx = skeleton.find_bone(skin.get_bind_name(i))
		if bone_idx < 0:
			continue
		var rest := skeleton.get_bone_global_rest(bone_idx)
		if is_zero_approx(rest.basis.determinant()):
			continue
		skin.set_bind_pose(i, rest.affine_inverse())


func _fit_body_height(target_height: float) -> void:
	if body == null or target_height <= 0.001:
		return
	body.scale = Vector3.ONE
	body.position = Vector3.ZERO
	var aabb := body.get_aabb()
	var height := aabb.size.y
	if height < 0.0001:
		return
	var factor := target_height / height
	body.scale = Vector3.ONE * factor
	body.position.y = -(aabb.position.y * factor)
	pos_scale = 1.0 / factor


func _first_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for child in node.get_children():
		var found := _first_skeleton(child)
		if found:
			return found
	return null
