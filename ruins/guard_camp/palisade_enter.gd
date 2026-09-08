class_name PalisadeEnter
extends Node3D

## Enter gap in the palisade. E returns to the service-tunnel far end.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const ROPE := preload("res://ruins/guard_camp/materials/rope.tres")
const GATE := preload("res://core/area_gate.gd")


func _ready() -> void:
	name = "palisade_enter"
	_build()
	_place_gate()


func _build() -> void:
	CampProp.tapered_log(self, Vector3(-1.15, 1.35, 0.0), 0.18, 0.08, 2.7, BARK, true)
	CampProp.tapered_log(self, Vector3(1.15, 1.35, 0.0), 0.18, 0.08, 2.7, BARK, true)
	CampProp.rope_wrap(self, Vector3(-1.15, 1.7, 0.0), 0.19, ROPE)
	CampProp.rope_wrap(self, Vector3(1.15, 1.7, 0.0), 0.19, ROPE)
	PocketGeo.box(self, Vector3(0.0, 2.65, 0.0), Vector3(2.5, 0.1, 0.22), BOARD, true)
	PocketGeo.label(self, Vector3(0.0, 2.05, 0.45), "TUNNEL", Color(0.82, 0.74, 0.52), 26)
	PocketGeo.omni(self, Vector3(0.0, 2.2, 0.6), Color(0.85, 0.58, 0.3), 1.0, 5.0)


func _place_gate() -> void:
	var gate := Area3D.new()
	gate.set_script(GATE)
	gate.destination = "line7_pocket"
	gate.prompt_text = "E  —  return to the service tunnel"
	gate.arrive_banner = "SERVICE TUNNEL"
	gate.position = Vector3(0.0, 1.15, 0.15)
	add_child(gate)
