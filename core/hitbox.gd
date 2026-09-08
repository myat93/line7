class_name Hitbox
extends Area3D

signal landed(hurtbox: Hurtbox)

var damage: int = 0
var knockback: float = 0.0
var team: StringName = &"player"
var source: Node3D
var _hit_ids: Dictionary = {}


func _ready() -> void:
	monitoring = false
	monitorable = false
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func arm(p_damage: int, p_knockback: float, p_team: StringName, p_source: Node3D) -> void:
	damage = p_damage
	knockback = p_knockback
	team = p_team
	source = p_source
	_hit_ids.clear()
	monitoring = true


func disarm() -> void:
	monitoring = false
	_hit_ids.clear()


func _on_body_entered(body: Node) -> void:
	if body is Hurtbox:
		_try_hit(body)
	elif body.has_method("get_hurtbox"):
		var box: Variant = body.get_hurtbox()
		if box is Hurtbox:
			_try_hit(box)
	elif body.has_method("take_hit"):
		var id := body.get_instance_id()
		if _hit_ids.has(id):
			return
		_hit_ids[id] = true
		var from := Vector3.ZERO
		if source:
			from = source.global_position
		body.take_hit(damage, knockback, from)


func _on_area_entered(area: Area3D) -> void:
	if area is Hurtbox:
		_try_hit(area)


func _try_hit(hurt: Hurtbox) -> void:
	if hurt.team == team:
		return
	var id := hurt.get_instance_id()
	if _hit_ids.has(id):
		return
	_hit_ids[id] = true
	var from := Vector3.ZERO
	if source:
		from = source.global_position
	hurt.receive_hit(damage, knockback, from)
	landed.emit(hurt)
