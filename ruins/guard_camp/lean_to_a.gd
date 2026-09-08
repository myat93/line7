class_name LeanToA
extends Node3D

## Check A — PBR cloth lean-to.

func _ready() -> void:
	name = "lean_to_a"
	add_to_group("lean_to_a")
	RealisticCamp.add(self, "res://ruins/guard_camp/meshes/lean_to_a_realistic.glb")
	PocketGeo.label(self, Vector3(0.0, 2.15, 0.0), "SHELTER", Color(0.88, 0.74, 0.5), 24)
