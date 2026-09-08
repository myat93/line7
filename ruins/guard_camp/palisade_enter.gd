class_name PalisadeEnter
extends Node3D

## Enter gap. PBR log posts. E returns to the service-tunnel far end.

const GATE := preload("res://core/area_gate.gd")


func _ready() -> void:
	name = "palisade_enter"
	var left := RealisticCamp.add(self, "res://ruins/guard_camp/meshes/palisade_log_realistic.glb", Vector3(-1.25, 0, 0), 0.0)
	left.scale = Vector3.ONE * (3.15 / 2.6)
	var right := RealisticCamp.add(self, "res://ruins/guard_camp/meshes/palisade_log_realistic.glb", Vector3(1.25, 0, 0), 8.0)
	right.scale = Vector3.ONE * (3.05 / 2.6)
	PocketGeo.label(self, Vector3(0.0, 2.15, 0.45), "TUNNEL", Color(0.82, 0.74, 0.52), 26)
	var gate := Area3D.new()
	gate.set_script(GATE)
	gate.destination = "line7_pocket"
	gate.prompt_text = "E  —  return to the service tunnel"
	gate.arrive_banner = "SERVICE TUNNEL"
	gate.position = Vector3(0.0, 1.15, 0.15)
	add_child(gate)
