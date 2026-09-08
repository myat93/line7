class_name GuardCamp
extends Node3D

## Photo-locked wooden guard camp. CampKit meshes. Enter from the tunnel.
## Loop: gap → tripod → left lean-tos / plank → optional crate E → mist drop.

const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")
const ENTER := preload("res://ruins/guard_camp/palisade_enter.tscn")
const TRIPOD := preload("res://ruins/guard_camp/tripod_central.tscn")
const LEAN_A := preload("res://ruins/guard_camp/lean_to_a.tscn")
const LEAN_B := preload("res://ruins/guard_camp/lean_to_b.tscn")
const PLANK := preload("res://ruins/guard_camp/guard_plank.tscn")
const CRATE := preload("res://ruins/guard_camp/crate_loot.tscn")
const TORCH := preload("res://ruins/guard_camp/torch_post.tscn")
const MIST := preload("res://ruins/guard_camp/mist_drop.tscn")
const STAKE := preload("res://ruins/guard_camp/palisade_log.tscn")

var player_spawn: Vector3 = Vector3(0.0, 1.05, 1.85)

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
	sky.sky_top_color = Color(0.10, 0.07, 0.16)
	sky.sky_horizon_color = Color(0.42, 0.22, 0.38)
	sky.ground_bottom_color = Color(0.05, 0.04, 0.05)
	sky.ground_horizon_color = Color(0.18, 0.10, 0.16)
	sky.sun_angle_max = 8.0
	sky.energy_multiplier = 0.55
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.sky.sky_material = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.30, 0.20, 0.34)
	env.ambient_light_energy = 0.42
	env.fog_enabled = true
	env.fog_light_color = Color(0.56, 0.34, 0.50)
	env.fog_density = 0.048
	env.fog_aerial_perspective = 0.58
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.55
	world_env.environment = env
	var moon := get_node_or_null("DirectionalLight3D") as DirectionalLight3D
	if moon:
		moon.light_color = Color(0.52, 0.40, 0.72)
		moon.light_energy = 0.38
		moon.rotation_degrees = Vector3(-36, 148, 0)


func _build_yard() -> void:
	## Tiny muddy clearing — player fills most of the ring.
	Kit.mud_ground(geometry, Vector3(0.0, 0.35, 4.7), Vector3(9.0, 0.7, 10.2), Color(0.36, 0.26, 0.18))
	## Forest floor drops beyond the north gap (walkable, no softlock).
	Kit.mud_ground(geometry, Vector3(0.0, -0.12, 13.0), Vector3(15.5, 0.45, 8.6), Color(0.22, 0.16, 0.12))
	var path := MeshInstance3D.new()
	var strip := BoxMesh.new()
	strip.size = Vector3(1.35, 0.035, 8.6)
	path.mesh = strip
	var path_mat := Kit.mat("mud").duplicate() as StandardMaterial3D
	path_mat.albedo_color = Color(0.22, 0.16, 0.11)
	path.material_override = path_mat
	path.position = Vector3(0.0, 0.72, 4.8)
	geometry.add_child(path)
	for p in [
		Vector3(-2.15, 0.72, 2.4), Vector3(1.85, 0.72, 3.6),
		Vector3(-1.35, 0.72, 6.8), Vector3(1.55, 0.72, 7.4),
	]:
		Kit.grass_tuft(geometry, p)
	## Edge clutter: spare logs and a store barrel, not grey cubes.
	var spare := Kit.add_log(geometry, Vector3(3.15, 0.78, 7.55), 1.15, 0.07, 82.0, 78.0)
	spare.get_parent().rotation_degrees = Vector3(82, -28, 0)
	Kit.barrel(geometry, Vector3(3.05, 0.7, 6.45))
	Kit.crate(geometry, Vector3(2.85, 0.96, 4.55), Vector3(0.52, 0.32, 0.46), -22.0)
	_drape_hide(geometry, Vector3(2.78, 1.18, 4.58), Vector2(0.62, 0.5))


