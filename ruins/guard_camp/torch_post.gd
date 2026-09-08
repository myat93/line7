class_name TorchPost
extends Node3D

## CampKit brazier post.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")


func _ready() -> void:
	name = "torch_post"
	add_to_group("torch_post")
	var lamps := Node3D.new()
	add_child(lamps)
	Kit.torch_post(self, Vector3.ZERO, lamps)
	PocketGeo.label(self, Vector3(0.1, 2.45, 0.0), "TORCH", Color(1.0, 0.72, 0.4), 20)
