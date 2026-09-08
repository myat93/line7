class_name PalisadeLog
extends Node3D

## One jagged, rope-lashed palisade stake. The ring instances these.

const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const ROPE := preload("res://ruins/guard_camp/materials/rope.tres")

@export var log_height: float = 2.6
@export var lean: Vector3 = Vector3.ZERO


func _ready() -> void:
	if not name.begins_with("palisade_log"):
		name = "palisade_log"
	add_to_group("palisade_log")
	_build()


func _build() -> void:
	var top := 0.07 + fmod(log_height, 0.11)
	CampProp.tapered_log(self, Vector3(0.0, log_height * 0.5, 0.0), 0.16, top, log_height, BARK, true, lean)
	CampProp.rope_wrap(self, Vector3(0.0, log_height * 0.62, 0.0), 0.17, ROPE)
	## Split tip so the stake reads as a cut log, not a grey post.
	PocketGeo.box(self, Vector3(0.02, log_height + 0.06, 0.0), Vector3(0.05, 0.16, 0.12), BARK, false)
