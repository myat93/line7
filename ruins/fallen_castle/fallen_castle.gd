class_name FallenCastle
extends Node3D

## Guard camp pocket — PBR palisade outpost. Same RUINS BREACH link.

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
	if OS.get_cmdline_user_args().has("--camp-shot"):
		_dump_camp_shots()


func _style_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	var pano := PanoramaSkyMaterial.new()
	var dusk := Kit.sky_tex()
	if dusk:
		pano.panorama = dusk
		pano.energy_multiplier = 0.42
		env.sky.sky_material = pano
	else:
		var sky := ProceduralSkyMaterial.new()
		sky.sky_top_color = Color(0.22, 0.24, 0.34)
		sky.sky_horizon_color = Color(0.55, 0.32, 0.3)
		sky.ground_bottom_color = Color(0.08, 0.07, 0.06)
		sky.ground_horizon_color = Color(0.28, 0.2, 0.16)
		sky.energy_multiplier = 0.7
		env.sky.sky_material = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.38
	env.fog_enabled = true
	env.fog_light_color = Color(0.42, 0.36, 0.4)
	env.fog_density = 0.022
	env.fog_aerial_perspective = 0.55
	env.fog_sky_affect = 0.55
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.045
	env.volumetric_fog_albedo = Color(0.52, 0.46, 0.48)
	env.volumetric_fog_emission = Color(0.08, 0.06, 0.07)
	env.volumetric_fog_anisotropy = 0.25
	env.volumetric_fog_length = 64.0
	env.glow_enabled = true
	env.glow_intensity = 0.55
	env.glow_bloom = 0.12
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.82
	env.adjustment_contrast = 1.06
	world_env.environment = env
	var sun := get_node_or_null("DirectionalLight3D") as DirectionalLight3D
	if sun:
		sun.light_energy = 0.32
		sun.light_color = Color(0.55, 0.6, 0.72)
		sun.shadow_enabled = true
		sun.rotation_degrees = Vector3(-28, 40, 0)


func _build_ground() -> void:
	Kit.mud_ground(geometry, Vector3(0, 0.35, 16), Vector3(36, 0.7, 48))
	Kit.mud_path(geometry, Vector3(0, 0.72, 14), Vector3(4.4, 0.04, 28))
	for i in 28:
		var side := -1.0 if i % 2 == 0 else 1.0
		var z := 3.0 + float(i) * 0.95
		var x := side * (2.05 + 0.4 * sin(float(i) * 1.6))
		Kit.grass_tuft(geometry, Vector3(x, 0.72, z))
	for p in [
		Vector3(-8.2, 0.72, 9.5), Vector3(7.6, 0.72, 11.0), Vector3(-9.0, 0.72, 16.5),
		Vector3(8.4, 0.72, 18.0), Vector3(-6.5, 0.72, 22.0), Vector3(5.8, 0.72, 24.0),
	]:
		Kit.grass_tuft(geometry, p)


func _build_palisade() -> void:
	## ~30m enclosure. North side leaves a gap toward the misty valley.
	Kit.palisade_run(geometry, Vector3(-13, 0.7, 0.4), Vector3(13, 0.7, 0.4), 2)
	Kit.palisade_run(geometry, Vector3(-13.2, 0.7, 0.6), Vector3(-13.2, 0.7, 28.5), 4)
	Kit.palisade_run(geometry, Vector3(13.2, 0.7, 0.6), Vector3(13.2, 0.7, 28.5), 5)
	Kit.palisade_run(geometry, Vector3(-13, 0.7, 28.6), Vector3(-2.4, 0.7, 28.6), 7)
	Kit.palisade_run(geometry, Vector3(2.4, 0.7, 28.6), Vector3(13, 0.7, 28.6), 8)
	Kit.valley(geometry, Vector3(0.0, 0.4, 36.0))


