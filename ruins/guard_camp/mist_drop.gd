class_name MistDrop
extends Node3D

## Far palisade gap. Look-only mist / forest drop. Fog wall blocks the void.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const DIRT := preload("res://ruins/guard_camp/materials/dirt.tres")
const MIST := preload("res://ruins/guard_camp/materials/mist.tres")
const MUD := preload("res://ruins/guard_camp/materials/mud.tres")


func _ready() -> void:
	name = "mist_drop"
	add_to_group("mist_drop")
	_build()


func _build() -> void:
	PocketGeo.box(self, Vector3(0.0, 0.1, 0.85), Vector3(2.3, 0.14, 1.9), BOARD, true)
	CampProp.tapered_log(self, Vector3(-1.15, 1.25, 0.1), 0.17, 0.08, 2.5, BARK, true)
	CampProp.tapered_log(self, Vector3(1.15, 1.25, 0.1), 0.17, 0.08, 2.5, BARK, true)
	PocketGeo.box(self, Vector3(0.0, 0.3, 1.75), Vector3(2.4, 0.26, 0.2), BARK, true)
	## Fog wall — colliding, so the drop is a tease.
	PocketGeo.box(self, Vector3(0.0, 1.7, 2.15), Vector3(4.2, 3.4, 0.65), MIST, true)
	## Forest silhouettes beyond — look only.
	var dark := DIRT.duplicate() as StandardMaterial3D
	dark.albedo_color = Color(0.07, 0.08, 0.07)
	for xz in [Vector3(-1.6, 2.2, 3.4), Vector3(0.2, 2.6, 3.8), Vector3(1.5, 2.1, 3.5), Vector3(-0.7, 1.8, 4.2)]:
		CampProp.tapered_log(self, xz, 0.22, 0.04, xz.y * 1.4, dark, false)
	PocketGeo.box(self, Vector3(0.0, -2.0, 4.8), Vector3(9.0, 0.3, 5.0), dark, false)
	PocketGeo.omni(self, Vector3(0.0, 1.5, 1.1), Color(0.5, 0.66, 0.7), 1.2, 6.0)
	PocketGeo.label(self, Vector3(0.0, 1.95, 1.15), "MIST", Color(0.72, 0.84, 0.86), 30)
