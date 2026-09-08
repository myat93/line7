class_name TripodCentral
extends Node3D

## Landmark — PBR lashed cook tripod.

func _ready() -> void:
	name = "tripod_central"
	add_to_group("tripod_central")
	RealisticCamp.add(self, "res://ruins/guard_camp/meshes/tripod_realistic.glb")
	PocketGeo.label(self, Vector3(0.0, 3.35, 0.0), "TRIPOD", Color(0.95, 0.78, 0.45), 30)
	PocketGeo.omni(self, Vector3(0.0, 0.7, 0.0), Color(1.0, 0.5, 0.18), 2.2, 7.0)
