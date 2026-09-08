class_name CampKit
extends RefCounted

## Guard-camp props: modeled meshes + Poly Haven CC0 PBR. Not CSG, not game rips.

const TEX := "res://ruins/fallen_castle/textures/"

static var _mats: Dictionary = {}
static var _tex_cache: Dictionary = {}
static var _sky: Texture2D


static func sky_tex() -> Texture2D:
	if _sky:
		return _sky
	var img := Image.new()
	if img.load(TEX + "dusk.hdr") != OK:
		return null
	_sky = ImageTexture.create_from_image(img)
	return _sky


static func mat(kind: String) -> StandardMaterial3D:
	if _mats.has(kind):
		return _mats[kind]
	var made := _build_mat(kind)
	_mats[kind] = made
	return made


static func _tex(fname: String) -> Texture2D:
	if _tex_cache.has(fname):
		return _tex_cache[fname]
	var img := Image.new()
	if img.load(TEX + fname) != OK:
		return null
	var tex := ImageTexture.create_from_image(img)
	_tex_cache[fname] = tex
	return tex


static func _pbr(diff: String, nor: String, rough: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = _tex(diff)
	m.normal_enabled = true
	m.normal_texture = _tex(nor)
	m.normal_scale = 1.15
	m.roughness_texture = _tex(rough)
	m.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return m


static func _build_mat(kind: String) -> StandardMaterial3D:
	var m: StandardMaterial3D
	match kind:
		"bark":
			m = _pbr("bark_diff.jpg", "bark_nor.jpg", "bark_rough.jpg")
			m.albedo_color = Color(0.62, 0.52, 0.4)
			m.uv1_scale = Vector3(1.4, 2.8, 1.4)
			m.roughness = 0.95
		"plank":
			m = _pbr("plank_diff.jpg", "plank_nor.jpg", "plank_rough.jpg")
			m.albedo_color = Color(0.72, 0.58, 0.4)
			m.uv1_scale = Vector3(1.2, 1.2, 1.2)
			m.roughness = 0.88
		"cloth":
			m = _pbr("cloth_diff.jpg", "cloth_nor.jpg", "cloth_rough.jpg")
			m.albedo_color = Color(0.28, 0.24, 0.22)
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
			m.metallic = 0.0
			m.roughness = 0.94
			m.uv1_scale = Vector3(2.0, 2.0, 2.0)
		"leather":
			m = _pbr("leather_diff.jpg", "leather_nor.jpg", "leather_rough.jpg")
			m.albedo_color = Color(0.85, 0.48, 0.28)
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
			m.roughness = 0.72
		"mud":
			m = _pbr("mud_diff.jpg", "mud_nor.jpg", "mud_rough.jpg")
			m.albedo_color = Color(0.42, 0.32, 0.24)
			m.uv1_scale = Vector3(8, 8, 8)
			m.roughness = 0.55
			m.metallic = 0.08
		"ground":
			m = _pbr("ground_diff.jpg", "ground_nor.jpg", "ground_rough.jpg")
			m.albedo_color = Color(0.55, 0.5, 0.38)
			m.uv1_scale = Vector3(10, 10, 10)
			m.roughness = 0.92
		"rope":
			m = _pbr("leather_diff.jpg", "leather_nor.jpg", "leather_rough.jpg")
			m.albedo_color = Color(0.55, 0.42, 0.26)
			m.uv1_scale = Vector3(4, 1, 4)
			m.roughness = 0.9
		"metal":
			m = StandardMaterial3D.new()
			m.albedo_color = Color(0.18, 0.16, 0.14)
			m.metallic = 0.82
			m.roughness = 0.48
		"hill":
			m = _pbr("ground_diff.jpg", "ground_nor.jpg", "ground_rough.jpg")
			m.albedo_color = Color(0.22, 0.2, 0.2)
			m.roughness = 1.0
			m.uv1_scale = Vector3(4, 2, 4)
		"mist":
			m = StandardMaterial3D.new()
			m.albedo_color = Color(0.55, 0.48, 0.5, 0.22)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
			m.roughness = 1.0
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		"grass":
			m = StandardMaterial3D.new()
			m.albedo_texture = _grass_tex()
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			m.alpha_scissor_threshold = 0.4
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
			m.roughness = 0.95
		_:
			m = _pbr("plank_diff.jpg", "plank_nor.jpg", "plank_rough.jpg")
	return m


static func _grass_tex() -> Texture2D:
	if _tex_cache.has("grass"):
		return _tex_cache["grass"]
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for i in 18:
		var x0 := 8 + (i * 3) % 48
		var h := 28 + (i * 7) % 24
		var lean := ((i % 5) - 2) * 0.35
		for y in h:
			var x := int(float(x0) + lean * float(y) * 0.08)
			if x < 0 or x > 63:
				continue
			var t := 1.0 - float(y) / float(h)
			var g := 0.18 + t * 0.22
			img.set_pixel(x, 63 - y, Color(g * 0.55, g, g * 0.28, 1.0))
			if x + 1 < 64:
				img.set_pixel(x + 1, 63 - y, Color(g * 0.4, g * 0.85, g * 0.22, 0.85))
	var tex := ImageTexture.create_from_image(img)
	_tex_cache["grass"] = tex
	return tex


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


static func _beam(parent: Node3D, from: Vector3, to: Vector3, radius: float, kind: String) -> void:
	var mi := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	var length: float = from.distance_to(to)
	cyl.height = length
	cyl.top_radius = radius
	cyl.bottom_radius = radius * 1.05
	cyl.radial_segments = 10
	mi.mesh = cyl
	mi.material_override = mat(kind)
	mi.transform = _orient_along(from, to)
	parent.add_child(mi)


static func add_log(parent: Node3D, pos: Vector3, height: float, radius: float, yaw: float = 0.0, lean: float = 0.0) -> MeshInstance3D:
	var root := Node3D.new()
	root.position = pos
	root.rotation_degrees = Vector3(lean, yaw, 0.0)
	var shaft := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius * 0.78
	cyl.bottom_radius = radius * 1.08
	cyl.height = height
	cyl.radial_segments = 14
	cyl.rings = 3
	shaft.mesh = cyl
	shaft.material_override = mat("bark")
	shaft.position = Vector3(0, height * 0.5, 0)
	shaft.scale = Vector3(1.0, 1.0, 0.88)
	root.add_child(shaft)
	var tip := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.008
	cone.bottom_radius = radius * 0.82
	cone.height = radius * 3.1
	cone.radial_segments = 10
	tip.mesh = cone
	tip.material_override = mat("bark")
	tip.position = Vector3(0, height + radius * 1.35, 0)
	root.add_child(tip)
	for band_t in [0.38, 0.68]:
		var lash := MeshInstance3D.new()
		var band := CylinderMesh.new()
		band.top_radius = radius * 1.18
		band.bottom_radius = radius * 1.18
		band.height = 0.055
		band.radial_segments = 10
		lash.mesh = band
		lash.material_override = mat("rope")
		lash.position = Vector3(0, height * band_t, 0)
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
	var count := maxi(int(length / 0.32), 2)
	var posts: Array[Vector3] = []
	for i in count:
		var t := float(i) / float(count - 1)
		var jitter := float((seed_n * 17 + i * 31) % 10) * 0.014
		var h := 2.45 + float((seed_n + i * 7) % 13) * 0.11
		var r := 0.10 + float((i * 3 + seed_n) % 5) * 0.016
		var pos := from.lerp(to, t) + side * (jitter - 0.05)
		pos.y = from.y
		var lean := float((i * 5 + seed_n) % 7) - 3.0
		add_log(parent, pos, h, r, float(i * 27), lean * 0.85)
		posts.append(pos)
	for rail_h in [1.05, 1.72]:
		for i in range(0, posts.size() - 1, 2):
			var a := posts[i] + Vector3(0, rail_h, 0)
			var b := posts[mini(i + 2, posts.size() - 1)] + Vector3(0, rail_h + 0.04, 0)
			_beam(parent, a, b, 0.028, "rope")
	var wall := StaticBody3D.new()
	wall.collision_layer = Combat.LAYER_WORLD
	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.5, 2.9, length)
	col.shape = box
	wall.add_child(col)
	parent.add_child(wall)
	var mid := from.lerp(to, 0.5) + Vector3(0, 1.4, 0)
	var xaxis := dir.cross(Vector3.UP)
	if xaxis.length_squared() < 0.0001:
		xaxis = Vector3.RIGHT
	xaxis = xaxis.normalized()
	wall.transform = Transform3D(Basis(xaxis, Vector3.UP, dir), mid)


