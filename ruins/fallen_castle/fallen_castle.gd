class_name FallenCastle
extends Node3D

## Exploration pocket: fallen keep, three guard posts, rubble climb. No enemy.

const STONE := preload("res://ruins/fallen_castle/materials/ruin_stone.tres")
const KEEP := preload("res://ruins/fallen_castle/materials/keep_stone.tres")
const ANGEL := preload("res://ruins/line7_undercroft/materials/angel_stone.tres")
const GATE := preload("res://core/area_gate.gd")
const CRATE := preload("res://ruins/fallen_castle/loot_crate.gd")

var player_spawn: Vector3 = Vector3(0.0, 1.15, 3.2)

@onready var geometry: Node3D = $Geometry
@onready var lights: Node3D = $Lights
@onready var markers: Node3D = $Markers
@onready var world_env: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	_style_environment()
	_build_ground()
	_build_keep()
	_build_guard_posts()
	_build_climb()
	_place_crate()
	_place_return_gate()
	_place_markers()


func _style_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.045, 0.04)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.22, 0.18, 0.16)
	env.ambient_light_energy = 0.7
	env.fog_enabled = true
	env.fog_light_color = Color(0.2, 0.16, 0.14)
	env.fog_density = 0.01
	env.glow_enabled = true
	world_env.environment = env


func _build_ground() -> void:
	_box(geometry, Vector3(0, 0.4, 16), Vector3(38, 0.8, 40), STONE, true)
	## Outer rubble walls (collapsed, with gaps).
	_box(geometry, Vector3(-18.4, 2.4, 16), Vector3(1.4, 4.0, 40), KEEP, true)
	_box(geometry, Vector3(18.4, 2.4, 16), Vector3(1.4, 4.0, 40), KEEP, true)
	_box(geometry, Vector3(0, 2.6, -3.4), Vector3(38, 4.4, 1.4), KEEP, true)
	_box(geometry, Vector3(-8, 2.2, 35.6), Vector3(22, 3.6, 1.4), KEEP, true)
	_box(geometry, Vector3(12, 1.4, 35.4), Vector3(8, 2.0, 1.2), KEEP, true)
	var dirt := STONE.duplicate() as StandardMaterial3D
	dirt.albedo_color = Color(0.2, 0.18, 0.14)
	_box(geometry, Vector3(0, 0.15, 16), Vector3(36, 0.2, 38), dirt, false)
	_torch(Vector3(0, 4.8, 6), Color(1.0, 0.7, 0.4), 2.2)


func _build_keep() -> void:
	## Slumped keep — readable blockout of a fallen castle.
	_box(geometry, Vector3(0, 3.2, 26.5), Vector3(12, 5.2, 8), KEEP, true)
	_box(geometry, Vector3(-3.4, 5.8, 24.2), Vector3(4.5, 1.6, 3.2), KEEP, true)
	_box(geometry, Vector3(4.2, 2.4, 22.4), Vector3(3.4, 2.2, 3.6), KEEP, true)
	_box(geometry, Vector3(2.8, 1.4, 20.2), Vector3(2.4, 1.2, 2.2), STONE, true)
	## Broken tower lean.
	var lean := StaticBody3D.new()
	lean.position = Vector3(-5.6, 4.6, 28.4)
	lean.rotation_degrees = Vector3(0, 12, -18)
	lean.collision_layer = Combat.LAYER_WORLD
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.4, 7.2, 2.4)
	mesh.mesh = box
	mesh.material_override = KEEP
	lean.add_child(mesh)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box.size
	col.shape = shape
	lean.add_child(col)
	geometry.add_child(lean)
	## Interior dais.
	_box(geometry, Vector3(0, 1.15, 26.4), Vector3(5.5, 0.5, 4.2), STONE, true)
	_label(Vector3(0, 3.4, 22.6), "FALLEN KEEP")
	_torch(Vector3(-4.2, 5.2, 24.0), Color(1.0, 0.55, 0.28), 2.8)
	_torch(Vector3(4.2, 4.4, 24.0), Color(1.0, 0.55, 0.28), 2.4)


func _build_guard_posts() -> void:
	_guard_post(Vector3(0, 0, 7.2), "GATEHOUSE")
	_guard_post(Vector3(-11.5, 0, 16.5), "WEST WATCH")
	_guard_post(Vector3(11.5, 0, 16.5), "EAST WATCH")


