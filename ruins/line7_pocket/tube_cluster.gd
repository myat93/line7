class_name TubeCluster
extends Node3D

## Landmark A — flickering fluorescent tube cluster. Navigation beacon only.

const TUBE := preload("res://ruins/line7_pocket/materials/tube_glow.tres")
const RUST := preload("res://ruins/line7_pocket/materials/rust_metal.tres")
const TILE := preload("res://ruins/line7_pocket/materials/tile.tres")

var _lamps: Array[OmniLight3D] = []
var _t: float = 0.0


func _ready() -> void:
	name = "tube_cluster"
	_build()


func _process(delta: float) -> void:
	_t += delta
	var pulse := 0.85 + sin(_t * 9.4) * 0.15
	if sin(_t * 23.0) > 0.82 or fmod(_t * 2.7, 1.0) > 0.93:
		pulse *= 0.12
	for lamp in _lamps:
		lamp.light_energy = 2.4 * pulse


func _build() -> void:
	PocketGeo.box(self, Vector3(0.0, 0.48, 0.0), Vector3(3.2, 0.96, 3.6), TILE, true)
	PocketGeo.box(self, Vector3(0.0, 3.25, 0.0), Vector3(2.8, 0.14, 2.4), RUST, false)
	var offsets := [
		Vector3(-0.7, 2.85, -0.25),
		Vector3(-0.15, 2.95, 0.2),
		Vector3(0.4, 2.8, -0.15),
		Vector3(0.85, 2.9, 0.35),
	]
	for i in offsets.size():
		var pos: Vector3 = offsets[i]
		PocketGeo.capsule(self, pos, 0.07, 2.1, TUBE, Vector3(0.0, 18.0 * float(i - 1), 90.0))
		var lamp := PocketGeo.omni(self, pos + Vector3(0.0, -0.2, 0.0), Color(0.65, 0.95, 0.72), 2.8, 10.0)
		_lamps.append(lamp)
	PocketGeo.label(self, Vector3(0.0, 1.85, 0.2), "TUBES", Color(0.7, 0.95, 0.78), 38)
