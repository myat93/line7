class_name DoorGap
extends Node3D

## Sealed service door / platform lip. E travels; no physical hole.

const TILE := preload("res://ruins/line7_pocket/materials/tile.tres")
const RUST := preload("res://ruins/line7_pocket/materials/rust_metal.tres")
const CONCRETE := preload("res://ruins/line7_undercroft/materials/concrete.tres")
const GATE := preload("res://core/area_gate.gd")

@export var destination: String = "line7_pocket"
@export var prompt_text: String = "E  —  enter the service tunnel"
@export var arrive_banner: String = ""
@export var plaque_text: String = "SERVICE"


func _ready() -> void:
	name = "door_gap"
	_build()
	_place_gate()


func _build() -> void:
	## Lip in front of the sealed slab so HE has ground at the wall.
	PocketGeo.box(self, Vector3(0.0, 0.5, 0.95), Vector3(2.4, 1.0, 1.9), TILE, true)
	## Frame.
	PocketGeo.box(self, Vector3(-0.95, 1.7, 0.08), Vector3(0.22, 2.6, 0.28), RUST, true)
	PocketGeo.box(self, Vector3(0.95, 1.7, 0.08), Vector3(0.22, 2.6, 0.28), RUST, true)
	PocketGeo.box(self, Vector3(0.0, 3.05, 0.08), Vector3(2.15, 0.22, 0.3), RUST, true)
	## Sealed slab.
	PocketGeo.box(self, Vector3(0.0, 1.65, 0.02), Vector3(1.7, 2.4, 0.12), CONCRETE, true)
	PocketGeo.box(self, Vector3(0.0, 1.7, 0.1), Vector3(0.08, 2.1, 0.04), RUST, false)
	PocketGeo.box(self, Vector3(0.55, 1.55, 0.12), Vector3(0.12, 0.18, 0.08), RUST, false)
	PocketGeo.label(self, Vector3(0.0, 2.55, 0.28), plaque_text, Color(0.7, 0.86, 0.84), 32)
	PocketGeo.omni(self, Vector3(0.0, 2.8, 0.7), Color(0.45, 0.72, 0.7), 1.8, 5.5)


func _place_gate() -> void:
	var gate := Area3D.new()
	gate.set_script(GATE)
	gate.destination = destination
	gate.prompt_text = prompt_text
	gate.arrive_banner = arrive_banner
	gate.position = Vector3(0.0, 1.2, 0.7)
	add_child(gate)
