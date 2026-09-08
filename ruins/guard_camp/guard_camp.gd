class_name GuardCamp
extends Node3D

## Wooden guard-camp pocket. Enter from the tunnel far end. No enemy.

const ENTER := preload("res://ruins/guard_camp/palisade_enter.tscn")
const TRIPOD := preload("res://ruins/guard_camp/camp_tripod.tscn")
const LEAN := preload("res://ruins/guard_camp/lean_to_shelter.tscn")
const PLANK := preload("res://ruins/guard_camp/guard_plank.tscn")
const CRATE := preload("res://ruins/guard_camp/camp_crate.tscn")
const MIST := preload("res://ruins/guard_camp/mist_exit.tscn")
const BARK := preload("res://ruins/guard_camp/materials/wood_bark.tres")
const BOARD := preload("res://ruins/guard_camp/materials/wood_board.tres")
const DIRT := preload("res://ruins/guard_camp/materials/dirt.tres")

## Dirt top is y = 0.8. Pieces sit on that plane.
var player_spawn: Vector3 = Vector3(0.0, 1.0, 2.6)

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
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.07, 0.08, 0.09)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.28, 0.24, 0.18)
	env.ambient_light_energy = 0.62
	env.fog_enabled = true
	env.fog_light_color = Color(0.42, 0.46, 0.48)
	env.fog_density = 0.022
	env.glow_enabled = true
	env.glow_intensity = 0.28
	world_env.environment = env


func _build_yard() -> void:
	## Packed dirt — not a featureless grey slab.
	PocketGeo.box(geometry, Vector3(0.0, 0.4, 12.2), Vector3(20.0, 0.8, 26.0), DIRT, true)
	var path := BOARD.duplicate() as StandardMaterial3D
	path.albedo_color = Color(0.34, 0.26, 0.16)
	PocketGeo.box(geometry, Vector3(0.0, 0.82, 11.5), Vector3(2.4, 0.06, 20.0), path, false)
	PocketGeo.omni(lights, Vector3(0.0, 4.2, 8.0), Color(1.0, 0.72, 0.42), 1.6, 16.0)
	PocketGeo.omni(lights, Vector3(-5.0, 3.2, 16.0), Color(0.85, 0.55, 0.3), 1.1, 10.0)
	PocketGeo.omni(lights, Vector3(5.2, 3.2, 13.0), Color(0.85, 0.55, 0.3), 1.1, 10.0)


func _build_palisade() -> void:
	## South wall, enter gap around x=0 / z=0.4.
	_log_run(Vector3(-9.6, 0.0, 0.45), Vector3(-1.55, 0.0, 0.45), 0.4)
	_log_run(Vector3(1.55, 0.0, 0.45), Vector3(9.6, 0.0, 0.45), 0.4)
	## North wall, mist gap around x=0 / z=23.6.
	_log_run(Vector3(-9.6, 0.0, 23.6), Vector3(-1.55, 0.0, 23.6), 0.4)
	_log_run(Vector3(1.55, 0.0, 23.6), Vector3(9.6, 0.0, 23.6), 0.4)
	## Sides.
	_log_run(Vector3(-9.8, 0.0, 0.6), Vector3(-9.8, 0.0, 23.4), 0.42)
	_log_run(Vector3(9.8, 0.0, 0.6), Vector3(9.8, 0.0, 23.4), 0.42)


func _log_run(from: Vector3, to: Vector3, spacing: float) -> void:
	var delta := to - from
	var length := delta.length()
	if length < 0.01:
		return
	var count := maxi(int(round(length / spacing)), 1)
	for i in count + 1:
		var t := float(i) / float(count)
		var pos := from.lerp(to, t)
		var h := 2.45 + fmod(float(i) * 0.41, 0.5)
		var lean := Vector3(0.0, 0.0, (float(i % 3) - 1.0) * 2.2)
		PocketGeo.cylinder(geometry, pos + Vector3(0.0, h * 0.5 + 0.05, 0.0), 0.15, h, BARK, true, lean)


func _place_pieces() -> void:
	var enter: Node3D = ENTER.instantiate()
	enter.position = Vector3(0.0, 0.8, 0.7)
	add_child(enter)

	var tripod: Node3D = TRIPOD.instantiate()
	tripod.position = Vector3(0.0, 0.8, 10.8)
	add_child(tripod)

	var shelter: LeanToShelter = LEAN.instantiate()
	shelter.title = "SHELTER"
	shelter.with_torch = true
	shelter.position = Vector3(-6.1, 0.8, 8.4)
	shelter.rotation_degrees = Vector3(0.0, 18.0, 0.0)
	add_child(shelter)

	var store: LeanToShelter = LEAN.instantiate()
	store.title = "STORE"
	store.with_torch = false
	store.position = Vector3(6.2, 0.8, 16.4)
	store.rotation_degrees = Vector3(0.0, -155.0, 0.0)
	add_child(store)

	var plank: Node3D = PLANK.instantiate()
	plank.position = Vector3(5.4, 0.8, 12.2)
	plank.rotation_degrees = Vector3(0.0, -8.0, 0.0)
	add_child(plank)

	var crate: Node3D = CRATE.instantiate()
	crate.position = Vector3(1.7, 1.16, 15.2)
	add_child(crate)

	var mist: Node3D = MIST.instantiate()
	mist.position = Vector3(0.0, 0.8, 23.5)
	add_child(mist)


func _place_markers() -> void:
	_marker("PlayerSpawn", player_spawn)
	_marker("palisade_enter", Vector3(0.0, 1.0, 0.7))
	_marker("camp_tripod", Vector3(0.0, 1.0, 10.8))
	_marker("lean_to_shelter", Vector3(-6.1, 1.0, 8.4))
	_marker("guard_plank", Vector3(5.4, 1.0, 12.2))
	_marker("camp_crate", Vector3(1.7, 1.0, 15.2))
	_marker("mist_exit", Vector3(0.0, 1.0, 23.5))


func _marker(marker_name: String, pos: Vector3) -> void:
	var m := Marker3D.new()
	m.name = marker_name
	m.position = pos
	markers.add_child(m)