func _build_camp() -> void:
	Kit.timber_gate(geometry, Vector3(0, 0.7, 6.2), 0.0)
	Kit.lean_to(geometry, Vector3(-6.2, 0.7, 9.4), 16.0)
	Kit.lean_to(geometry, Vector3(-7.0, 0.7, 14.2), 6.0)
	Kit.tripod(geometry, Vector3(-2.8, 0.7, 11.4))
	Kit.crate(geometry, Vector3(-4.2, 0.98, 10.6), Vector3(0.7, 0.5, 0.64), 18.0, true)
	Kit.crate(geometry, Vector3(5.2, 0.98, 14.4), Vector3(0.68, 0.48, 0.62), -14.0, false)
	Kit.barrel(geometry, Vector3(-2.0, 0.7, 10.0))
	Kit.barrel(geometry, Vector3(4.6, 0.7, 13.0))
	Kit.watch_post(geometry, Vector3(-9.4, 0.7, 20.2), lights, "")
	Kit.watch_post(geometry, Vector3(9.4, 0.7, 20.2), lights, "")
	Kit.torch_post(geometry, Vector3(3.1, 0.7, 8.4), lights)
	Kit.torch_post(geometry, Vector3(-8.4, 0.7, 8.2), lights)
	Kit.torch_post(geometry, Vector3(8.0, 0.7, 16.4), lights)


func _build_climb() -> void:
	Kit.plank_ramp(geometry, Vector3(-1.6, 1.15, 16.4), Vector3(2.4, 0.1, 0.85), -18.0, 12.0)
	Kit.plank_ramp(geometry, Vector3(-0.4, 1.65, 18.2), Vector3(2.2, 0.1, 0.8), -16.0, 8.0)
	Kit.plank_ramp(geometry, Vector3(0.5, 2.05, 20.0), Vector3(2.0, 0.1, 0.75), -14.0, 4.0)
	for i in 5:
		Kit.add_log(geometry, Vector3(2.6 + float(i) * 0.22, 0.85, 17.4 + float(i) * 0.35), 1.6, 0.1, 90.0, 82.0)


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
	glow.light_energy = 1.2
	glow.omni_range = 5.0
	lights.add_child(glow)


func _place_markers() -> void:
	_marker("PlayerSpawn", player_spawn)
	_marker("Gatehouse", Vector3(0, 1, 6.2))
	_marker("WestWatch", Vector3(-9.4, 1, 20.2))
	_marker("EastWatch", Vector3(9.4, 1, 20.2))
	_marker("ValleyGap", Vector3(0, 1, 28.6))


func _marker(marker_name: String, pos: Vector3) -> void:
	var m := Marker3D.new()
	m.name = marker_name
	m.position = pos
	markers.add_child(m)


func _dump_camp_shots() -> void:
	var cam := Camera3D.new()
	add_child(cam)
	cam.current = true
	cam.fov = 62.0
	await get_tree().create_timer(0.5).timeout
	var origins: Array[Vector3] = [
		Vector3(1.8, 1.85, 3.6),
		Vector3(-1.4, 1.7, 8.0),
		Vector3(0.2, 1.9, 22.8),
		Vector3(-10.6, 2.1, 12.4),
	]
	var aims: Array[Vector3] = [
		Vector3(-2.6, 1.45, 11.0),
		Vector3(-6.0, 1.4, 9.5),
		Vector3(0.0, 2.2, 40.0),
		Vector3(0.0, 1.5, 12.0),
	]
	var names := PackedStringArray([
		"guard_camp_pbr_gate.png",
		"guard_camp_pbr_lean_to.png",
		"guard_camp_pbr_valley.png",
		"guard_camp_pbr_palisade.png",
	])
	for i in origins.size():
		cam.global_position = origins[i]
		cam.look_at(aims[i], Vector3.UP)
		await get_tree().process_frame
		await get_tree().process_frame
		get_viewport().get_texture().get_image().save_png("/opt/cursor/artifacts/" + names[i])
	get_tree().quit()


func _label(pos: Vector3, text: String) -> void:
	var plaque := Label3D.new()
	plaque.text = text
	plaque.font_size = 32
	plaque.position = pos
	plaque.modulate = Color(0.86, 0.76, 0.55)
	geometry.add_child(plaque)
