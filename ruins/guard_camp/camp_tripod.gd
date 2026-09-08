class_name CampTripod
extends Node3D

## Landmark — cook tripod that orients the yard. Look / walk around. No systems.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const IRON := preload("res://ruins/guard_camp/materials/iron.tres")
const EMBER := preload("res://ruins/guard_camp/materials/ember.tres")


func _ready() -> void:
	name = "camp_tripod"
	add_to_group("camp_tripod")
	_build()


func _build() -> void:
	## Three poles lean in. Collision on each so HE can walk through the gaps.
	PocketGeo.cylinder(self, Vector3(-0.55, 1.15, -0.42), 0.055, 2.5, BARK, true, Vector3(18.0, 0.0, 14.0))
	PocketGeo.cylinder(self, Vector3(0.58, 1.15, -0.35), 0.055, 2.5, BARK, true, Vector3(16.0, 0.0, -16.0))
	PocketGeo.cylinder(self, Vector3(0.0, 1.15, 0.62), 0.055, 2.5, BARK, true, Vector3(-20.0, 0.0, 0.0))
	## Lashing + hanging pot.
	PocketGeo.sphere(self, Vector3(0.0, 2.28, 0.0), 0.1, IRON, false)
	PocketGeo.cylinder(self, Vector3(0.0, 1.55, 0.0), 0.28, 0.22, IRON, true)
	PocketGeo.cylinder(self, Vector3(0.0, 1.42, 0.0), 0.32, 0.06, IRON, false)
	## Firewood ring + ember.
	PocketGeo.cylinder(self, Vector3(-0.28, 0.12, 0.1), 0.06, 0.55, BARK, false, Vector3(0.0, 0.0, 90.0))
	PocketGeo.cylinder(self, Vector3(0.22, 0.12, -0.12), 0.05, 0.5, BARK, false, Vector3(0.0, 35.0, 90.0))
	PocketGeo.cylinder(self, Vector3(0.05, 0.1, 0.22), 0.045, 0.42, BOARD, false, Vector3(0.0, -40.0, 88.0))
	PocketGeo.sphere(self, Vector3(0.0, 0.22, 0.0), 0.16, EMBER, false)
	PocketGeo.omni(self, Vector3(0.0, 0.85, 0.0), Color(1.0, 0.55, 0.22), 2.6, 9.0)
	PocketGeo.label(self, Vector3(0.0, 2.55, 0.0), "TRIPOD", Color(0.95, 0.78, 0.45), 36)
