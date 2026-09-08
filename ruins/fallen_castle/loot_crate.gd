class_name LootCrate
extends Area3D

## One-shot stub interact. No loot table — just a ruin beat.

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
		_build_visual()


func can_interact() -> bool:
	return not opened


func interact() -> bool:
	if opened:
		return false
	opened = true
	Game.banner("The crate is empty. The watch is long gone.")
	Game.set_prompt("")
	rotate_x(0.35)
	return true


func _on_body_entered(body: Node) -> void:
	if opened:
		return
	if body.is_in_group("player"):
		Game.set_prompt("E  —  search crate")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		Game.set_prompt("")


func _build_visual() -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.7, 0.55, 0.7)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.38, 0.26, 0.16)
	mat.roughness = 0.85
	mesh.material_override = mat
	add_child(mesh)
	var col := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 1.4
	col.shape = shape
	add_child(col)
