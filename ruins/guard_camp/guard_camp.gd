class_name GuardCamp
extends Node3D

## Cramped wooden guard-camp pocket. CampKit meshes. Enter from the tunnel.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")
const ENTER := preload("res://ruins/guard_camp/palisade_enter.tscn")
const TRIPOD := preload("res://ruins/guard_camp/tripod_central.tscn")
const LEAN_A := preload("res://ruins/guard_camp/lean_to_a.tscn")
const LEAN_B := preload("res://ruins/guard_camp/lean_to_b.tscn")
const PLANK := preload("res://ruins/guard_camp/guard_plank.tscn")
const CRATE := preload("res://ruins/guard_camp/crate_loot.tscn")
const TORCH := preload("res://ruins/guard_camp/torch_post.tscn")
const MIST := preload("res://ruins/guard_camp/mist_drop.tscn")

var player_spawn: Vector3 = Vector3(0.0, 1.05, 2.0)

@onready var geometry: Node3D = $Geometry
@onready var lights: Node3D = $Lights
@onready var markers: Node3D = $Markers
@onready var world_env: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	_style_environment()
	_build_yard()
	_build_palisade()
	_place_pieces()
	_place_markers()


func _style_environment() -> void:
	var sky := ProceduralSkyMaterial.new()
	sky.sky_top_color = Color(0.28, 0.32, 0.4)
	sky.sky_horizon_color = Color(0.62, 0.36, 0.32)
	sky.ground_bottom_color = Color(0.1, 0.08, 0.07)
	sky.ground_horizon_color = Color(0.32, 0.22, 0.16)
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.sky.sky_material = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.8
	env.fog_enabled = true
	env.fog_light_color = Color(0.36, 0.3, 0.28)
	env.fog_density = 0.018
	env.glow_enabled = true
	world_env.environment = env


func _build_yard() -> void:
	Kit.mud_ground(geometry, Vector3(0.0, 0.35, 7.2), Vector3(13.2, 0.7, 15.6))
	var path := MeshInstance3D.new()
	var strip := BoxMesh.new()
	strip.size = Vector3(1.8, 0.04, 12.0)
	path.mesh = strip
	var path_mat := Kit.mat("mud").duplicate() as StandardMaterial3D
	path_mat.albedo_color = Color(0.5, 0.4, 0.3)
	path.material_override = path_mat
	path.position = Vector3(0.0, 0.72, 7.0)
	geometry.add_child(path)
	for p in [Vector3(-2.0, 0.72, 4.2), Vector3(1.8, 0.72, 6.4), Vector3(-1.6, 0.72, 9.2), Vector3(2.1, 0.72, 11.0)]:
		Kit.grass_tuft(geometry, p)


func _build_palisade() -> void:
	var ring := Node3D.new()
	ring.name = "palisade_ring"
	add_child(ring)
	var logs := Node3D.new()
	logs.name = "palisade_log"
	ring.add_child(logs)
	Kit.palisade_run(logs, Vector3(-6.2, 0.7, 0.5), Vector3(-1.25, 0.7, 0.5), 2)
	Kit.palisade_run(logs, Vector3(1.25, 0.7, 0.5), Vector3(6.2, 0.7, 0.5), 3)
	Kit.palisade_run(logs, Vector3(-6.2, 0.7, 13.8), Vector3(-1.25, 0.7, 13.8), 4)
	Kit.palisade_run(logs, Vector3(1.25, 0.7, 13.8), Vector3(6.2, 0.7, 13.8), 5)
	Kit.palisade_run(logs, Vector3(-6.35, 0.7, 0.7), Vector3(-6.35, 0.7, 13.6), 6)
	Kit.palisade_run(logs, Vector3(6.35, 0.7, 0.7), Vector3(6.35, 0.7, 13.6), 7)


func _place_pieces() -> void:
	var enter: Node3D = ENTER.instantiate()
	enter.position = Vector3(0.0, 0.7, 0.65)
	add_child(enter)

	var tripod: Node3D = TRIPOD.instantiate()
	tripod.position = Vector3(0.0, 0.7, 6.6)
	add_child(tripod)

	var a: Node3D = LEAN_A.instantiate()
	a.position = Vector3(-3.3, 0.7, 5.3)
	a.rotation_degrees = Vector3(0.0, 22.0, 0.0)
	add_child(a)

	var torch: Node3D = TORCH.instantiate()
	torch.position = Vector3(-2.05, 0.7, 4.2)
	add_child(torch)

	var b: Node3D = LEAN_B.instantiate()
	b.position = Vector3(3.25, 0.7, 9.0)
	b.rotation_degrees = Vector3(0.0, -150.0, 0.0)
	add_child(b)

	var plank: Node3D = PLANK.instantiate()
	plank.position = Vector3(3.05, 0.7, 6.8)
	plank.rotation_degrees = Vector3(0.0, -10.0, 0.0)
	add_child(plank)

	var crate: Node3D = CRATE.instantiate()
	crate.position = Vector3(1.1, 0.95, 8.5)
	add_child(crate)

	var mist: Node3D = MIST.instantiate()
	mist.position = Vector3(0.0, 0.7, 13.75)
	add_child(mist)


func _place_markers() -> void:
	_marker("PlayerSpawn", player_spawn)
	_marker("palisade_log", Vector3(-6.35, 1.0, 7.0))
	_marker("palisade_ring", Vector3(0.0, 1.0, 7.0))
	_marker("palisade_enter", Vector3(0.0, 1.0, 0.65))
	_marker("tripod_central", Vector3(0.0, 1.0, 6.6))
	_marker("lean_to_a", Vector3(-3.3, 1.0, 5.3))
	_marker("lean_to_b", Vector3(3.25, 1.0, 9.0))
	_marker("guard_plank", Vector3(3.05, 1.0, 6.8))
	_marker("crate_loot", Vector3(1.1, 1.0, 8.5))
	_marker("torch_post", Vector3(-2.05, 1.0, 4.2))
	_marker("mist_drop", Vector3(0.0, 1.0, 13.75))


func _marker(marker_name: String, pos: Vector3) -> void:
	var m := Marker3D.new()
	m.name = marker_name
	m.position = pos
	markers.add_child(m)
