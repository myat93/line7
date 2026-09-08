class_name CampProp
extends RefCounted

## Authored wood / cloth meshes for the cramped palisade yard. Not CSG.


static func cloth_sail(parent: Node, pos: Vector3, size: Vector3, mat: Material, sag: float = 0.2, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cols := 4
	var rows := 3
	for z in rows:
		for x in cols:
			var u := float(x) / float(cols - 1)
			var v := float(z) / float(rows - 1)
			var drop := sag * sin(u * PI) * (0.35 + v)
			var p := Vector3((u - 0.5) * size.x, size.y * (1.0 - v) - drop, (v - 0.5) * size.z)
			st.set_uv(Vector2(u, v))
			st.set_normal(Vector3.UP)
			st.add_vertex(p)
	for z in rows - 1:
		for x in cols - 1:
			var i := z * cols + x
			st.add_index(i)
			st.add_index(i + 1)
			st.add_index(i + cols)
			st.add_index(i + 1)
			st.add_index(i + cols + 1)
			st.add_index(i + cols)
	st.generate_normals()
	var mesh := st.commit()
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = mat
	node.position = pos
	node.rotation_degrees = rot
	parent.add_child(node)
	return node


static func rope_wrap(parent: Node, pos: Vector3, radius: float, mat: Material) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius * 0.92
	torus.outer_radius = radius * 1.12
	torus.rings = 10
	torus.ring_segments = 8
	mesh.mesh = torus
	mesh.material_override = mat
	mesh.position = pos
	parent.add_child(mesh)
	return mesh


static func tapered_log(parent: Node, pos: Vector3, bottom: float, top: float, height: float, mat: Material, collide: bool, rot: Vector3 = Vector3.ZERO) -> Node3D:
	var cyl := CylinderMesh.new()
	cyl.bottom_radius = bottom
	cyl.top_radius = top
	cyl.height = height
	cyl.radial_segments = 8
	if collide:
		var body := StaticBody3D.new()
		body.position = pos
		body.rotation_degrees = rot
		body.collision_layer = Combat.LAYER_WORLD
		body.collision_mask = 0
		var inst := MeshInstance3D.new()
		inst.mesh = cyl
		inst.material_override = mat
		body.add_child(inst)
		var col := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = maxf(bottom, top)
		shape.height = height
		col.shape = shape
		body.add_child(col)
		parent.add_child(body)
		return body
	var inst := MeshInstance3D.new()
	inst.mesh = cyl
	inst.material_override = mat
	inst.position = pos
	inst.rotation_degrees = rot
	parent.add_child(inst)
	return inst
