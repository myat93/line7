class_name LeanToA
extends Node3D

## Check A — CampKit cloth lean-to.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")


func _ready() -> void:
	name = "lean_to_a"
	add_to_group("lean_to_a")
	Kit.lean_to(self, Vector3.ZERO, 0.0)
	PocketGeo.label(self, Vector3(0.0, 2.15, 0.0), "SHELTER", Color(0.88, 0.74, 0.5), 24)
