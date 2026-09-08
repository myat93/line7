class_name CrateLoot
extends Area3D

## Optional stub loot. Visual is CampKit crate + barrel.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")

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
	Kit.crate(self, Vector3(0.0, 0.0, 0.0), Vector3(0.7, 0.5, 0.62), 8.0)
	Kit.crate(self, Vector3(0.58, -0.04, 0.18), Vector3(0.45, 0.32, 0.4), -16.0)
	Kit.barrel(self, Vector3(-0.55, -0.22, 0.12))
	PocketGeo.label(self, Vector3(0.12, 0.72, 0.0), "CRATE", Color(0.86, 0.72, 0.48), 22)
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
	return true


func _on_body_entered(body: Node) -> void:
	if opened:
		return
	if body.is_in_group("player"):
		Game.set_prompt("E  —  search crate")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		Game.set_prompt("")
