class_name CampKit
extends RefCounted

## Camp props: Poly Haven CC0 PBR + glTF where it reads better than cylinders.
## Generated bark/cloth/mud stay as fallback. Not CSG greybox. No ripped game files.

const TEX_BARK := "res://third_party/polyhaven/textures/pine_bark/pine_bark_diff_1k.jpg"
const TEX_BARK_N := "res://third_party/polyhaven/textures/pine_bark/pine_bark_nor_gl_1k.jpg"
const TEX_BARK_R := "res://third_party/polyhaven/textures/pine_bark/pine_bark_rough_1k.jpg"
const TEX_PLANK := "res://third_party/polyhaven/textures/brown_planks_07/brown_planks_07_diff_1k.jpg"
const TEX_PLANK_N := "res://third_party/polyhaven/textures/brown_planks_07/brown_planks_07_nor_gl_1k.jpg"
const TEX_PLANK_R := "res://third_party/polyhaven/textures/brown_planks_07/brown_planks_07_rough_1k.jpg"
const TEX_MUD := "res://third_party/polyhaven/textures/mud_forest/mud_forest_diff_1k.jpg"
const TEX_MUD_N := "res://third_party/polyhaven/textures/mud_forest/mud_forest_nor_gl_1k.jpg"
const TEX_MUD_R := "res://third_party/polyhaven/textures/mud_forest/mud_forest_rough_1k.jpg"
const TEX_CLOTH := "res://third_party/polyhaven/textures/hessian_380/hessian_380_diff_1k.jpg"
const TEX_CLOTH_N := "res://third_party/polyhaven/textures/hessian_380/hessian_380_nor_gl_1k.jpg"
const TEX_CLOTH_R := "res://third_party/polyhaven/textures/hessian_380/hessian_380_rough_1k.jpg"
const TEX_LEATHER := "res://third_party/polyhaven/textures/brown_leather/brown_leather_diff_1k.jpg"
const TEX_LEATHER_N := "res://third_party/polyhaven/textures/brown_leather/brown_leather_nor_gl_1k.jpg"
const TEX_LEATHER_R := "res://third_party/polyhaven/textures/brown_leather/brown_leather_rough_1k.jpg"

const PROP_CRATE := "res://third_party/polyhaven/models/wooden_crate_01/wooden_crate_01_1k.gltf"
const PROP_BARREL := "res://third_party/polyhaven/models/wine_barrel_01/wine_barrel_01_1k.gltf"
const PROP_LANTERN := "res://third_party/polyhaven/models/wooden_lantern_01/wooden_lantern_01_1k.gltf"
const PROP_BUCKET := "res://third_party/polyhaven/models/wooden_bucket_01/wooden_bucket_01_1k.gltf"
const PROP_AXE := "res://third_party/polyhaven/models/wooden_axe_02/wooden_axe_02_1k.gltf"
const PROP_POT := "res://third_party/polyhaven/models/brass_pot_01/brass_pot_01_1k.gltf"

static var _mats: Dictionary = {}


static func mat(kind: String) -> StandardMaterial3D:
	if _mats.has(kind):
		return _mats[kind]
	var made := _load_pbr(kind)
	if made == null:
		made = _build_mat(kind)
	_mats[kind] = made
	return made


static func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


static func _pbr(diff: String, nor: String, rough: String) -> StandardMaterial3D:
	var albedo := _tex(diff)
	if albedo == null:
		return null
	var m := StandardMaterial3D.new()
	m.albedo_texture = albedo
	m.roughness = 0.86
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var ntex := _tex(nor)
	if ntex:
		m.normal_enabled = true
		m.normal_texture = ntex
		m.normal_scale = 0.85
	var rtex := _tex(rough)
	if rtex:
		m.roughness_texture = rtex
	return m


