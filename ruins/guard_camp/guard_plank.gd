class_name GuardPlank
extends Node3D

## Check B — raised watch plank. Short jump (or roll from the step crate).
## Slow on the plank is an exposed silhouette — cones come later.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const IRON := preload("res://ruins/guard_camp/materials/iron.tres")


func _ready() -> void:
	name = "guard_plank"
	add_to_group("guard_plank")
	_build()


func _build() -> void:
	## Four posts. Deck sits ~0.78 m above yard dirt (jump ~1.4 m).
	for xz in [Vector3(-0.7, 0.0, -1.55), Vector3(0.7, 0.0, -1.55), Vector3(-0.7, 0.0, 1.55), Vector3(0.7, 0.0, 1.55)]:
		PocketGeo.cylinder(self, xz + Vector3(0.0, 0.55, 0.0), 0.075, 1.1, BARK, true)
	## Deck planks.
	for i in 7:
		var z := -1.65 + float(i) * 0.48
		PocketGeo.box(self, Vector3(0.0, 1.08, z), Vector3(1.55, 0.08, 0.42), BOARD, true)
	## Rail on the outside (+X) so the silhouette reads; inside stays open to jump.
	PocketGeo.box(self, Vector3(0.72, 1.45, 0.0), Vector3(0.06, 0.55, 3.3), BOARD, true)
	PocketGeo.box(self, Vector3(-0.55, 1.38, -1.7), Vector3(1.2, 0.4, 0.06), BOARD, true)
	PocketGeo.box(self, Vector3(-0.55, 1.38, 1.7), Vector3(1.2, 0.4, 0.06), BOARD, true)
	## Step crate — roll or step then hop if the jump feels tall.
	PocketGeo.box(self, Vector3(-1.15, 0.28, -0.15), Vector3(0.7, 0.42, 0.7), BOARD, true)
	PocketGeo.box(self, Vector3(-1.15, 0.5, -0.15), Vector3(0.62, 0.06, 0.62), BARK, false)
	## Iron spike / banner stub.
	PocketGeo.cylinder(self, Vector3(0.55, 1.7, 0.0), 0.03, 1.15, IRON, false)
	PocketGeo.box(self, Vector3(0.7, 2.15, 0.0), Vector3(0.28, 0.22, 0.04), IRON, false)
	PocketGeo.label(self, Vector3(0.0, 1.85, 0.0), "PLANK", Color(0.9, 0.7, 0.42), 30)
	PocketGeo.omni(self, Vector3(0.0, 2.1, 0.0), Color(0.9, 0.65, 0.35), 1.1, 6.5)
