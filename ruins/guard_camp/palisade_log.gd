class_name PalisadeLog
extends Node3D

## One jagged, rope-lashed palisade stake from CampKit.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")

@export var log_height: float = 2.6
@export var lean: float = 0.0


func _ready() -> void:
	if not name.begins_with("palisade_log"):
		name = "palisade_log"
	add_to_group("palisade_log")
	Kit.add_log(self, Vector3.ZERO, log_height, 0.13, 0.0, lean)