static func _load_pbr(kind: String) -> StandardMaterial3D:
	var m: StandardMaterial3D
	match kind:
		"bark":
			m = _pbr(TEX_BARK, TEX_BARK_N, TEX_BARK_R)
			if m:
				m.uv1_scale = Vector3(1.8, 2.8, 1.8)
		"plank":
			m = _pbr(TEX_PLANK, TEX_PLANK_N, TEX_PLANK_R)
			if m:
				m.uv1_scale = Vector3(1.4, 1.4, 1.4)
		"cloth":
			m = _pbr(TEX_CLOTH, TEX_CLOTH_N, TEX_CLOTH_R)
			if m:
				m.cull_mode = BaseMaterial3D.CULL_DISABLED
				m.roughness = 0.82
				m.uv1_scale = Vector3(2.2, 2.2, 2.2)
		"mud":
			m = _pbr(TEX_MUD, TEX_MUD_N, TEX_MUD_R)
			if m:
				m.uv1_scale = Vector3(5.5, 5.5, 5.5)
				m.albedo_color = Color(0.78, 0.68, 0.52)
		"leather":
			m = _pbr(TEX_LEATHER, TEX_LEATHER_N, TEX_LEATHER_R)
			if m:
				m.cull_mode = BaseMaterial3D.CULL_DISABLED
				m.uv1_scale = Vector3(1.6, 1.6, 1.6)
		_:
			m = null
	return m


static func _build_mat(kind: String) -> StandardMaterial3D:
	var img := Image.create(128, 128, false, Image.FORMAT_RGB8)
	match kind:
		"bark":
			_fill_bark(img)
		"plank":
			_fill_plank(img)
		"cloth":
			_fill_cloth(img)
		"mud":
			_fill_mud(img)
		"grass":
			_fill_grass(img)
		"rope":
			_fill_rope(img)
		"leather":
			_fill_leather(img)
		_:
			_fill_plank(img)
	var tex := ImageTexture.create_from_image(img)
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.roughness = 0.92
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if kind == "cloth":
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.roughness = 0.78
	if kind == "grass":
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if kind == "mud":
		m.uv1_scale = Vector3(6, 6, 6)
		m.albedo_color = Color(0.85, 0.72, 0.55)
	if kind == "bark":
		m.uv1_scale = Vector3(1.6, 2.4, 1.6)
	return m


static func instance_prop(parent: Node3D, path: String, pos: Vector3, yaw: float = 0.0, scale: float = 1.0) -> Node3D:
	if not ResourceLoader.exists(path):
		return null
	var packed := load(path) as PackedScene
	if packed == null:
		return null
	var node := packed.instantiate() as Node3D
	if node == null:
		return null
	node.position = pos
	node.rotation_degrees.y = yaw
	if not is_equal_approx(scale, 1.0):
		node.scale = Vector3.ONE * scale
	parent.add_child(node)
	return node


static func _fill_bark(img: Image) -> void:
	for y in 128:
		for x in 128:
			var stripe := sin(float(x) * 0.55 + float(y) * 0.04) * 0.5 + 0.5
			var knot := 1.0 - clampf(absf(float((x * 13 + y * 7) % 47) - 8.0) * 0.12, 0.0, 1.0)
			var n := fmod(float(x * 17 + y * 31), 11.0) / 11.0
			var t := 0.18 + stripe * 0.16 + n * 0.07 + knot * 0.05
			img.set_pixel(x, y, Color(t * 1.05, t * 0.78, t * 0.52))


static func _fill_plank(img: Image) -> void:
	for y in 128:
		var board := int(y / 16)
		var gap := 1 if (y % 16) < 2 else 0
		for x in 128:
			var grain := sin(float(x) * 0.35 + float(board) * 1.7) * 0.5 + 0.5
			var n := fmod(float(x * 9 + y * 5 + board * 19), 9.0) / 9.0
			var t := 0.22 + grain * 0.14 + n * 0.06
			if gap:
				t *= 0.35
			img.set_pixel(x, y, Color(t * 1.15, t * 0.82, t * 0.5))


static func _fill_cloth(img: Image) -> void:
	for y in 128:
		for x in 128:
			var fold := sin(float(x) * 0.12 + float(y) * 0.04) * 0.5 + 0.5
			var wrinkle := sin(float(y) * 0.28) * 0.08
			var t := 0.14 + fold * 0.1 + wrinkle
			img.set_pixel(x, y, Color(t * 0.95, t * 0.88, t * 0.78))


static func _fill_mud(img: Image) -> void:
	for y in 128:
		for x in 128:
			var puddle := sin(float(x) * 0.09) * sin(float(y) * 0.11)
			var n := fmod(float(x * 21 + y * 13), 17.0) / 17.0
			var t := 0.12 + n * 0.08 + puddle * 0.03
			img.set_pixel(x, y, Color(t * 1.1, t * 0.82, t * 0.55))


static func _fill_grass(img: Image) -> void:
	for y in 128:
		for x in 128:
			var blade := sin(float(x) * 1.8 + float(y) * 0.2) * 0.5 + 0.5
			var t := 0.16 + blade * 0.14
			img.set_pixel(x, y, Color(t * 0.55, t * 0.85, t * 0.32))


