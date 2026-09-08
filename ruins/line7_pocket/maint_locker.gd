class_name MaintLocker
extends Area3D

## Landmark C — maintenance locker. E once for stub loot (note or wrap).

const RUST := preload("res://ruins/line7_pocket/materials/rust_metal.tres")
const TILE := preload("res://ruins/line7_pocket/materials/tile.tres")

const NOTE := "SERVICE LOG\nAshpike still rests on the angel stone.\nTake it. Bind with 1."
const KIT := "A dry wrap from the locker. You bind a cut."
const KIT_HEAL := 16

var opened: bool = false


func _ready() -> void:
	name = "maint_locker"
	collision_layer = Combat.LAYER_INTERACT
	collision_mask = Combat.LAYER_PLAYER
	monitoring = true
	monitorable = true
	add_to_group("interactable")
	add_to_group("maint_locker")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_build()
	if get_node_or_null("CollisionShape3D") == null:
		var col := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = 1.5
		col.shape = shape
		add_child(col)


func can_interact() -> bool:
	return not opened


func interact() -> bool:
	if opened:
		return false
	opened = true
	Game.set_prompt("")
	if Game.ashpike_taken:
		_give_kit()
	else:
		Game.banner(NOTE, 5.0)
		Game.pocket_note_taken = true
	_crack_door()
	return true


func _give_kit() -> void:
	Game.pocket_kit_taken = true
	var he := Game.player
	if he and "hp" in he:
		he.hp = mini(int(he.hp) + KIT_HEAL, Combat.PLAYER_MAX_HP)
		Game.hud_dirty.emit()
	Game.banner(KIT, 3.6)


func _crack_door() -> void:
	var door := get_node_or_null("Door") as Node3D
	if door:
		door.rotation_degrees.y = 55.0


func _on_body_entered(body: Node) -> void:
	if opened:
		return
	if body.is_in_group("player"):
		Game.set_prompt("E  —  search locker")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		Game.set_prompt("")


func _build() -> void:
	PocketGeo.box(self, Vector3(0.0, -0.7, -0.4), Vector3(3.2, 0.96, 3.4), TILE, true)
	PocketGeo.box(self, Vector3(0.0, 0.55, 0.05), Vector3(1.15, 1.85, 0.55), RUST, true)
	var door := MeshInstance3D.new()
	door.name = "Door"
	var box := BoxMesh.new()
	box.size = Vector3(1.05, 1.7, 0.06)
	door.mesh = box
	door.material_override = RUST
	door.position = Vector3(0.0, 0.55, 0.34)
	add_child(door)
	PocketGeo.box(self, Vector3(0.42, 0.5, 0.4), Vector3(0.08, 0.16, 0.08), TILE, false)
	PocketGeo.label(self, Vector3(0.0, 1.65, 0.45), "LOCKER", Color(0.78, 0.72, 0.58), 32)
	PocketGeo.omni(self, Vector3(0.0, 1.8, 0.6), Color(0.85, 0.7, 0.45), 1.4, 5.5)
