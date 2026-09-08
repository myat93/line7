class_name AshpikePickup
extends Area3D

## Shrine-only pickup. Taken with E, stays unequipped until bind (1).

@onready var mesh_anchor: Node3D = $MeshAnchor

var taken: bool = false


func _ready() -> void:
	collision_layer = Combat.LAYER_INTERACT
	collision_mask = Combat.LAYER_PLAYER
	monitoring = true
	monitorable = true
	add_to_group("interactable")
	Game.shrine_pickup = self
	if mesh_anchor.get_child_count() == 0:
		var visual := Ashpike.make_mesh()
		visual.rotation_degrees = Vector3(18, 0, -12)
		mesh_anchor.add_child(visual)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if taken:
		return
	rotate_y(delta * 0.35)
	mesh_anchor.position.y = 0.15 + sin(Time.get_ticks_msec() * 0.002) * 0.05


func can_interact() -> bool:
	return not taken


func interact() -> bool:
	if taken:
		return false
	if Game.take_ashpike():
		taken = true
		visible = false
		monitoring = false
		Game.near_shrine = false
		return true
	return false


func _on_body_entered(body: Node) -> void:
	if taken:
		return
	if body.is_in_group("player"):
		Game.near_shrine = true
		Game.set_prompt("E  —  take Ashpike")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		Game.near_shrine = false
		Game.set_prompt("")
