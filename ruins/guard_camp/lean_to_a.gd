class_name LeanToA
extends Node3D

## Check A — cloth lean-to, walk-through. Poles + sagging canvas.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const CLOTH := preload("res://ruins/guard_camp/materials/cloth.tres")
const ROPE := preload("res://ruins/guard_camp/materials/rope.tres")


func _ready() -> void:
	name = "lean_to_a"
	add_to_group("lean_to_a")
	_build()


func _build() -> void:
	CampProp.tapered_log(self, Vector3(-0.95, 0.95, -0.7), 0.07, 0.045, 1.9, BARK, true)
	CampProp.tapered_log(self, Vector3(0.95, 0.95, -0.7), 0.07, 0.045, 1.9, BARK, true)
	CampProp.tapered_log(self, Vector3(-0.95, 0.55, 0.75), 0.07, 0.045, 1.1, BARK, true)
	CampProp.tapered_log(self, Vector3(0.95, 0.55, 0.75), 0.07, 0.045, 1.1, BARK, true)
	CampProp.rope_wrap(self, Vector3(-0.95, 1.55, -0.7), 0.08, ROPE)
	CampProp.rope_wrap(self, Vector3(0.95, 1.55, -0.7), 0.08, ROPE)
	## Canvas roof, open face toward -Z.
	CampProp.cloth_sail(self, Vector3(0.0, 1.15, 0.05), Vector3(2.3, 0.85, 1.7), CLOTH, 0.22, Vector3(-8.0, 0.0, 0.0))
	## Side cloth flaps.
	CampProp.cloth_sail(self, Vector3(-1.05, 0.85, 0.05), Vector3(0.15, 1.1, 1.5), CLOTH, 0.08, Vector3(0.0, 90.0, 0.0))
	CampProp.cloth_sail(self, Vector3(1.05, 0.85, 0.05), Vector3(0.15, 1.1, 1.5), CLOTH, 0.08, Vector3(0.0, -90.0, 0.0))
	PocketGeo.box(self, Vector3(0.0, 0.14, 0.2), Vector3(1.4, 0.08, 0.9), BOARD, true)
	PocketGeo.label(self, Vector3(0.0, 1.85, -0.15), "SHELTER", Color(0.88, 0.74, 0.5), 24)