static func _fill_rope(img: Image) -> void:
	for y in 128:
		for x in 128:
			var twist := sin((float(x) + float(y)) * 0.4) * 0.5 + 0.5
			var t := 0.28 + twist * 0.12
			img.set_pixel(x, y, Color(t * 1.05, t * 0.85, t * 0.5))


static func _fill_leather(img: Image) -> void:
	for y in 128:
		for x in 128:
			var crease := sin(float(x) * 0.18 + float(y) * 0.07) * 0.5 + 0.5
			var n := fmod(float(x * 11 + y * 19), 13.0) / 13.0
			var t := 0.28 + crease * 0.16 + n * 0.08
			img.set_pixel(x, y, Color(t * 1.25, t * 0.62, t * 0.32))


static func _orient_along(from: Vector3, to: Vector3) -> Transform3D:
	var mid := (from + to) * 0.5
	var y := (to - from)
	if y.length_squared() < 0.0001:
		return Transform3D(Basis.IDENTITY, mid)
	y = y.normalized()
	var x := y.cross(Vector3.UP)
	if x.length_squared() < 0.0001:
		x = y.cross(Vector3.RIGHT)
	x = x.normalized()
	return Transform3D(Basis(x, y, x.cross(y)), mid)


static func add_log(parent: Node3D, pos: Vector3, height: float, radius: float, yaw: float = 0.0, lean: float = 0.0) -> MeshInstance3D:
	var root := Node3D.new()
	root.position = pos
	root.rotation_degrees = Vector3(lean, yaw, 0.0)
	var shaft := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius * 0.92
	cyl.bottom_radius = radius
	cyl.height = height
	cyl.radial_segments = 16
	shaft.mesh = cyl
	shaft.material_override = mat("bark")
	shaft.position = Vector3(0, height * 0.5, 0)
	root.add_child(shaft)
	var tip := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.012
	cone.bottom_radius = radius * 0.95
	cone.height = radius * 2.4
	cone.radial_segments = 12
	tip.mesh = cone
	tip.material_override = mat("bark")
	tip.position = Vector3(0, height + radius * 1.1, 0)
	root.add_child(tip)
	## Rope lash around the shaft (palisade "tied together" read).
	var lash := MeshInstance3D.new()
	var band := CylinderMesh.new()
	band.top_radius = radius * 1.12
	band.bottom_radius = radius * 1.12
	band.height = 0.07
	band.radial_segments = 12
	lash.mesh = band
	lash.material_override = mat("rope")
	lash.position = Vector3(0, height * 0.62, 0)
	root.add_child(lash)
	parent.add_child(root)
	return shaft


static func palisade_run(parent: Node3D, from: Vector3, to: Vector3, seed_n: int = 1) -> void:
	var span := to - from
	span.y = 0.0
	var length := span.length()
	if length < 0.2:
		return
	var dir := span / length
	var side := Vector3(-dir.z, 0.0, dir.x)
	var count := maxi(int(length / 0.34), 2)
	for i in count:
		var t := float(i) / float(count - 1)
		var jitter := float((seed_n * 17 + i * 31) % 10) * 0.012
		var h := 2.15 + float((seed_n + i * 7) % 13) * 0.14
		var r := 0.11 + float((i * 3 + seed_n) % 5) * 0.012
		var pos := from.lerp(to, t) + side * (jitter - 0.05)
		pos.y = from.y
		var lean := float((i * 5 + seed_n) % 7) - 3.0
		add_log(parent, pos, h, r, float(i * 27), lean * 0.8)
	## Horizontal rope rails — photo palisade is lashed, not free stakes.
	lash_rail(parent, from, to, 0.95, 0.028)
	lash_rail(parent, from, to, 1.55, 0.032)
	var wall := StaticBody3D.new()
	wall.collision_layer = Combat.LAYER_WORLD
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.45, 2.8, length)
	col.shape = box
	wall.add_child(col)
	parent.add_child(wall)
	var mid := from.lerp(to, 0.5) + Vector3(0, 1.4, 0)
	var xaxis := dir.cross(Vector3.UP)
	if xaxis.length_squared() < 0.0001:
		xaxis = Vector3.RIGHT
	xaxis = xaxis.normalized()
	wall.transform = Transform3D(Basis(xaxis, Vector3.UP, dir), mid)


