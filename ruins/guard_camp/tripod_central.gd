class_name TripodCentral
extends Node3D

## Landmark — lashed cook tripod over a mud firepit. Orients the yard.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const IRON := preload("res://ruins/guard_camp/materials/iron.tres")
const EMBER := preload("res://ruins/guard_camp/materials/ember.tres")
const ROPE := preload("res://ruins/guard_camp/materials/rope.tres")
const MUD := preload("res://ruins/guard_camp/materials/mud.tres")


func _ready() -> void:
	name = "tripod_central"
	add_to_group("tripod_central")
	_build()


func _build() -> void:
	CampProp.tapered_log(self, Vector3(-0.5, 1.05, -0.38), 0.05, 0.03, 2.3, BARK, true, Vector3(18.0, 0.0, 14.0))
	CampProp.tapered_log(self, Vector3(0.52, 1.05, -0.32), 0.05, 0.03, 2.3, BARK, true, Vector3(16.0, 0.0, -16.0))
	CampProp.tapered_log(self, Vector3(0.0, 1.05, 0.55), 0.05, 0.03, 2.3, BARK, true, Vector3(-20.0, 0.0, 0.0))
	CampProp.rope_wrap(self, Vector3(0.0, 2.15, 0.0), 0.12, ROPE)
	PocketGeo.sphere(self, Vector3(0.0, 2.2, 0.0), 0.08, ROPE, false)
	PocketGeo.cylinder(self, Vector3(0.0, 1.48, 0.0), 0.26, 0.2, IRON, true)
	PocketGeo.cylinder(self, Vector3(0.0, 1.36, 0.0), 0.3, 0.05, IRON, false)
	PocketGeo.cylinder(self, Vector3(0.0, 0.06, 0.0), 0.55, 0.08, MUD, false)
	PocketGeo.cylinder(self, Vector3(-0.22, 0.1, 0.08), 0.05, 0.48, BARK, false, Vector3(0.0, 0.0, 90.0))
	PocketGeo.cylinder(self, Vector3(0.18, 0.1, -0.1), 0.045, 0.42, BARK, false, Vector3(0.0, 40.0, 90.0))
	PocketGeo.sphere(self, Vector3(0.0, 0.2, 0.0), 0.15, EMBER, false)
	PocketGeo.omni(self, Vector3(0.0, 0.75, 0.0), Color(1.0, 0.5, 0.18), 2.4, 7.5)
	PocketGeo.label(self, Vector3(0.0, 2.45, 0.0), "TRIPOD", Color(0.95, 0.78, 0.45), 30)
