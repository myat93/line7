class_name LeanToShelter
extends Node3D

## Check A — walk-through lean-to. Optional torch post beside the open face.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const EMBER := preload("res://ruins/guard_camp/materials/ember.tres")
const IRON := preload("res://ruins/guard_camp/materials/iron.tres")

@export var title: String = "SHELTER"
@export var with_torch: bool = true


func _ready() -> void:
	name = "lean_to_shelter" if with_torch else "lean_to_store"
	add_to_group("lean_to_shelter")
	_build()
	if with_torch:
		_torch_post()


func _build() -> void:
	## Posts.
	PocketGeo.cylinder(self, Vector3(-1.15, 1.05, -0.85), 0.08, 2.1, BARK, true)
	PocketGeo.cylinder(self, Vector3(1.15, 1.05, -0.85), 0.08, 2.1, BARK, true)
	PocketGeo.cylinder(self, Vector3(-1.15, 0.7, 0.95), 0.08, 1.4, BARK, true)
	PocketGeo.cylinder(self, Vector3(1.15, 0.7, 0.95), 0.08, 1.4, BARK, true)
	## Back boards (closed +Z).
	for x in [-0.9, -0.45, 0.0, 0.45, 0.9]:
		PocketGeo.box(self, Vector3(x, 0.85, 1.05), Vector3(0.38, 1.55, 0.07), BOARD, true)
	## Side boards, open face toward -Z so HE can walk through.
	PocketGeo.box(self, Vector3(-1.25, 0.85, 0.1), Vector3(0.07, 1.55, 1.7), BOARD, true)
	PocketGeo.box(self, Vector3(1.25, 0.85, 0.1), Vector3(0.07, 1.55, 1.7), BOARD, true)
	## Slanted roof planks.
	var roof := Node3D.new()
	roof.position = Vector3(0.0, 1.7, 0.1)
	roof.rotation_degrees = Vector3(-22.0, 0.0, 0.0)
	add_child(roof)
	for i in 5:
		var z := -0.85 + float(i) * 0.42
		PocketGeo.box(roof, Vector3(0.0, 0.0, z), Vector3(2.7, 0.06, 0.36), BOARD, true)
	## Sleeping plank inside — walk-over, not a climb.
	PocketGeo.box(self, Vector3(0.0, 0.22, 0.35), Vector3(1.7, 0.1, 1.15), BOARD, true)
	PocketGeo.label(self, Vector3(0.0, 2.05, -0.2), title, Color(0.88, 0.74, 0.5), 28)


func _torch_post() -> void:
	var post := Node3D.new()
	post.name = "torch_post"
	post.position = Vector3(2.05, 0.0, -1.15)
	add_child(post)
	PocketGeo.cylinder(post, Vector3(0.0, 1.05, 0.0), 0.07, 2.1, BARK, true)
	PocketGeo.box(post, Vector3(0.12, 1.85, 0.0), Vector3(0.28, 0.06, 0.06), BOARD, false)
	PocketGeo.cylinder(post, Vector3(0.28, 1.92, 0.0), 0.035, 0.28, IRON, false)
	PocketGeo.sphere(post, Vector3(0.28, 2.08, 0.0), 0.08, EMBER, false)
	PocketGeo.omni(post, Vector3(0.28, 2.1, 0.0), Color(1.0, 0.6, 0.28), 2.2, 8.0)
	PocketGeo.label(post, Vector3(0.15, 2.45, 0.0), "TORCH", Color(1.0, 0.72, 0.4), 22)
