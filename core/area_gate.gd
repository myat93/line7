class_name AreaGate
extends Area3D

## In-world pocket door. E travels; Game keeps combat/shrine state.

@export var destination: String = "fallen_castle"
@export var prompt_text: String = "E  —  enter the ruins"
@export var arrive_banner: String = ""


func _ready() -> void:
	collision_layer = Combat.LAYER_INTERACT
	collision_mask = Combat.LAYER_PLAYER
	monitoring = true
	monitorable = true
	add_to_group("interactable")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if get_node_or_null("CollisionShape3D") == null:
		var col := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = 1.7
		col.shape = shape
		add_child(col)


func can_interact() -> bool:
	return true


func interact() -> bool:
	Game.set_prompt("")
	if not arrive_banner.is_empty():
		Game.banner(arrive_banner)
	Game.travel_to(destination)
	return true


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		Game.set_prompt(prompt_text)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		Game.set_prompt("")
