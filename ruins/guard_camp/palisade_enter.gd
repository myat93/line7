class_name PalisadeEnter
extends Node3D

## Enter gap in the palisade. E returns to the service-tunnel far end.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const GATE := preload("res://core/area_gate.gd")


func _ready() -> void:
	name = "palisade_enter"
	_build()
	_place_gate()


func _build() -> void:
	## Thick gate posts — the ring leaves this gap open.
	PocketGeo.cylinder(self, Vector3(-1.35, 1.45, 0.0), 0.2, 2.9, BARK, true)
	PocketGeo.cylinder(self, Vector3(1.35, 1.45, 0.0), 0.2, 2.9, BARK, true)
	## Lintel board so the gap reads as a cut, not a missing wall.
	PocketGeo.box(self, Vector3(0.0, 2.85, 0.0), Vector3(2.9, 0.12, 0.28), BOARD, true)
	PocketGeo.box(self, Vector3(-1.35, 2.55, 0.0), Vector3(0.12, 0.55, 0.12), BOARD, false)
	PocketGeo.box(self, Vector3(1.35, 2.55, 0.0), Vector3(0.12, 0.55, 0.12), BOARD, false)
	PocketGeo.label(self, Vector3(0.0, 2.15, 0.55), "TUNNEL", Color(0.82, 0.74, 0.52), 30)
	PocketGeo.omni(self, Vector3(0.0, 2.4, 0.8), Color(0.85, 0.62, 0.35), 1.2, 6.0)


func _place_gate() -> void:
	var gate := Area3D.new()
	gate.set_script(GATE)
	gate.destination = "line7_pocket"
	gate.prompt_text = "E  —  return to the service tunnel"
	gate.arrive_banner = "SERVICE TUNNEL"
	gate.position = Vector3(0.0, 1.15, 0.2)
	add_child(gate)
