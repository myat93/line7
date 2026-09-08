class_name CrateLoot
extends Area3D

## Optional stub loot. Skip for a faster exit. Bandage + scrap, one-shot.

const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const IRON := preload("res://ruins/guard_camp/materials/iron.tres")
const ROPE := preload("res://ruins/guard_camp/materials/rope.tres")

const LOOT := "A linen wrap and a scrap of watch brass.\nThe crate is picked clean."
const HEAL := 12

var opened: bool = false


func _ready() -> void:
	name = "crate_loot"
	collision_layer = Combat.LAYER_INTERACT
	collision_mask = Combat.LAYER_PLAYER
	monitoring = true
	monitorable = true
	add_to_group("interactable")
	add_to_group("crate_loot")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_build()
	if get_node_or_null("CollisionShape3D") == null:
		var col := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = 1.35
		col.shape = shape
		add_child(col)


func can_interact() -> bool:
	return not opened


func interact() -> bool:
	if opened:
		return false
	opened = true
	Game.camp_loot_taken = true
	Game.set_prompt("")
	var he := Game.player
	if he and "hp" in he:
		he.hp = mini(int(he.hp) + HEAL, Combat.PLAYER_MAX_HP)
		Game.hud_dirty.emit()
	Game.banner(LOOT, 4.0)
	var lid := get_node_or_null("Lid") as Node3D
	if lid:
		lid.rotation_degrees.x = -70.0
		lid.position.y += 0.12
		lid.position.z -= 0.18
	return true


func _on_body_entered(body: Node) -> void:
	if opened:
		return
	if body.is_in_group("player"):
		Game.set_prompt("E  —  search crate")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		Game.set_prompt("")


func _build() -> void:
	PocketGeo.box(self, Vector3(0.0, -0.12, 0.0), Vector3(0.68, 0.46, 0.58), BOARD, true)
	PocketGeo.box(self, Vector3(0.0, -0.12, 0.0), Vector3(0.7, 0.07, 0.6), BARK, false)
	PocketGeo.box(self, Vector3(0.0, 0.05, 0.0), Vector3(0.72, 0.04, 0.62), IRON, false)
	CampProp.rope_wrap(self, Vector3(0.0, -0.12, 0.0), 0.34, ROPE)
	var lid := MeshInstance3D.new()
	lid.name = "Lid"
	var box := BoxMesh.new()
	box.size = Vector3(0.7, 0.05, 0.6)
	lid.mesh = box
	lid.material_override = BOARD
	lid.position = Vector3(0.0, 0.14, 0.0)
	add_child(lid)
	PocketGeo.box(self, Vector3(0.62, -0.18, 0.16), Vector3(0.42, 0.28, 0.38), BARK, true)
	PocketGeo.label(self, Vector3(0.12, 0.62, 0.0), "CRATE", Color(0.86, 0.72, 0.48), 22)
	PocketGeo.omni(self, Vector3(0.1, 0.8, 0.15), Color(0.85, 0.58, 0.3), 0.8, 4.0)