static func crate(parent: Node3D, pos: Vector3, size: Vector3 = Vector3(0.72, 0.55, 0.72), yaw: float = 0.0, covered: bool = false) -> MeshInstance3D:
	var root := Node3D.new()
	root.position = pos
	root.rotation_degrees.y = yaw
	parent.add_child(root)
	var body := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	body.mesh = box
	body.material_override = mat("plank")
	root.add_child(body)
	## Frame battens so it reads as built timber, not a single cube.
	for edge in [
		Vector3(size.x * 0.5, 0, 0), Vector3(-size.x * 0.5, 0, 0),
		Vector3(0, 0, size.z * 0.5), Vector3(0, 0, -size.z * 0.5),
	]:
		var slat := MeshInstance3D.new()
		var slat_mesh := BoxMesh.new()
		if absf(edge.x) > 0.01:
			slat_mesh.size = Vector3(0.04, size.y * 1.02, size.z * 0.98)
		else:
			slat_mesh.size = Vector3(size.x * 0.98, size.y * 1.02, 0.04)
		slat.mesh = slat_mesh
		slat.material_override = mat("plank")
		slat.position = edge
		root.add_child(slat)
	var lid := MeshInstance3D.new()
	var lid_mesh := BoxMesh.new()
	lid_mesh.size = Vector3(size.x * 1.04, 0.05, size.z * 1.04)
	lid.mesh = lid_mesh
	lid.material_override = mat("plank")
	lid.position = Vector3(0.02, size.y * 0.52, 0.0)
	lid.rotation_degrees = Vector3(0, 4.0, 2.0)
	root.add_child(lid)
	if covered:
		sagging_cloth(root, Vector3(0.0, size.y * 0.58, 0.04), Vector2(size.x * 1.15, size.z * 1.2), Vector3(8, 12, -6), 0.08, "leather")
	return body