func _guard_post(origin: Vector3, title: String) -> void:
	_box(geometry, origin + Vector3(0, 1.6, 0), Vector3(3.2, 2.4, 3.2), KEEP, true)
	_box(geometry, origin + Vector3(0, 3.15, 0), Vector3(3.6, 0.35, 3.6), STONE, true)
	_box(geometry, origin + Vector3(-1.3, 2.6, -1.3), Vector3(0.35, 1.8, 0.35), KEEP, true)
	_box(geometry, origin + Vector3(1.3, 2.6, -1.3), Vector3(0.35, 1.8, 0.35), KEEP, true)
	_box(geometry, origin + Vector3(-1.3, 2.6, 1.3), Vector3(0.35, 1.8, 0.35), KEEP, true)
	_box(geometry, origin + Vector3(1.3, 2.6, 1.3), Vector3(0.35, 1.8, 0.35), KEEP, true)
	_label(origin + Vector3(0, 3.7, 0), title)
	_torch(origin + Vector3(0, 4.3, 0), Color(1.0, 0.72, 0.38), 2.0)


func _build_climb() -> void:
	## Rubble stair from courtyard to keep wall-walk so jump/sprint matter.
	var steps := [
		Vector3(-2.2, 0.95, 12.4),
		Vector3(-1.4, 1.45, 13.6),
		Vector3(-0.6, 1.95, 14.8),
		Vector3(0.2, 2.45, 16.0),
		Vector3(0.8, 2.95, 17.4),
		Vector3(0.4, 3.45, 18.8),
	]
	for pos in steps:
		_box(geometry, pos, Vector3(2.4, 0.45, 1.6), STONE, true)
	_box(geometry, Vector3(0.2, 3.7, 20.4), Vector3(4.8, 0.4, 2.4), KEEP, true)
	_box(geometry, Vector3(-6.5, 1.2, 12.8), Vector3(2.0, 0.7, 1.8), STONE, true)
	_box(geometry, Vector3(6.8, 1.35, 13.2), Vector3(1.8, 0.9, 1.6), STONE, true)


func _place_crate() -> void:
	var crate := Area3D.new()
	crate.set_script(CRATE)
	crate.position = Vector3(0.6, 1.55, 26.6)
	add_child(crate)


func _place_return_gate() -> void:
	_box(geometry, Vector3(-1.15, 2.1, 1.15), Vector3(0.35, 2.4, 0.35), ANGEL, true)
	_box(geometry, Vector3(1.15, 2.1, 1.15), Vector3(0.35, 2.4, 0.35), ANGEL, true)
	_box(geometry, Vector3(0, 3.35, 1.15), Vector3(2.6, 0.28, 0.35), ANGEL, true)
	_label(Vector3(0, 2.6, 1.6), "LINE 7")
	var gate := Area3D.new()
	gate.set_script(GATE)
	gate.destination = "undercroft"
	gate.prompt_text = "E  —  return to Line 7"
	gate.arrive_banner = "LINE 7 — UNDERCROFT"
	gate.position = Vector3(0.0, 1.2, 1.3)
	add_child(gate)
	_torch(Vector3(0, 3.6, 1.2), Color(0.55, 0.85, 0.9), 2.4)


func _place_markers() -> void:
	_marker("PlayerSpawn", player_spawn)
	_marker("Gatehouse", Vector3(0, 1, 7.2))
	_marker("WestWatch", Vector3(-11.5, 1, 16.5))
	_marker("EastWatch", Vector3(11.5, 1, 16.5))
	_marker("Keep", Vector3(0, 1, 26.5))


func _marker(marker_name: String, pos: Vector3) -> void:
	var m := Marker3D.new()
	m.name = marker_name
	m.position = pos
	markers.add_child(m)


func _label(pos: Vector3, text: String) -> void:
	var plaque := Label3D.new()
	plaque.text = text
	plaque.font_size = 42
	plaque.position = pos
	plaque.modulate = Color(0.88, 0.78, 0.58)
	geometry.add_child(plaque)


func _torch(pos: Vector3, color: Color, energy: float) -> void:
	var lamp := OmniLight3D.new()
	lamp.position = pos
	lamp.light_color = color
	lamp.light_energy = energy
	lamp.omni_range = 11.0
	lamp.shadow_enabled = true
	lights.add_child(lamp)


func _box(parent: Node, pos: Vector3, size: Vector3, mat: Material, collide: bool) -> void:
	if collide:
		var body := StaticBody3D.new()
		body.position = pos
		body.collision_layer = Combat.LAYER_WORLD
		body.collision_mask = 0
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = size
		mesh.mesh = box
		mesh.material_override = mat
		body.add_child(mesh)
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		col.shape = shape
		body.add_child(col)
		parent.add_child(body)
	else:
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = size
		mesh.mesh = box
		mesh.material_override = mat
		mesh.position = pos
		parent.add_child(mesh)
