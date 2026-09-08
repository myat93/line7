class_name TorchPost
extends Node3D

## Iron brazier on a lashed post. Check A companion.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const IRON := preload("res://ruins/guard_camp/materials/iron.tres")
const EMBER := preload("res://ruins/guard_camp/materials/ember.tres")
const ROPE := preload("res://ruins/guard_camp/materials/rope.tres")


func _ready() -> void:
	name = "torch_post"
	add_to_group("torch_post")
	_build()


func _build() -> void:
	CampProp.tapered_log(self, Vector3(0.0, 0.95, 0.0), 0.07, 0.05, 1.9, BARK, true)
	CampProp.rope_wrap(self, Vector3(0.0, 1.55, 0.0), 0.08, ROPE)
	PocketGeo.cylinder(self, Vector3(0.0, 1.95, 0.0), 0.16, 0.1, IRON, false)
	PocketGeo.cylinder(self, Vector3(0.0, 2.02, 0.0), 0.12, 0.16, IRON, false)
	PocketGeo.sphere(self, Vector3(0.0, 2.12, 0.0), 0.09, EMBER, false)
	PocketGeo.omni(self, Vector3(0.0, 2.15, 0.0), Color(1.0, 0.55, 0.22), 2.3, 7.5)
	PocketGeo.label(self, Vector3(0.1, 2.45, 0.0), "TORCH", Color(1.0, 0.72, 0.4), 20)
