class_name TorchPost
extends Node3D

## PBR lantern post. Light is still a scene OmniLight (mesh is unlit).

func _ready() -> void:
	name = "torch_post"
	add_to_group("torch_post")
	RealisticCamp.add(self, "res://ruins/guard_camp/meshes/torch_post_realistic.glb")
	PocketGeo.omni(self, Vector3(0.0, 2.1, 0.0), Color(1.0, 0.62, 0.32), 2.6, 9.0)
	PocketGeo.label(self, Vector3(0.1, 2.45, 0.0), "TORCH", Color(1.0, 0.72, 0.4), 20)
