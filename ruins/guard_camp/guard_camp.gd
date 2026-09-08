class_name GuardCamp
extends Node3D

## Cramped wooden guard-camp pocket. Enter from the tunnel far end. No enemy.

const LOG := preload("res://ruins/guard_camp/palisade_log.tscn")
const ENTER := preload("res://ruins/guard_camp/palisade_enter.tscn")
const TRIPOD := preload("res://ruins/guard_camp/tripod_central.tscn")
const LEAN_A := preload("res://ruins/guard_camp/lean_to_a.tscn")
const LEAN_B := preload("res://ruins/guard_camp/lean_to_b.tscn")
const PLANK := preload("res://ruins/guard_camp/guard_plank.tscn")
const CRATE := preload("res://ruins/guard_camp/crate_loot.tscn")
const TORCH := preload("res://ruins/guard_camp/torch_post.tscn")
const MIST := preload("res://ruins/guard_camp/mist_drop.tscn")
const DIRT := preload("res://ruins/guard_camp/materials/dirt.tres")
const MUD := preload("res://ruins/guard_camp/materials/mud.tres")

## Tiny ring. Dirt top is y = 0.8. Pieces sit on that plane.
var player_spawn: Vector3 = Vector3(0.0, 1.0, 2.0)

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
	env.background_color = Color(0.08, 0.09, 0.1)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.26, 0.22, 0.16)
	env.ambient_light_energy = 0.55
	env.fog_enabled = true
	env.fog_light_color = Color(0.4, 0.44, 0.46)
	env.fog_density = 0.034
	env.glow_enabled = true
	env.glow_intensity = 0.3
	world_env.environment = env


func _build_yard() -> void:
	PocketGeo.box(geometry, Vector3(0.0, 0.4, 7.2), Vector3(13.2, 0.8, 15.6), DIRT, true)
	PocketGeo.box(geometry, Vector3(0.0, 0.82, 7.0), Vector3(1.7, 0.05, 12.2), MUD, false)
	PocketGeo.omni(lights, Vector3(0.0, 3.6, 6.5), Color(1.0, 0.68, 0.38), 1.4, 12.0)


func _build_palisade() -> void:
	var ring := Node3D.new()
	ring.name = "palisade_log"
	add_child(ring)
	## South wall, enter gap ~2.2 m.
	_log_run(ring, Vector3(-6.2, 0.8, 0.5), Vector3(-1.25, 0.8, 0.5), 0.36)
	_log_run(ring, Vector3(1.25, 0.8, 0.5), Vector3(6.2, 0.8, 0.5), 0.36)
	## North wall, mist gap.
	_log_run(ring, Vector3(-6.2, 0.8, 13.8), Vector3(-1.25, 0.8, 13.8), 0.36)
	_log_run(ring, Vector3(1.25, 0.8, 13.8), Vector3(6.2, 0.8, 13.8), 0.36)
	_log_run(ring, Vector3(-6.35, 0.8, 0.7), Vector3(-6.35, 0.8, 13.6), 0.38)
	_log_run(ring, Vector3(6.35, 0.8, 0.7), Vector3(6.35, 0.8, 13.6), 0.38)


func _log_run(parent: Node, from: Vector3, to: Vector3, spacing: float) -> void:
	var delta := to - from
	var length := delta.length()
	if length < 0.01:
		return
	var count := maxi(int(round(length / spacing)), 1)
	for i in count + 1:
		var t := float(i) / float(count)
		var pos := from.lerp(to, t)
		var stake: PalisadeLog = LOG.instantiate()
		stake.log_height = 2.2 + fmod(float(i) * 0.47, 0.85)
		stake.lean = Vector3(0.0, 0.0, (float(i % 3) - 1.0) * 2.4)
		stake.position = pos
		parent.add_child(stake)


func _place_pieces() -> void:
	var enter: Node3D = ENTER.instantiate()
	enter.position = Vector3(0.0, 0.8, 0.65)
	add_child(enter)

	var tripod: Node3D = TRIPOD.instantiate()
	tripod.position = Vector3(0.0, 0.8, 6.6)
	add_child(tripod)

	var a: Node3D = LEAN_A.instantiate()
	a.position = Vector3(-3.4, 0.8, 5.4)
	a.rotation_degrees = Vector3(0.0, 22.0, 0.0)
	add_child(a)

	var torch: Node3D = TORCH.instantiate()
	torch.position = Vector3(-2.15, 0.8, 4.35)
	add_child(torch)

	var b: Node3D = LEAN_B.instantiate()
	b.position = Vector3(3.35, 0.8, 9.1)
	b.rotation_degrees = Vector3(0.0, -150.0, 0.0)
	add_child(b)

	var plank: Node3D = PLANK.instantiate()
	plank.position = Vector3(3.15, 0.8, 6.9)
	plank.rotation_degrees = Vector3(0.0, -10.0, 0.0)
	add_child(plank)

	var crate: Node3D = CRATE.instantiate()
	crate.position = Vector3(1.15, 1.16, 8.6)
	add_child(crate)

	var mist: Node3D = MIST.instantiate()
	mist.position = Vector3(0.0, 0.8, 13.75)
	add_child(mist)


func _place_markers() -> void:
	_marker("PlayerSpawn", player_spawn)
	_marker("palisade_log", Vector3(-6.35, 1.0, 7.0))
	_marker("palisade_enter", Vector3(0.0, 1.0, 0.65))
	_marker("tripod_central", Vector3(0.0, 1.0, 6.6))
	_marker("lean_to_a", Vector3(-3.4, 1.0, 5.4))
	_marker("lean_to_b", Vector3(3.35, 1.0, 9.1))
	_marker("guard_plank", Vector3(3.15, 1.0, 6.9))
	_marker("crate_loot", Vector3(1.15, 1.0, 8.6))
	_marker("torch_post", Vector3(-2.15, 1.0, 4.35))
	_marker("mist_drop", Vector3(0.0, 1.0, 13.75))


func _marker(marker_name: String, pos: Vector3) -> void:
	var m := Marker3D.new()
	m.name = marker_name
	m.position = pos
	markers.add_child(m)