static func lash_rail(parent: Node3D, from: Vector3, to: Vector3, y: float, radius: float = 0.03) -> void:
	var a := Vector3(from.x, from.y + y, from.z)
	var b := Vector3(to.x, to.y + y, to.z)
	if a.distance_to(b) < 0.2:
		return
	var rail := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = a.distance_to(b)
	cyl.radial_segments = 10
	rail.mesh = cyl
	rail.material_override = mat("rope")
	rail.transform = _orient_along(a, b)
	parent.add_child(rail)


static func crate(parent: Node3D, pos: Vector3, size: Vector3 = Vector3(0.72, 0.55, 0.72), yaw: float = 0.0) -> MeshInstance3D:
	## wooden_crate_01 is ~0.82 x 0.32 x 0.41, origin at the floor.
	var scale := maxf(size.x / 0.82, size.z / 0.41)
	scale = clampf(scale, 0.85, 2.2)
	var imported := instance_prop(parent, PROP_CRATE, pos + Vector3(0.0, -size.y * 0.5, 0.0), yaw, scale)
	if imported:
		var dummy := MeshInstance3D.new()
		dummy.visible = false
		imported.add_child(dummy)
		return dummy
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.material_override = mat("plank")
	mi.position = pos
	mi.rotation_degrees.y = yaw
	parent.add_child(mi)
	var lid := MeshInstance3D.new()
	var lid_mesh := BoxMesh.new()
	lid_mesh.size = Vector3(size.x * 1.04, 0.06, size.z * 1.04)
	lid.mesh = lid_mesh
	lid.material_override = mat("plank")
	lid.position = pos + Vector3(0.02, size.y * 0.52, 0.0)
	lid.rotation_degrees = Vector3(0, yaw + 4.0, 2.0)
	parent.add_child(lid)
	return mi


static func barrel(parent: Node3D, pos: Vector3) -> void:
	## wine_barrel_01 is ~0.74 across and 0.87 tall, origin at the floor.
	if instance_prop(parent, PROP_BARREL, pos, 12.0, 0.72):
		return
	var body := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.28
	cyl.bottom_radius = 0.3
	cyl.height = 0.62
	cyl.radial_segments = 16
	body.mesh = cyl
	body.material_override = mat("plank")
	body.position = pos + Vector3(0, 0.31, 0)
	parent.add_child(body)
	for yoff in [0.1, 0.31, 0.52]:
		var hoop := MeshInstance3D.new()
		var ring := CylinderMesh.new()
		ring.top_radius = 0.32
		ring.bottom_radius = 0.32
		ring.height = 0.035
		hoop.mesh = ring
		hoop.material_override = mat("rope")
		hoop.position = pos + Vector3(0, yoff, 0)
		parent.add_child(hoop)


static func cloth_sheet(parent: Node3D, pos: Vector3, size: Vector2, rot: Vector3, sag: float = 12.0) -> void:
	var mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = size
	plane.subdivide_width = 6
	plane.subdivide_depth = 4
	mi.mesh = plane
	mi.material_override = mat("cloth")
	mi.position = pos
	mi.rotation_degrees = rot + Vector3(sag, 0, 0)
	parent.add_child(mi)


static func lean_to(parent: Node3D, origin: Vector3, yaw: float) -> void:
	var root := Node3D.new()
	root.position = origin
	root.rotation_degrees.y = yaw
	parent.add_child(root)
	for xz in [Vector3(-1.15, 0, -0.85), Vector3(1.15, 0, -0.85), Vector3(-1.15, 0, 0.95), Vector3(1.05, 0, 0.55)]:
		add_log(root, xz, 2.05 if xz.z < 0.0 else 1.35, 0.07, 20.0, 2.0 if xz.z > 0.0 else 0.0)
	var beam := MeshInstance3D.new()
	var beam_mesh := CylinderMesh.new()
	beam_mesh.top_radius = 0.055
	beam_mesh.bottom_radius = 0.055
	beam_mesh.height = 2.5
	beam.mesh = beam_mesh
	beam.material_override = mat("bark")
	beam.position = Vector3(0, 2.0, -0.85)
	beam.rotation_degrees.z = 90
	root.add_child(beam)
	cloth_sheet(root, Vector3(0, 1.72, 0.05), Vector2(2.6, 2.2), Vector3(0, 0, 0), 28.0)
	cloth_sheet(root, Vector3(0, 1.55, 0.15), Vector2(2.4, 2.0), Vector3(0, 6, 0), 34.0)
	crate(root, Vector3(-0.55, 0.28, 0.15), Vector3(0.7, 0.5, 0.62), 12.0)
	crate(root, Vector3(0.35, 0.22, 0.35), Vector3(0.55, 0.4, 0.5), -18.0)
	barrel(root, Vector3(0.95, 0.0, -0.15))
	instance_prop(root, PROP_BUCKET, Vector3(0.15, 0.0, 0.55), -22.0, 1.0)
	instance_prop(root, PROP_AXE, Vector3(-0.95, 0.28, -0.35), 70.0, 1.0)
	## Orange-brown hide drape on the front crate (reference camp clutter).
	var hide := MeshInstance3D.new()
	var hide_mesh := PlaneMesh.new()
	hide_mesh.size = Vector2(0.78, 0.7)
	hide.mesh = hide_mesh
	hide.material_override = mat("leather")
	hide.position = Vector3(-0.5, 0.58, 0.18)
	hide.rotation_degrees = Vector3(12, 18, -8)
	root.add_child(hide)


