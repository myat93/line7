class_name Line7Pocket
extends Node3D

## Service-tunnel exploration pocket. No enemy. Reverse the same path back.

const DOOR := preload("res://ruins/line7_pocket/door_gap.tscn")
const TUNNEL := preload("res://ruins/line7_pocket/tunnel_flood.tscn")
const TUBES := preload("res://ruins/line7_pocket/tube_cluster.tscn")
const RELIEF := preload("res://ruins/line7_pocket/relief_wall.tscn")
const LOCKER := preload("res://ruins/line7_pocket/maint_locker.tscn")
const TILE := preload("res://ruins/line7_pocket/materials/tile.tres")
const CONCRETE := preload("res://ruins/line7_undercroft/materials/concrete.tres")

var player_spawn: Vector3 = Vector3(0.0, 1.15, 2.2)

@onready var geometry: Node3D = $Geometry
@onready var lights: Node3D = $Lights
@onready var markers: Node3D = $Markers
@onready var world_env: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	_style_environment()
	_build_ends()
	_place_pieces()
	_place_markers()


func _style_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.03, 0.04, 0.045)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.14, 0.2, 0.2)
	env.ambient_light_energy = 0.55
	env.fog_enabled = true
	env.fog_light_color = Color(0.14, 0.22, 0.22)
	env.fog_density = 0.028
	env.glow_enabled = true
	env.glow_intensity = 0.35
	world_env.environment = env


func _build_ends() -> void:
	## Spine floor + walls so landmarks connect; pieces dress the rooms.
	PocketGeo.box(geometry, Vector3(0.0, 0.48, 20.5), Vector3(3.4, 0.96, 40.0), TILE, true)
	PocketGeo.box(geometry, Vector3(-1.95, 1.6, 30.2), Vector3(0.5, 3.4, 22.0), CONCRETE, true)
	PocketGeo.box(geometry, Vector3(1.95, 1.6, 30.2), Vector3(0.5, 3.4, 22.0), CONCRETE, true)
	PocketGeo.box(geometry, Vector3(0.0, 1.7, -0.35), Vector3(4.0, 3.6, 0.5), CONCRETE, true)
	PocketGeo.box(geometry, Vector3(0.0, 1.7, 41.4), Vector3(4.0, 3.6, 0.5), CONCRETE, true)
	PocketGeo.box(geometry, Vector3(0.0, 3.4, 20.5), Vector3(4.2, 0.28, 42.0), CONCRETE, true)


func _place_pieces() -> void:
	var door: DoorGap = DOOR.instantiate()
	door.destination = "undercroft"
	door.prompt_text = "E  —  return to Line 7"
	door.arrive_banner = "LINE 7 — UNDERCROFT"
	door.plaque_text = "LINE 7"
	door.position = Vector3(0.0, 0.0, 0.55)
	add_child(door)

	var tunnel: Node3D = TUNNEL.instantiate()
	tunnel.position = Vector3(0.0, 0.0, 3.6)
	add_child(tunnel)

	var tubes: Node3D = TUBES.instantiate()
	tubes.position = Vector3(0.0, 0.0, 21.8)
	add_child(tubes)

	var relief: Node3D = RELIEF.instantiate()
	relief.position = Vector3(0.0, 0.0, 29.4)
	add_child(relief)

	var locker: Node3D = LOCKER.instantiate()
	locker.position = Vector3(0.0, 1.15, 36.6)
	add_child(locker)

	## Far-end exit — sealed CAMP door onto the wooden yard. Wall stays.
	var camp_door: DoorGap = DOOR.instantiate()
	camp_door.destination = "guard_camp"
	camp_door.prompt_text = "E  —  climb to the guard camp"
	camp_door.arrive_banner = ""
	camp_door.plaque_text = "CAMP"
	camp_door.position = Vector3(0.0, 0.0, 39.35)
	camp_door.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	add_child(camp_door)


func _place_markers() -> void:
	_marker("PlayerSpawn", player_spawn)
	_marker("door_gap", Vector3(0.0, 1.0, 0.55))
	_marker("tunnel_flood", Vector3(0.0, 1.0, 11.6))
	_marker("tube_cluster", Vector3(0.0, 1.0, 21.8))
	_marker("relief_wall", Vector3(0.0, 1.0, 29.4))
	_marker("maint_locker", Vector3(0.0, 1.0, 36.6))
	_marker("camp_door", Vector3(0.0, 1.0, 39.35))


func _marker(marker_name: String, pos: Vector3) -> void:
	var m := Marker3D.new()
	m.name = marker_name
	m.position = pos
	markers.add_child(m)
