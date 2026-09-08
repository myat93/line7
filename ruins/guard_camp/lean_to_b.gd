class_name LeanToB
extends Node3D

## Check B companion — second CampKit cloth lean-to.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")


func _ready() -> void:
	name = "lean_to_b"
	add_to_group("lean_to_b")
	Kit.lean_to(self, Vector3.ZERO, 0.0)
	Kit.weather_cloth(self, Color(0.15, 0.12, 0.09))
	PocketGeo.label(self, Vector3(0.0, 2.05, 0.0), "STORE", Color(0.88, 0.74, 0.5), 22)
