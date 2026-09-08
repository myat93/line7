class_name LeanToB
extends Node3D

## Check B companion — second PBR cloth lean-to.

func _ready() -> void:
	name = "lean_to_b"
	add_to_group("lean_to_b")
	RealisticCamp.add(self, "res://ruins/guard_camp/meshes/lean_to_b_realistic.glb")
	PocketGeo.label(self, Vector3(0.0, 2.05, 0.0), "STORE", Color(0.88, 0.74, 0.5), 22)