static func tripod(parent: Node3D, origin: Vector3) -> void:
	var root := Node3D.new()
	root.position = origin
	parent.add_child(root)
	var apex := Vector3(0, 3.15, 0)
	var feet: Array[Vector3] = [Vector3(-0.95, 0, 0.55), Vector3(0.95, 0, 0.55), Vector3(0.0, 0, -1.05)]
	for foot in feet:
		var pole := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		var length: float = foot.distance_to(apex)
		cyl.top_radius = 0.045
		cyl.bottom_radius = 0.055
		cyl.height = length
		cyl.radial_segments = 12
		pole.mesh = cyl
		pole.material_override = mat("bark")
		pole.transform = _orient_along(foot, apex)
		root.add_child(pole)
	var lash := MeshInstance3D.new()
	var wrap := CylinderMesh.new()
	wrap.top_radius = 0.12
	wrap.bottom_radius = 0.12
	wrap.height = 0.16
	lash.mesh = wrap
	lash.material_override = mat("rope")
	lash.position = apex + Vector3(0, -0.08, 0)
	root.add_child(lash)
	instance_prop(root, PROP_POT, Vector3(0.0, 0.72, 0.0), 8.0, 1.15)
	instance_prop(root, PROP_BUCKET, Vector3(0.55, 0.0, 0.35), 18.0, 1.0)
	for s in [Vector3(-0.45, 0.18, 0.35), Vector3(0.25, 0.16, 0.15), Vector3(0.05, 0.14, -0.35)]:
		var sack := MeshInstance3D.new()
		var sph := SphereMesh.new()
		sph.radius = 0.22
		sph.height = 0.38
		sack.mesh = sph
		sack.material_override = mat("cloth")
		sack.position = s
		sack.scale = Vector3(1.15, 0.75, 0.95)
		root.add_child(sack)


static func torch_post(parent: Node3D, pos: Vector3, lights: Node3D) -> void:
	add_log(parent, pos, 1.85, 0.07, 10.0, 1.5)
	var iron := StandardMaterial3D.new()
	iron.albedo_color = Color(0.18, 0.16, 0.14)
	iron.metallic = 0.68
	iron.roughness = 0.48
	var basket := MeshInstance3D.new()
	var bowl := CylinderMesh.new()
	bowl.top_radius = 0.17
	bowl.bottom_radius = 0.055
	bowl.height = 0.14
	bowl.radial_segments = 12
	basket.mesh = bowl
	basket.material_override = iron
	basket.position = pos + Vector3(0.05, 1.88, 0.0)
	parent.add_child(basket)
	for i in 4:
		var bar := MeshInstance3D.new()
		var rod := CylinderMesh.new()
		rod.top_radius = 0.012
		rod.bottom_radius = 0.012
		rod.height = 0.2
		bar.mesh = rod
		bar.material_override = iron
		var ang := float(i) * TAU / 4.0
		bar.position = pos + Vector3(0.05 + cos(ang) * 0.12, 1.82, sin(ang) * 0.12)
		parent.add_child(bar)
	instance_prop(parent, PROP_LANTERN, pos + Vector3(0.18, 1.55, 0.08), 16.0, 1.15)
	var flame := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.11
	sph.height = 0.22
	flame.mesh = sph
	var fire := StandardMaterial3D.new()
	fire.albedo_color = Color(1.0, 0.55, 0.2)
	fire.emission_enabled = true
	fire.emission = Color(1.0, 0.45, 0.12)
	fire.emission_energy_multiplier = 3.2
	flame.material_override = fire
	flame.position = pos + Vector3(0.05, 2.02, 0.0)
	parent.add_child(flame)
	var lamp := OmniLight3D.new()
	lamp.position = pos + Vector3(0, 2.1, 0)
	lamp.light_color = Color(1.0, 0.62, 0.32)
	lamp.light_energy = 2.6
	lamp.omni_range = 9.0
	lamp.shadow_enabled = true
	lights.add_child(lamp)


