class_name GuardPlank
extends Node3D

## Check B — CampKit plank deck. Short jump / roll from the step crate.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")


func _ready() -> void:
	name = "guard_plank"
	add_to_group("guard_plank")
	Kit.add_log(self, Vector3(-0.55, 0, -1.15), 1.05, 0.07, 0, 1)
	Kit.add_log(self, Vector3(0.55, 0, -1.15), 1.05, 0.07, 12, -1)
	Kit.add_log(self, Vector3(-0.55, 0, 1.15), 1.05, 0.07, 8, 0)
	Kit.add_log(self, Vector3(0.55, 0, 1.15), 1.05, 0.07, 20, 2)
	Kit.plank_ramp(self, Vector3(0.0, 1.0, 0.0), Vector3(1.4, 0.08, 2.7), 0.0, 0.0)
	Kit.crate(self, Vector3(-1.05, 0.22, -0.1), Vector3(0.58, 0.36, 0.58), 8.0)
	PocketGeo.label(self, Vector3(0.0, 1.7, 0.0), "PLANK", Color(0.9, 0.7, 0.42), 26)
