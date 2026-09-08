class_name LootCrate
extends Area3D

## Searchable crate under the lean-to. Wood mesh, not a grey cube.

var opened: bool = false


func _ready() -> void:
	collision_layer = Combat.LAYER_INTERACT
	collision_mask = Combat.LAYER_PLAYER
	monitoring = true
	monitorable = true
	add_to_group("interactable")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if get_child_count() == 0:
		preload("res://ruins/fallen_castle/camp_kit.gd").crate(self, Vector3.ZERO, Vector3(0.72, 0.52, 0.7), 8.0)
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
	Game.banner("The crate is empty. The watch is long gone.")
	Game.set_prompt("")
	rotate_z(0.4)
	return true


func _on_body_entered(body: Node) -> void:
	if opened:
		return
	if body.is_in_group("player"):
		Game.set_prompt("E  —  search crate")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		Game.set_prompt("")
