class_name LeanToB
extends Node3D

## Second cloth lean-to. Tighter, more cluttered — bedroll + spare poles.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const CLOTH := preload("res://ruins/guard_camp/materials/cloth.tres")
const ROPE := preload("res://ruins/guard_camp/materials/rope.tres")


func _ready() -> void:
	name = "lean_to_b"
	add_to_group("lean_to_b")
	_build()


func _build() -> void:
	CampProp.tapered_log(self, Vector3(-0.8, 0.85, -0.55), 0.065, 0.04, 1.7, BARK, true, Vector3(0.0, 0.0, 4.0))
	CampProp.tapered_log(self, Vector3(0.8, 0.85, -0.55), 0.065, 0.04, 1.7, BARK, true, Vector3(0.0, 0.0, -3.0))
	CampProp.tapered_log(self, Vector3(-0.75, 0.5, 0.65), 0.06, 0.04, 1.0, BARK, true)
	CampProp.tapered_log(self, Vector3(0.75, 0.5, 0.65), 0.06, 0.04, 1.0, BARK, true)
	CampProp.rope_wrap(self, Vector3(-0.8, 1.4, -0.55), 0.075, ROPE)
	CampProp.cloth_sail(self, Vector3(0.0, 1.0, 0.05), Vector3(2.0, 0.75, 1.45), CLOTH, 0.26, Vector3(-10.0, 8.0, 0.0))
	PocketGeo.box(self, Vector3(0.05, 0.12, 0.15), Vector3(1.15, 0.07, 0.7), CLOTH, true)
	PocketGeo.cylinder(self, Vector3(0.85, 0.12, 0.55), 0.05, 0.85, BARK, false, Vector3(0.0, 20.0, 88.0))
	PocketGeo.label(self, Vector3(0.0, 1.7, -0.1), "STORE", Color(0.88, 0.74, 0.5), 22)