func _drape_hide(parent: Node3D, pos: Vector3, size: Vector2) -> void:
	var hide := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = size
	hide.mesh = plane
	hide.material_override = Kit.mat("leather")
	hide.position = pos
	hide.rotation_degrees = Vector3(10, 16, -6)
	parent.add_child(hide)


func _build_palisade() -> void:
	var ring := Node3D.new()
	ring.name = "palisade_ring"
	add_child(ring)
	var logs := Node3D.new()
	logs.name = "palisade_log"
	ring.add_child(logs)
	Kit.palisade_run(logs, Vector3(-4.15, 0.7, 0.35), Vector3(-1.2, 0.7, 0.28), 2)
	Kit.palisade_run(logs, Vector3(1.2, 0.7, 0.28), Vector3(4.15, 0.7, 0.35), 3)
	Kit.palisade_run(logs, Vector3(-4.15, 0.7, 9.05), Vector3(-1.35, 0.7, 9.18), 4)
	Kit.palisade_run(logs, Vector3(1.35, 0.7, 9.18), Vector3(4.15, 0.7, 9.05), 5)
	Kit.palisade_run(logs, Vector3(-4.2, 0.7, 0.4), Vector3(-4.2, 0.7, 9.0), 6)
	Kit.palisade_run(logs, Vector3(4.2, 0.7, 0.4), Vector3(4.2, 0.7, 9.0), 7)
	## Named stake at the enter gap so the piece exists as its own node.
	var stake: Node3D = STAKE.instantiate()
	stake.position = Vector3(-1.45, 0.7, 0.32)
	ring.add_child(stake)


func _place_pieces() -> void:
	var enter: Node3D = ENTER.instantiate()
	enter.position = Vector3(0.0, 0.7, 0.48)
	add_child(enter)

	var tripod: Node3D = TRIPOD.instantiate()
	tripod.position = Vector3(0.06, 0.7, 4.45)
	add_child(tripod)

	var a: Node3D = LEAN_A.instantiate()
	a.position = Vector3(2.45, 0.7, 3.15)
	a.rotation_degrees = Vector3(0.0, -12.0, 0.0)
	add_child(a)

	var b: Node3D = LEAN_B.instantiate()
	b.position = Vector3(2.50, 0.7, 6.25)
	b.rotation_degrees = Vector3(0.0, -20.0, 0.0)
	add_child(b)

	var plank: Node3D = PLANK.instantiate()
	plank.position = Vector3(1.55, 0.7, 4.75)
	plank.rotation_degrees = Vector3(0.0, -8.0, 0.0)
	add_child(plank)

	var crate: Node3D = CRATE.instantiate()
	crate.position = Vector3(1.45, 0.95, 7.25)
	add_child(crate)

	## Torch / brazier sits at the mist exit, warm against the purple drop.
	var torch: Node3D = TORCH.instantiate()
	torch.position = Vector3(-1.22, 0.7, 8.55)
	add_child(torch)

	var mist: Node3D = MIST.instantiate()
	mist.position = Vector3(0.0, 0.7, 9.15)
	add_child(mist)


func _place_markers() -> void:
	_marker("PlayerSpawn", player_spawn)
	_marker("palisade_log", Vector3(-4.2, 1.0, 4.6))
	_marker("palisade_ring", Vector3(0.0, 1.0, 4.7))
	_marker("palisade_enter", Vector3(0.0, 1.0, 0.48))
	_marker("tripod_central", Vector3(0.06, 1.0, 4.45))
	_marker("lean_to_a", Vector3(2.45, 1.0, 3.15))
	_marker("lean_to_b", Vector3(2.50, 1.0, 6.25))
	_marker("guard_plank", Vector3(1.55, 1.0, 4.75))
	_marker("crate_loot", Vector3(1.45, 1.0, 7.25))
	_marker("torch_post", Vector3(-1.22, 1.0, 8.55))
	_marker("mist_drop", Vector3(0.0, 1.0, 9.15))


func _marker(marker_name: String, pos: Vector3) -> void:
	var m := Marker3D.new()
	m.name = marker_name
	m.position = pos
	markers.add_child(m)
