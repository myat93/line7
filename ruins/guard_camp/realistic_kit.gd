class_name RealisticCamp
extends RefCounted

## Instance the director-pass PBR GLBs. Collision stays on CampKit / Area3D.


static func add(parent: Node3D, path: String, offset: Vector3 = Vector3.ZERO, yaw_deg: float = 0.0) -> Node3D:
	var packed := load(path) as PackedScene
	var node := packed.instantiate() as Node3D
	node.position = offset
	node.rotation_degrees.y = yaw_deg
	parent.add_child(node)
	return node


static func hide_meshes(root: Node) -> void:
	## Hide CampKit primitives only. Imported GLBs are ArrayMesh and stay visible.
	for child in root.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		if mi.mesh is CylinderMesh or mi.mesh is BoxMesh or mi.mesh is SphereMesh or mi.mesh is PlaneMesh:
			mi.visible = false
