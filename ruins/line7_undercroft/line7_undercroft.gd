class_name Line7Undercroft
extends Node3D

## Flooded subway chapel: spawn wake → mid-platform duel → angel-stone shrine.

const CONCRETE := preload("res://ruins/line7_undercroft/materials/concrete.tres")
const WATER := preload("res://ruins/line7_undercroft/materials/water.tres")
const ANGEL := preload("res://ruins/line7_undercroft/materials/angel_stone.tres")
const PICKUP := preload("res://weapons/ashpike/ashpike_pickup.tscn")

var player_spawn: Vector3 = Vector3(0, 1.05, 0)
var herald_spawn: Vector3 = Vector3(0, 1.05, 18.5)
var shrine_pos: Vector3 = Vector3(0, 1.05, 36.8)

@onready var geometry: Node3D = $Geometry
@onready var lights: Node3D = $Lights
@onready var markers: Node3D = $Markers
@onready var world_env: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	_style_environment()
	_build_volume()
	_build_loop()
	_build_angel_stone()
	_place_pickup()
	_place_markers()


func _style_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.035, 0.045, 0.055)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.16, 0.2, 0.24)
	env.ambient_light_energy = 0.42
	env.fog_enabled = true
	env.fog_light_color = Color(0.1, 0.16, 0.18)
	env.fog_density = 0.02
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.035
	env.volumetric_fog_albedo = Color(0.16, 0.22, 0.24)
	env.glow_enabled = true
	env.glow_intensity = 0.45
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.92
	world_env.environment = env


func _build_volume() -> void:
	_box(geometry, Vector3(0, -0.2, 20), Vector3(22, 0.4, 56), WATER, false)
	_box(geometry, Vector3(-8.4, 4.2, 20), Vector3(1.2, 10, 56), CONCRETE, true)
	_box(geometry, Vector3(8.4, 4.2, 20), Vector3(1.2, 10, 56), CONCRETE, true)
	_box(geometry, Vector3(0, 8.8, 20), Vector3(18, 0.6, 56), CONCRETE, true)
	_box(geometry, Vector3(0, 3.5, -7.2), Vector3(18, 8, 1.2), CONCRETE, true)
	_box(geometry, Vector3(0, 3.5, 47.2), Vector3(18, 8, 1.2), CONCRETE, true)
	var rail := CONCRETE.duplicate() as StandardMaterial3D
	rail.albedo_color = Color(0.12, 0.12, 0.13)
	rail.metallic = 0.7
	rail.roughness = 0.4
	_box(geometry, Vector3(-3.4, 0.55, 20), Vector3(0.12, 0.12, 50), rail, false)
	_box(geometry, Vector3(3.4, 0.55, 20), Vector3(0.12, 0.12, 50), rail, false)
	for z in [4.0, 12.0, 20.0, 28.0, 36.0]:
		_box(geometry, Vector3(-6.6, 2.4, z), Vector3(0.7, 5.2, 0.7), CONCRETE, true)
		_box(geometry, Vector3(6.6, 2.4, z), Vector3(0.7, 5.2, 0.7), CONCRETE, true)
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(0, 5.6, z)
		lamp.light_color = Color(0.72, 0.78, 0.7)
		lamp.light_energy = 1.15
		lamp.omni_range = 9.0
		lamp.shadow_enabled = true
		lights.add_child(lamp)


func _build_loop() -> void:
	var tile := CONCRETE.duplicate() as StandardMaterial3D
	tile.albedo_color = Color(0.28, 0.27, 0.26)
	## Spawn wake platform.
	_box(geometry, Vector3(0, 0.5, 0), Vector3(8.5, 1.0, 8.5), tile, true)
	_box(geometry, Vector3(0, 0.95, -2.4), Vector3(3.2, 0.18, 1.4), tile, true)
	var wake := MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = 0.9
	ring.outer_radius = 1.35
	wake.mesh = ring
	wake.position = Vector3(0, 0.42, 1.6)
	var wake_mat := StandardMaterial3D.new()
	wake_mat.albedo_color = Color(0.35, 0.7, 0.72, 0.5)
	wake_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wake_mat.emission_enabled = true
	wake_mat.emission = Color(0.2, 0.55, 0.58)
	wake_mat.emission_energy_multiplier = 1.4
	wake.material_override = wake_mat
	wake.name = "SpawnWake"
	geometry.add_child(wake)
	## Walkway to the duel floor.
	_box(geometry, Vector3(0, 0.45, 8.2), Vector3(3.4, 0.9, 8.2), tile, true)
	## Mid-platform duel.
	_box(geometry, Vector3(0, 0.5, 18.5), Vector3(13.5, 1.0, 12.5), tile, true)
	_box(geometry, Vector3(-4.8, 1.15, 22.4), Vector3(2.2, 0.3, 1.4), tile, true)
	_box(geometry, Vector3(4.8, 1.15, 22.4), Vector3(2.2, 0.3, 1.4), tile, true)
	## Walkway to shrine.
	_box(geometry, Vector3(0, 0.45, 28.6), Vector3(3.2, 0.9, 8.0), tile, true)
	## Shrine dais.
	_box(geometry, Vector3(0, 0.55, 36.8), Vector3(10.5, 1.1, 10.0), tile, true)
	_box(geometry, Vector3(0, 1.25, 38.4), Vector3(4.4, 0.35, 3.6), ANGEL, true)


func _build_angel_stone() -> void:
	_box(geometry, Vector3(0, 2.4, 38.6), Vector3(0.7, 2.4, 0.55), ANGEL, true)
	_box(geometry, Vector3(0, 3.55, 38.6), Vector3(0.85, 0.55, 0.7), ANGEL, true)
	_box(geometry, Vector3(-1.15, 2.85, 38.6), Vector3(1.6, 0.18, 0.28), ANGEL, true)
	_box(geometry, Vector3(1.15, 2.85, 38.6), Vector3(1.6, 0.18, 0.28), ANGEL, true)
	var glow := OmniLight3D.new()
	glow.position = Vector3(0, 3.3, 37.4)
	glow.light_color = Color(1.0, 0.86, 0.55)
	glow.light_energy = 3.4
	glow.omni_range = 10.0
	glow.shadow_enabled = true
	glow.name = "AngelGlow"
	lights.add_child(glow)
	var plaque := Label3D.new()
	plaque.text = "ASHPIKE"
	plaque.font_size = 48
	plaque.position = Vector3(0, 1.7, 36.2)
	plaque.modulate = Color(0.92, 0.84, 0.62)
	geometry.add_child(plaque)


func _place_pickup() -> void:
	var pickup: Node3D = PICKUP.instantiate()
	pickup.position = Vector3(0.85, 1.55, 37.15)
	add_child(pickup)


func _place_markers() -> void:
	_marker("PlayerSpawn", player_spawn)
	_marker("HeraldSpawn", herald_spawn)
	_marker("Shrine", shrine_pos)


func _marker(marker_name: String, pos: Vector3) -> void:
	var m := Marker3D.new()
	m.name = marker_name
	m.position = pos
	markers.add_child(m)


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
