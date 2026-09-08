class_name MistExit
extends Node3D

## Far palisade gap. Look-only mist / drop tease. Fog wall blocks the void.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const DIRT := preload("res://ruins/guard_camp/materials/dirt.tres")
const MIST := preload("res://ruins/guard_camp/materials/mist.tres")


func _ready() -> void:
	name = "mist_exit"
	add_to_group("mist_exit")
	_build()


func _build() -> void:
	## Lookout boards through the north gap.
	PocketGeo.box(self, Vector3(0.0, 0.12, 1.1), Vector3(2.6, 0.16, 2.4), BOARD, true)
	PocketGeo.cylinder(self, Vector3(-1.3, 1.35, 0.15), 0.18, 2.7, BARK, true)
	PocketGeo.cylinder(self, Vector3(1.3, 1.35, 0.15), 0.18, 2.7, BARK, true)
	## Low curb — you can stand and look; you do not walk off.
	PocketGeo.box(self, Vector3(0.0, 0.32, 2.15), Vector3(2.7, 0.28, 0.22), BARK, true)
	## Fog wall: visible + colliding so the drop is a tease, not a softlock.
	PocketGeo.box(self, Vector3(0.0, 1.8, 2.55), Vector3(4.6, 3.6, 0.7), MIST, true)
	PocketGeo.box(self, Vector3(-2.4, 1.6, 3.6), Vector3(1.2, 3.4, 2.4), MIST, false)
	PocketGeo.box(self, Vector3(2.4, 1.6, 3.6), Vector3(1.2, 3.4, 2.4), MIST, false)
	## Painted drop beyond the wall — never reachable.
	var void_mat := DIRT.duplicate() as StandardMaterial3D
	void_mat.albedo_color = Color(0.06, 0.07, 0.08)
	PocketGeo.box(self, Vector3(0.0, -2.2, 5.4), Vector3(10.0, 0.3, 6.0), void_mat, false)
	PocketGeo.omni(self, Vector3(0.0, 1.6, 1.4), Color(0.55, 0.7, 0.75), 1.4, 7.0)
	PocketGeo.label(self, Vector3(0.0, 2.05, 1.35), "MIST", Color(0.72, 0.84, 0.86), 34)