static func barrel(parent: Node3D, pos: Vector3) -> void:
	var body := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.26
	cyl.bottom_radius = 0.28
	cyl.height = 0.64
	cyl.radial_segments = 16
	body.mesh = cyl
	body.material_override = mat("plank")
	body.position = pos + Vector3(0, 0.32, 0)
	parent.add_child(body)
	var bulge := MeshInstance3D.new()
	var mid := CylinderMesh.new()
	mid.top_radius = 0.3
	mid.bottom_radius = 0.3
	mid.height = 0.22
	mid.radial_segments = 16
	bulge.mesh = mid
	bulge.material_override = mat("plank")
	bulge.position = pos + Vector3(0, 0.32, 0)
	parent.add_child(bulge)
	for yoff in [0.08, 0.32, 0.56]:
		var hoop := MeshInstance3D.new()
		var ring := CylinderMesh.new()
		ring.top_radius = 0.315
		ring.bottom_radius = 0.315
		ring.height = 0.028
		ring.radial_segments = 16
		hoop.mesh = ring
		hoop.material_override = mat("metal")
		hoop.position = pos + Vector3(0, yoff, 0)
		parent.add_child(hoop)


static func sagging_cloth(parent: Node3D, pos: Vector3, size: Vector2, rot: Vector3, sag: float, kind: String = "cloth") -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segs_x := 8
	var segs_z := 6
	for z in segs_z + 1:
		for x in segs_x + 1:
			var u := float(x) / float(segs_x)
			var v := float(z) / float(segs_z)
			var px := (u - 0.5) * size.x
			var pz := (v - 0.5) * size.y
			var py := -sag * sin(u * PI) * sin(v * PI)
			st.set_uv(Vector2(u * 2.0, v * 2.0))
			st.add_vertex(Vector3(px, py, pz))
	for z in segs_z:
		for x in segs_x:
			var i := z * (segs_x + 1) + x
			st.add_index(i)
			st.add_index(i + 1)
			st.add_index(i + segs_x + 1)
			st.add_index(i + 1)
			st.add_index(i + segs_x + 2)
			st.add_index(i + segs_x + 1)
			st.add_index(i)
			st.add_index(i + segs_x + 1)
			st.add_index(i + 1)
			st.add_index(i + 1)
			st.add_index(i + segs_x + 1)
			st.add_index(i + segs_x + 2)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat(kind)
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)


static func cloth_sheet(parent: Node3D, pos: Vector3, size: Vector2, rot: Vector3, sag: float = 12.0) -> void:
	sagging_cloth(parent, pos, size, rot + Vector3(sag, 0, 0), 0.22, "cloth")


