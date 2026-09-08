class_name FallenCastle
extends Node3D

## Guard camp pocket — wooden palisade, lean-tos, tripod, mud path. Not CSG greybox.

const GATE := preload("res://core/area_gate.gd")
const CRATE := preload("res://ruins/fallen_castle/loot_crate.gd")
const Kit := preload("res://ruins/fallen_castle/camp_kit.gd")

var player_spawn: Vector3 = Vector3(0.0, 1.05, 2.4)

@onready var geometry: Node3D = $Geometry
@onready var lights: Node3D = $Lights
@onready var markers: Node3D = $Markers
@onready var world_env: WorldEnvironment = $WorldEnvironment


func _ready() -> void:
	_style_environment()
	_build_ground()
	_build_palisade()
	_build_camp()
	_build_climb()
	_place_crate()
	_place_return_gate()
	_place_markers()


func _style_environment() -> void:
	var sky := ProceduralSkyMaterial.new()
	sky.sky_top_color = Color(0.18, 0.2, 0.24)
	sky.sky_horizon_color = Color(0.42, 0.28, 0.26)
	sky.ground_bottom_color = Color(0.08, 0.07, 0.06)
	sky.ground_horizon_color = Color(0.22, 0.16, 0.12)
	sky.sun_angle_max = 10.0
	sky.energy_multiplier = 0.85
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.sky.sky_material = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.55
	env.fog_enabled = true
	env.fog_light_color = Color(0.22, 0.2, 0.2)
	env.fog_density = 0.014
	env.fog_aerial_perspective = 0.35
	env.glow_enabled = true
	world_env.environment = env


func _build_ground() -> void:
	Kit.mud_ground(geometry, Vector3(0, 0.35, 14), Vector3(30, 0.7, 32))
	## Darker central path.
	var path := MeshInstance3D.new()
	var strip := BoxMesh.new()
	strip.size = Vector3(4.2, 0.04, 26)
	path.mesh = strip
	var path_mat := Kit.mat("mud").duplicate() as StandardMaterial3D
	path_mat.albedo_color = Color(0.55, 0.45, 0.35)
	path.material_override = path_mat
	path.position = Vector3(0, 0.72, 14)
	geometry.add_child(path)
	for p in [
		Vector3(-2.4, 0.72, 5), Vector3(2.2, 0.72, 6.5), Vector3(-2.6, 0.72, 12),
		Vector3(2.4, 0.72, 14), Vector3(-2.3, 0.72, 20), Vector3(2.6, 0.72, 22),
		Vector3(-8.5, 0.72, 10), Vector3(8.2, 0.72, 11), Vector3(-7.4, 0.72, 18),
	]:
		Kit.grass_tuft(geometry, p)


func _build_palisade() -> void:
	## ~30m enclosure of uneven sharpened logs.
	Kit.palisade_run(geometry, Vector3(-13, 0.7, 0.4), Vector3(13, 0.7, 0.4), 2)
	Kit.palisade_run(geometry, Vector3(-13.2, 0.7, 0.6), Vector3(-13.2, 0.7, 28.5), 4)
	Kit.palisade_run(geometry, Vector3(13.2, 0.7, 0.6), Vector3(13.2, 0.7, 28.5), 5)
	Kit.palisade_run(geometry, Vector3(-13, 0.7, 28.6), Vector3(-2.2, 0.7, 28.6), 7)
	Kit.palisade_run(geometry, Vector3(2.2, 0.7, 28.6), Vector3(13, 0.7, 28.6), 8)
	## Taller keep-end palisade (fallen timber mass, not a grey cube).
	for i in 9:
		var x := -3.6 + float(i) * 0.9
		Kit.add_log(geometry, Vector3(x, 0.7, 26.8), 3.6 + float(i % 4) * 0.18, 0.13, float(i * 15), float(i % 5) - 2.0)
	## Collapsed leaning logs.
	for i in 4:
		var log := Kit.add_log(geometry, Vector3(-5.5 + float(i) * 0.55, 0.85, 24.2 + float(i) * 0.3), 3.4, 0.11, 70.0, 62.0)
		log.get_parent().rotation_degrees = Vector3(68, 18 + float(i) * 8, 0)