static func timber_gate(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation_degrees.y = yaw
	parent.add_child(root)
	add_log(root, Vector3(-1.25, 0, 0), 3.15, 0.14, 0, 0)
	add_log(root, Vector3(1.25, 0, 0), 3.05, 0.14, 8, 1)
	var lintel := MeshInstance3D.new()
	var beam := BoxMesh.new()
	beam.size = Vector3(2.9, 0.28, 0.28)
	lintel.mesh = beam
	lintel.material_override = mat("plank")
	lintel.position = Vector3(0, 3.05, 0)
	root.add_child(lintel)


static func plank_ramp(parent: Node3D, pos: Vector3, size: Vector3, pitch: float, yaw: float) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation_degrees = Vector3(pitch, yaw, 0)
	body.collision_layer = Combat.LAYER_WORLD
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.material_override = mat("plank")
	body.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	parent.add_child(body)


static func grass_tuft(parent: Node3D, pos: Vector3) -> void:
	for i in 3:
		var blade := MeshInstance3D.new()
		var plane := PlaneMesh.new()
		plane.size = Vector2(0.18, 0.32)
		blade.mesh = plane
		blade.material_override = mat("grass")
		blade.position = pos + Vector3(float(i) * 0.06 - 0.06, 0.14, float(i % 2) * 0.05)
		blade.rotation_degrees = Vector3(80, float(i) * 40.0, 0)
		parent.add_child(blade)


static func weather_cloth(root: Node3D, tint: Color = Color(0.2, 0.16, 0.12)) -> void:
	var dark := mat("cloth").duplicate() as StandardMaterial3D
	dark.albedo_color = tint
	for child in root.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		if mi.mesh is PlaneMesh and (mi.mesh as PlaneMesh).size.x > 1.2:
			mi.material_override = dark


static func mud_ground(parent: Node3D, pos: Vector3, size: Vector3, tint: Color = Color(0.85, 0.72, 0.55)) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	body.collision_layer = Combat.LAYER_WORLD
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	var ground_mat := mat("mud")
	if tint != Color(0.85, 0.72, 0.55):
		ground_mat = ground_mat.duplicate() as StandardMaterial3D
		ground_mat.albedo_color = tint
	mi.material_override = ground_mat
	body.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	parent.add_child(body)


static func watch_post(parent: Node3D, origin: Vector3, lights: Node3D, title: String) -> void:
	var radius := 1.55
	for i in 10:
		var ang := float(i) / 10.0 * TAU
		var p := origin + Vector3(cos(ang) * radius, 0, sin(ang) * radius)
		add_log(parent, p, 2.7 + float(i % 3) * 0.12, 0.1, float(i * 18), float(i % 4) - 1.5)
	var deck := StaticBody3D.new()
	deck.position = origin + Vector3(0, 2.15, 0)
	deck.collision_layer = Combat.LAYER_WORLD
	var deck_mesh := MeshInstance3D.new()
	var deck_box := BoxMesh.new()
	deck_box.size = Vector3(2.4, 0.12, 2.4)
	deck_mesh.mesh = deck_box
	deck_mesh.material_override = mat("plank")
	deck.add_child(deck_mesh)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = deck_box.size
	col.shape = shape
	deck.add_child(col)
	parent.add_child(deck)
	plank_ramp(parent, origin + Vector3(1.6, 1.05, 0.2), Vector3(2.2, 0.1, 0.7), -28.0, 8.0)
	torch_post(parent, origin + Vector3(0.0, 0.0, -0.2), lights)
	var plaque := Label3D.new()
	plaque.text = title
	plaque.font_size = 28
	plaque.position = origin + Vector3(0, 3.15, 0)
	plaque.modulate = Color(0.82, 0.72, 0.52)
	parent.add_child(plaque)
