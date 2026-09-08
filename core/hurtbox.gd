class_name Hurtbox
extends Area3D

signal hit_received(damage: int, knockback: float, from: Vector3)

@export var team: StringName = &"player"
var host: Node


func _ready() -> void:
	monitorable = true
	monitoring = false
	collision_layer = Combat.LAYER_HURT
	collision_mask = 0


func receive_hit(damage: int, knockback: float, from: Vector3) -> void:
	hit_received.emit(damage, knockback, from)
	if host and host.has_method("take_hit"):
		host.take_hit(damage, knockback, from)
