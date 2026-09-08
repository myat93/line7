class_name MistDrop
extends Node3D

## Far palisade gap. Look-only mist / forest drop.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")
const MIST := preload("res://ruins/guard_camp/materials/mist.tres")


func _ready() -> void:
	name = "mist_drop"
	add_to_group("mist_drop")
	Kit.timber_gate(self, Vector3.ZERO, 0.0)
	Kit.plank_ramp(self, Vector3(0.0, 0.12, 0.85), Vector3(2.3, 0.14, 1.9), 0.0, 0.0)
	PocketGeo.box(self, Vector3(0.0, 0.3, 1.75), Vector3(2.4, 0.26, 0.2), Kit.mat("bark"), true)
	PocketGeo.box(self, Vector3(0.0, 1.7, 2.15), Vector3(4.2, 3.4, 0.65), MIST, true)
	for xz in [Vector3(-1.6, 0.0, 3.4), Vector3(0.2, 0.0, 3.8), Vector3(1.5, 0.0, 3.5), Vector3(-0.7, 0.0, 4.2)]:
		Kit.add_log(self, xz, 3.2 + xz.x * 0.2, 0.18, 10.0, 2.0)
	PocketGeo.label(self, Vector3(0.0, 1.95, 1.15), "MIST", Color(0.72, 0.84, 0.86), 30)
