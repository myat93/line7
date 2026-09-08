class_name PalisadeLog
extends Node3D

## One photogrammetry palisade stake. Collision stays on the ring boxes.

@export var log_height: float = 2.6
@export var lean: float = 0.0


func _ready() -> void:
	if not name.begins_with("palisade_log"):
		name = "palisade_log"
	add_to_group("palisade_log")
	var stake := RealisticCamp.add(self, "res://ruins/guard_camp/meshes/palisade_log_realistic.glb")
	stake.scale = Vector3.ONE * (log_height / 2.6)
	stake.rotation_degrees.x = lean