func _build_camp() -> void:
	Kit.timber_gate(geometry, Vector3(0, 0.7, 5.8), 0.0)
	Kit.lean_to(geometry, Vector3(-6.4, 0.7, 9.2), 18.0)
	Kit.lean_to(geometry, Vector3(-7.2, 0.7, 14.8), 8.0)
	Kit.lean_to(geometry, Vector3(6.8, 0.7, 10.8), -22.0)
	Kit.tripod(geometry, Vector3(-3.1, 0.7, 11.6))
	Kit.crate(geometry, Vector3(-4.4, 0.98, 10.4), Vector3(0.68, 0.48, 0.62), 22.0)
	Kit.barrel(geometry, Vector3(-2.2, 0.7, 10.1))
	Kit.barrel(geometry, Vector3(4.8, 0.7, 13.2))
	Kit.crate(geometry, Vector3(5.4, 0.98, 14.6), Vector3(0.7, 0.5, 0.66), -12.0)
	Kit.watch_post(geometry, Vector3(-9.2, 0.7, 19.4), lights, "WEST WATCH")
	Kit.watch_post(geometry, Vector3(9.2, 0.7, 19.4), lights, "EAST WATCH")
	Kit.watch_post(geometry, Vector3(0.0, 0.7, 24.6), lights, "KEEP WATCH")
	Kit.torch_post(geometry, Vector3(2.4, 0.7, 6.2), lights)
	Kit.torch_post(geometry, Vector3(-8.6, 0.7, 8.4), lights)
	Kit.torch_post(geometry, Vector3(8.2, 0.7, 16.0), lights)
	_label(Vector3(0, 3.55, 5.8), "GATEHOUSE")


func _build_climb() -> void:
	## Timber ramp toward the keep watch so jump/sprint matter.
	Kit.plank_ramp(geometry, Vector3(-1.6, 1.15, 16.4), Vector3(2.4, 0.1, 0.85), -18.0, 12.0)
	Kit.plank_ramp(geometry, Vector3(-0.4, 1.65, 18.2), Vector3(2.2, 0.1, 0.8), -16.0, 8.0)
	Kit.plank_ramp(geometry, Vector3(0.5, 2.05, 20.0), Vector3(2.0, 0.1, 0.75), -14.0, 4.0)
	for i in 5:
		Kit.add_log(geometry, Vector3(2.4 + float(i) * 0.22, 0.85, 17.2 + float(i) * 0.35), 1.6, 0.1, 90.0, 82.0)


func _place_crate() -> void:
	var crate := Area3D.new()
	crate.set_script(CRATE)
	crate.position = Vector3(-5.6, 1.05, 9.0)
	add_child(crate)


func _place_return_gate() -> void:
	Kit.timber_gate(geometry, Vector3(0, 0.7, 1.15), 0.0)
	_label(Vector3(0, 2.55, 1.5), "LINE 7")
	var gate := Area3D.new()
	gate.set_script(GATE)
	gate.destination = "undercroft"
	gate.prompt_text = "E  —  return to Line 7"
	gate.arrive_banner = "LINE 7 — UNDERCROFT"
	gate.position = Vector3(0.0, 1.15, 1.3)
	add_child(gate)
	var glow := OmniLight3D.new()
	glow.position = Vector3(0, 2.8, 1.2)
	glow.light_color = Color(0.55, 0.82, 0.88)
	glow.light_energy = 1.6
	glow.omni_range = 6.0
	lights.add_child(glow)


func _place_markers() -> void:
	_marker("PlayerSpawn", player_spawn)
	_marker("Gatehouse", Vector3(0, 1, 5.8))
	_marker("WestWatch", Vector3(-9.2, 1, 19.4))
	_marker("EastWatch", Vector3(9.2, 1, 19.4))
	_marker("KeepWatch", Vector3(0, 1, 24.6))


func _marker(marker_name: String, pos: Vector3) -> void:
	var m := Marker3D.new()
	m.name = marker_name
	m.position = pos
	markers.add_child(m)


func _label(pos: Vector3, text: String) -> void:
	var plaque := Label3D.new()
	plaque.text = text
	plaque.font_size = 32
	plaque.position = pos
	plaque.modulate = Color(0.86, 0.76, 0.55)
	geometry.add_child(plaque)
