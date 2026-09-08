class_name MistDrop
extends Node3D

## Far palisade gap. Look-only purple forest drop. No softlock.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")
const MIST := preload("res://ruins/guard_camp/materials/mist.tres")


func _ready() -> void:
	name = "mist_drop"
	add_to_group("mist_drop")
	Kit.timber_gate(self, Vector3.ZERO, 0.0)
	Kit.plank_ramp(self, Vector3(0.0, 0.12, 0.85), Vector3(2.3, 0.14, 1.9), 0.0, 0.0)
	PocketGeo.box(self, Vector3(0.0, 0.22, 1.85), Vector3(2.6, 0.22, 0.28), Kit.mat("bark"), true)
	var sheet := MIST.duplicate() as StandardMaterial3D
	sheet.albedo_color = Color(0.62, 0.40, 0.56, 0.36)
	var deep := MIST.duplicate() as StandardMaterial3D
	deep.albedo_color = Color(0.48, 0.26, 0.44, 0.28)
	PocketGeo.box(self, Vector3(0.0, 1.65, 2.35), Vector3(6.4, 3.2, 0.55), sheet, false)
	PocketGeo.box(self, Vector3(0.0, 1.85, 4.15), Vector3(10.5, 4.0, 0.8), deep, false)
	for xz in [
		Vector3(-1.7, 0.0, 3.2), Vector3(0.15, 0.0, 3.7), Vector3(1.55, 0.0, 3.35),
		Vector3(-0.85, 0.0, 4.4), Vector3(2.35, 0.0, 4.8), Vector3(-2.4, 0.0, 4.6),
	]:
		Kit.add_log(self, xz, 3.35 + xz.x * 0.12, 0.16, 8.0, 1.6)
	PocketGeo.label(self, Vector3(0.0, 1.95, 1.15), "MIST", Color(0.78, 0.58, 0.74), 30)
