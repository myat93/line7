class_name PalisadeEnter
extends Node3D

## Enter gap. CampKit timber gate. E returns to the service-tunnel far end.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")
const GATE := preload("res://core/area_gate.gd")


func _ready() -> void:
	name = "palisade_enter"
	Kit.timber_gate(self, Vector3.ZERO, 0.0)
	PocketGeo.label(self, Vector3(0.0, 2.15, 0.45), "TUNNEL", Color(0.82, 0.74, 0.52), 26)
	var gate := Area3D.new()
	gate.set_script(GATE)
	gate.destination = "line7_pocket"
	gate.prompt_text = "E  —  return to the service tunnel"
	gate.arrive_banner = "SERVICE TUNNEL"
	gate.position = Vector3(0.0, 1.15, 0.15)
	add_child(gate)
