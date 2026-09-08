class_name Ashpike
extends Node3D

## Held Ashpike visual. Hidden until the player binds after the shrine take.

func _ready() -> void:
	visible = false
	if get_child_count() == 0:
		add_child(make_mesh())


static func make_mesh() -> MeshInstance3D:
	var root := MeshInstance3D.new()
	root.name = "AshpikeMesh"
	var shaft := CylinderMesh.new()
	shaft.top_radius = 0.028
	shaft.bottom_radius = 0.034
	shaft.height = 1.85
	root.mesh = shaft
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.28, 0.26, 0.24)
	mat.metallic = 0.55
	mat.roughness = 0.38
	root.material_override = mat

	var tip := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.002
	cone.bottom_radius = 0.055
	cone.height = 0.28
	tip.mesh = cone
	tip.position = Vector3(0, 1.06, 0)
	var tip_mat := StandardMaterial3D.new()
	tip_mat.albedo_color = Color(0.62, 0.58, 0.5)
	tip_mat.metallic = 0.8
	tip_mat.roughness = 0.22
	tip_mat.emission_enabled = true
	tip_mat.emission = Color(0.35, 0.28, 0.16)
	tip_mat.emission_energy_multiplier = 0.4
	tip.material_override = tip_mat
	root.add_child(tip)

	var collar := MeshInstance3D.new()
	var ring := CylinderMesh.new()
	ring.top_radius = 0.05
	ring.bottom_radius = 0.05
	ring.height = 0.06
	collar.mesh = ring
	collar.position = Vector3(0, 0.86, 0)
	collar.material_override = tip_mat
	root.add_child(collar)
	return root


func set_bound(bound: bool) -> void:
	visible = bound