static func lean_to(parent: Node3D, origin: Vector3, yaw: float) -> void:
	var root := Node3D.new()
	root.position = origin
	root.rotation_degrees.y = yaw
	parent.add_child(root)
	var posts: Array[Vector3] = [
		Vector3(-1.2, 0, -0.9), Vector3(1.2, 0, -0.9),
		Vector3(-1.15, 0, 1.0), Vector3(1.1, 0, 0.65),
	]
	for xz in posts:
		add_log(root, xz, 2.15 if xz.z < 0.0 else 1.28, 0.065, 16.0, 1.5 if xz.z > 0.0 else 0.0)
	_beam(root, Vector3(-1.2, 2.12, -0.9), Vector3(1.2, 2.12, -0.9), 0.05, "bark")
	_beam(root, Vector3(-1.15, 1.25, 1.0), Vector3(1.1, 1.22, 0.65), 0.04, "bark")
	_beam(root, Vector3(-1.2, 2.12, -0.9), Vector3(-1.15, 1.25, 1.0), 0.035, "bark")
	_beam(root, Vector3(1.2, 2.12, -0.9), Vector3(1.1, 1.22, 0.65), 0.035, "bark")
	sagging_cloth(root, Vector3(0, 1.78, 0.05), Vector2(2.7, 2.35), Vector3(32, 0, 0), 0.28, "cloth")
	sagging_cloth(root, Vector3(0.08, 1.62, 0.12), Vector2(2.45, 2.15), Vector3(36, 7, 0), 0.32, "cloth")
	crate(root, Vector3(-0.55, 0.28, 0.18), Vector3(0.7, 0.5, 0.62), 12.0, true)
	crate(root, Vector3(0.38, 0.22, 0.38), Vector3(0.55, 0.4, 0.5), -18.0, false)
	barrel(root, Vector3(0.95, 0.0, -0.12))


static func tripod(parent: Node3D, origin: Vector3) -> void:
	var root := Node3D.new()
	root.position = origin
	parent.add_child(root)
	var apex := Vector3(0, 3.25, 0)
	var feet: Array[Vector3] = [Vector3(-1.05, 0, 0.62), Vector3(1.05, 0, 0.58), Vector3(0.05, 0, -1.15)]
	for foot in feet:
		_beam(root, foot, apex, 0.048, "bark")
	for wrap_y in [0.0, 0.1, 0.2]:
		var lash := MeshInstance3D.new()
		var wrap := CylinderMesh.new()
		wrap.top_radius = 0.13
		wrap.bottom_radius = 0.13
		wrap.height = 0.07
		wrap.radial_segments = 12
		lash.mesh = wrap
		lash.material_override = mat("rope")
		lash.position = apex + Vector3(0, -0.12 - wrap_y, 0)
		root.add_child(lash)
	for s in [Vector3(-0.5, 0.16, 0.38), Vector3(0.28, 0.14, 0.18), Vector3(0.02, 0.12, -0.4)]:
		var sack := MeshInstance3D.new()
		var sph := SphereMesh.new()
		sph.radius = 0.24
		sph.height = 0.4
		sph.radial_segments = 10
		sack.mesh = sph
		sack.material_override = mat("leather" if s.x < 0.0 else "cloth")
		sack.position = s
		sack.scale = Vector3(1.2, 0.7, 0.95)
		root.add_child(sack)


static func torch_post(parent: Node3D, pos: Vector3, lights: Node3D) -> void:
	add_log(parent, pos, 1.7, 0.065, 8.0, 1.2)
	var bowl := MeshInstance3D.new()
	var bowl_mesh := CylinderMesh.new()
	bowl_mesh.top_radius = 0.16
	bowl_mesh.bottom_radius = 0.08
	bowl_mesh.height = 0.12
	bowl_mesh.radial_segments = 12
	bowl.mesh = bowl_mesh
	bowl.material_override = mat("metal")
	bowl.position = pos + Vector3(0.04, 1.78, 0.0)
	parent.add_child(bowl)
	var flame := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.09
	sph.height = 0.28
	flame.mesh = sph
	var fire := StandardMaterial3D.new()
	fire.albedo_color = Color(1.0, 0.5, 0.16)
	fire.emission_enabled = true
	fire.emission = Color(1.0, 0.42, 0.1)
	fire.emission_energy_multiplier = 6.5
	fire.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	flame.material_override = fire
	flame.position = pos + Vector3(0.04, 1.98, 0.0)
	parent.add_child(flame)
	var glow := MeshInstance3D.new()
	var halo := SphereMesh.new()
	halo.radius = 0.22
	halo.height = 0.22
	glow.mesh = halo
	var halo_mat := StandardMaterial3D.new()
	halo_mat.albedo_color = Color(1.0, 0.45, 0.12, 0.18)
	halo_mat.emission_enabled = true
	halo_mat.emission = Color(1.0, 0.4, 0.08)
	halo_mat.emission_energy_multiplier = 2.2
	halo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	halo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.material_override = halo_mat
	glow.position = pos + Vector3(0.04, 1.98, 0.0)
	parent.add_child(glow)
	var lamp := OmniLight3D.new()
	lamp.position = pos + Vector3(0, 2.05, 0)
	lamp.light_color = Color(1.0, 0.55, 0.22)
	lamp.light_energy = 5.4
	lamp.omni_range = 13.0
	lamp.omni_attenuation = 1.4
	lamp.shadow_enabled = true
	lights.add_child(lamp)


