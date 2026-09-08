class_name MistDrop
extends Node3D

## Far palisade gap. Look-only purple forest drop. No softlock.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")


func _ready() -> void:
	name = "mist_drop"
	add_to_group("mist_drop")
	RealisticCamp.add(self, "res://ruins/guard_camp/meshes/mist_drop_realistic.glb")
	## Walkable threshold — same box as before so the drop cannot softlock.
	Kit.plank_ramp(self, Vector3(0.0, 0.12, 0.85), Vector3(2.3, 0.14, 1.9), 0.0, 0.0)
	PocketGeo.label(self, Vector3(0.0, 1.95, 1.15), "MIST", Color(0.78, 0.58, 0.74), 30)
