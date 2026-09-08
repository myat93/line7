class_name GuardPlank
extends Node3D

## Check B — raised watch plank. Short jump (or roll from the step crate).
## Slow on the plank is an exposed silhouette — cones come later.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const IRON := preload("res://ruins/guard_camp/materials/iron.tres")
const ROPE := preload("res://ruins/guard_camp/materials/rope.tres")


func _ready() -> void:
	name = "guard_plank"
	add_to_group("guard_plank")
	_build()


func _build() -> void:
	for xz in [Vector3(-0.55, 0.0, -1.2), Vector3(0.55, 0.0, -1.2), Vector3(-0.55, 0.0, 1.2), Vector3(0.55, 0.0, 1.2)]:
		CampProp.tapered_log(self, xz + Vector3(0.0, 0.5, 0.0), 0.07, 0.05, 1.0, BARK, true)
		CampProp.rope_wrap(self, xz + Vector3(0.0, 0.85, 0.0), 0.075, ROPE)
	for i in 6:
		var z := -1.3 + float(i) * 0.44
		PocketGeo.box(self, Vector3(0.0, 0.98, z), Vector3(1.35, 0.07, 0.38), BOARD, true)
	PocketGeo.box(self, Vector3(0.62, 1.32, 0.0), Vector3(0.05, 0.48, 2.6), BOARD, true)
	PocketGeo.box(self, Vector3(-0.95, 0.24, -0.1), Vector3(0.58, 0.36, 0.58), BOARD, true)
	PocketGeo.cylinder(self, Vector3(0.48, 1.55, 0.0), 0.028, 1.0, IRON, false)
	PocketGeo.label(self, Vector3(0.0, 1.7, 0.0), "PLANK", Color(0.9, 0.7, 0.42), 26)
	PocketGeo.omni(self, Vector3(0.0, 1.9, 0.0), Color(0.9, 0.62, 0.32), 0.9, 5.5)
