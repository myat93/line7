class_name GuardPlank
extends Node3D

## Check B — CampKit plank deck. Short jump / roll from the step crate.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")


func _ready() -> void:
	name = "guard_plank"
	add_to_group("guard_plank")
	## Walkable deck collision stays CampKit; posts / crate are PBR GLBs.
	for post in [
		[Vector3(-0.55, 0, -1.15), 1.05, 0.0],
		[Vector3(0.55, 0, -1.15), 1.05, 12.0],
		[Vector3(-0.55, 0, 1.15), 1.05, 8.0],
		[Vector3(0.55, 0, 1.15), 1.05, 20.0],
	]:
		var stake := RealisticCamp.add(self, "res://ruins/guard_camp/meshes/palisade_log_realistic.glb", post[0], post[2])
		stake.scale = Vector3.ONE * (float(post[1]) / 2.6)
	Kit.plank_ramp(self, Vector3(0.0, 1.0, 0.0), Vector3(1.4, 0.08, 2.7), 0.0, 0.0)
	var crate := RealisticCamp.add(self, "res://ruins/guard_camp/meshes/crate_realistic.glb", Vector3(-1.05, 0.0, -0.1), 8.0)
	crate.scale = Vector3.ONE * 0.72
	PocketGeo.label(self, Vector3(0.0, 1.7, 0.0), "PLANK", Color(0.9, 0.7, 0.42), 26)