static func timber_gate(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.rotation_degrees.y = yaw
	parent.add_child(root)
	add_log(root, Vector3(-1.3, 0, 0), 3.25, 0.15, 0, 0)
	add_log(root, Vector3(1.3, 0, 0), 3.12, 0.15, 10, 1.2)
	_beam(root, Vector3(-1.35, 3.12, 0), Vector3(1.35, 3.05, 0), 0.09, "plank")
	_beam(root, Vector3(-1.28, 2.72, 0.08), Vector3(1.28, 2.68, 0.08), 0.045, "rope")


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
		plane.size = Vector2(0.34, 0.42)
		blade.mesh = plane
		blade.material_override = mat("grass")
		blade.position = pos + Vector3(float(i) * 0.05 - 0.05, 0.2, float(i % 2) * 0.04)
		blade.rotation_degrees = Vector3(82, float(i) * 55.0, 0)
		parent.add_child(blade)


static func mud_ground(parent: Node3D, pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	body.collision_layer = Combat.LAYER_WORLD
	var mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(size.x, size.z)
	plane.subdivide_width = 12
	plane.subdivide_depth = 12
	mi.mesh = plane
	mi.material_override = mat("ground")
	mi.position = Vector3(0, size.y * 0.5, 0)
	body.add_child(mi)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	parent.add_child(body)


static func mud_path(parent: Node3D, pos: Vector3, size: Vector3) -> void:
	var mi := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(size.x, size.z)
	plane.subdivide_width = 6
	plane.subdivide_depth = 10
	mi.mesh = plane
	mi.material_override = mat("mud")
	mi.position = pos
	parent.add_child(mi)


static func valley(parent: Node3D, origin: Vector3) -> void:
	for i in 6:
		var hill := MeshInstance3D.new()
		var sph := SphereMesh.new()
		sph.radius = 7.0 + float(i) * 2.4
		sph.height = 5.5 + float(i) * 1.1
		sph.radial_segments = 12
		sph.rings = 8
		hill.mesh = sph
		hill.material_override = mat("hill")
		hill.position = origin + Vector3(float(i - 2) * 11.0, -1.2, 14.0 + float(i) * 5.5)
		hill.scale = Vector3(1.9, 0.48, 1.5)
		parent.add_child(hill)
	for i in 3:
		var mist := MeshInstance3D.new()
		var plane := PlaneMesh.new()
		plane.size = Vector2(28, 10)
		mist.mesh = plane
		mist.material_override = mat("mist")
		mist.position = origin + Vector3(0, 3.2 + float(i) * 1.4, 8 + float(i) * 6)
		mist.rotation_degrees = Vector3(8, float(i) * 12.0 - 12.0, 0)
		parent.add_child(mist)


static func watch_post(parent: Node3D, origin: Vector3, lights: Node3D, _title: String) -> void:
	var radius := 1.45
	for i in 9:
		var ang := float(i) / 9.0 * TAU
		var p := origin + Vector3(cos(ang) * radius, 0, sin(ang) * radius)
		add_log(parent, p, 2.55 + float(i % 3) * 0.1, 0.09, float(i * 18), float(i % 4) - 1.5)
	var deck := StaticBody3D.new()
	deck.position = origin + Vector3(0, 2.05, 0)
	deck.collision_layer = Combat.LAYER_WORLD
	var deck_mesh := MeshInstance3D.new()
	var deck_box := BoxMesh.new()
	deck_box.size = Vector3(2.2, 0.1, 2.2)
	deck_mesh.mesh = deck_box
	deck_mesh.material_override = mat("plank")
	deck.add_child(deck_mesh)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = deck_box.size
	col.shape = shape
	deck.add_child(col)
	parent.add_child(deck)
	plank_ramp(parent, origin + Vector3(1.55, 1.0, 0.15), Vector3(2.1, 0.09, 0.65), -28.0, 8.0)
	torch_post(parent, origin + Vector3(0.0, 0.0, -0.15), lights)
