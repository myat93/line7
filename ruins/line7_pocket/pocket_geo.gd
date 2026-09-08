class_name PocketGeo
extends RefCounted

## Shared box / cylinder / label / light helpers for pocket blockouts.


static func box(parent: Node, pos: Vector3, size: Vector3, mat: Material, collide: bool) -> Node3D:
	if collide:
		var body := StaticBody3D.new()
		body.position = pos
		body.collision_layer = Combat.LAYER_WORLD
		body.collision_mask = 0
		var mesh := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = size
		mesh.mesh = box_mesh
		mesh.material_override = mat
		body.add_child(mesh)
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		col.shape = shape
		body.add_child(col)
		parent.add_child(body)
		return body
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	mesh.material_override = mat
	mesh.position = pos
	parent.add_child(mesh)
	return mesh


static func cylinder(parent: Node, pos: Vector3, radius: float, height: float, mat: Material, collide: bool, rot: Vector3 = Vector3.ZERO) -> Node3D:
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = height
	if collide:
		var body := StaticBody3D.new()
		body.position = pos
		body.rotation_degrees = rot
		body.collision_layer = Combat.LAYER_WORLD
		body.collision_mask = 0
		var mesh := MeshInstance3D.new()
		mesh.mesh = cyl
		mesh.material_override = mat
		body.add_child(mesh)
		var col := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = radius
		shape.height = height
		col.shape = shape
		body.add_child(col)
		parent.add_child(body)
		return body
	var mesh := MeshInstance3D.new()
	mesh.mesh = cyl
	mesh.material_override = mat
	mesh.position = pos
	mesh.rotation_degrees = rot
	parent.add_child(mesh)
	return mesh


static func sphere(parent: Node, pos: Vector3, radius: float, mat: Material, collide: bool = false) -> Node3D:
	var ball := SphereMesh.new()
	ball.radius = radius
	ball.height = radius * 2.0
	if collide:
		var body := StaticBody3D.new()
		body.position = pos
		body.collision_layer = Combat.LAYER_WORLD
		body.collision_mask = 0
		var mesh := MeshInstance3D.new()
		mesh.mesh = ball
		mesh.material_override = mat
		body.add_child(mesh)
		var col := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = radius
		col.shape = shape
		body.add_child(col)
		parent.add_child(body)
		return body
	var mesh := MeshInstance3D.new()
	mesh.mesh = ball
	mesh.material_override = mat
	mesh.position = pos
	parent.add_child(mesh)
	return mesh


static func capsule(parent: Node, pos: Vector3, radius: float, height: float, mat: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = radius
	cap.height = height
	mesh.mesh = cap
	mesh.material_override = mat
	mesh.position = pos
	mesh.rotation_degrees = rot
	parent.add_child(mesh)
	return mesh


static func label(parent: Node, pos: Vector3, text: String, color: Color = Color(0.82, 0.88, 0.86), font_size: int = 36) -> Label3D:
	var plaque := Label3D.new()
	plaque.text = text
	plaque.font_size = font_size
	plaque.position = pos
	plaque.modulate = color
	plaque.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	plaque.double_sided = true
	parent.add_child(plaque)
	return plaque


static func omni(parent: Node, pos: Vector3, color: Color, energy: float, omni_range: float = 8.0) -> OmniLight3D:
	var lamp := OmniLight3D.new()
	lamp.position = pos
	lamp.light_color = color
	lamp.light_energy = energy
	lamp.omni_range = omni_range
	lamp.shadow_enabled = true
	parent.add_child(lamp)
	return lamp
