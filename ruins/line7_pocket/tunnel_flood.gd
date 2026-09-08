class_name TunnelFlood
extends Node3D

## Tight flooded service corridor. One jump gap; hanging pipe is walk-under flavor.

const TILE := preload("res://ruins/line7_pocket/materials/tile.tres")
const RUST := preload("res://ruins/line7_pocket/materials/rust_metal.tres")
const CONCRETE := preload("res://ruins/line7_undercroft/materials/concrete.tres")
const WATER := preload("res://ruins/line7_undercroft/materials/water.tres")

## Local +Z is the walk. Gap is ~1.9 m — walk-jumpable, sprint is easy.
const LENGTH := 16.0
const HALF_W := 1.7
const GAP_START := 7.4
const GAP_END := 9.3


func _ready() -> void:
	name = "tunnel_flood"
	_build_shell()
	_build_floors()
	_build_gap()
	_build_pipe()
	_light()


func _build_shell() -> void:
	var wall := CONCRETE.duplicate() as StandardMaterial3D
	wall.albedo_color = Color(0.18, 0.2, 0.22)
	PocketGeo.box(self, Vector3(-HALF_W - 0.25, 1.6, LENGTH * 0.5), Vector3(0.5, 3.4, LENGTH), wall, true)
	PocketGeo.box(self, Vector3(HALF_W + 0.25, 1.6, LENGTH * 0.5), Vector3(0.5, 3.4, LENGTH), wall, true)
	PocketGeo.box(self, Vector3(0.0, 3.35, LENGTH * 0.5), Vector3(HALF_W * 2.0 + 1.0, 0.28, LENGTH), wall, true)
	var wet := WATER.duplicate() as StandardMaterial3D
	wet.albedo_color = Color(0.1, 0.24, 0.26, 0.5)
	PocketGeo.box(self, Vector3(0.0, 0.08, LENGTH * 0.5), Vector3(HALF_W * 2.0, 0.12, LENGTH), wet, false)


func _build_floors() -> void:
	var near_len := GAP_START
	var far_len := LENGTH - GAP_END
	PocketGeo.box(self, Vector3(0.0, 0.48, near_len * 0.5), Vector3(HALF_W * 2.0 - 0.15, 0.96, near_len), TILE, true)
	PocketGeo.box(self, Vector3(0.0, 0.48, GAP_END + far_len * 0.5), Vector3(HALF_W * 2.0 - 0.15, 0.96, far_len), TILE, true)


func _build_gap() -> void:
	## Catch floor so a missed jump is a wade, not a death / softlock.
	PocketGeo.box(self, Vector3(0.0, 0.12, (GAP_START + GAP_END) * 0.5), Vector3(HALF_W * 2.0 - 0.2, 0.24, GAP_END - GAP_START), TILE, true)
	PocketGeo.box(self, Vector3(0.0, 0.22, (GAP_START + GAP_END) * 0.5), Vector3(HALF_W * 2.0 - 0.25, 0.08, GAP_END - GAP_START - 0.1), WATER, false)
	## Lip edges so the jump reads.
	PocketGeo.box(self, Vector3(0.0, 0.92, GAP_START - 0.08), Vector3(HALF_W * 2.0 - 0.2, 0.12, 0.16), RUST, true)
	PocketGeo.box(self, Vector3(0.0, 0.92, GAP_END + 0.08), Vector3(HALF_W * 2.0 - 0.2, 0.12, 0.16), RUST, true)


func _build_pipe() -> void:
	## Ceiling mains only — roll does not crouch the capsule, so the verb is the jump.
	PocketGeo.capsule(self, Vector3(0.0, 3.05, 12.4), 0.12, 3.2, RUST, Vector3(0.0, 0.0, 90.0))
	PocketGeo.capsule(self, Vector3(0.4, 3.08, 4.6), 0.08, 2.4, RUST, Vector3(0.0, 12.0, 90.0))
	PocketGeo.box(self, Vector3(0.0, 3.22, 12.4), Vector3(0.2, 0.22, 0.2), RUST, false)
	PocketGeo.label(self, Vector3(0.0, 1.7, (GAP_START + GAP_END) * 0.5), "GAP", Color(0.55, 0.85, 0.82), 40)


func _light() -> void:
	PocketGeo.omni(self, Vector3(0.0, 2.6, 3.2), Color(0.55, 0.7, 0.68), 1.6, 7.0)
	PocketGeo.omni(self, Vector3(0.0, 2.4, 8.35), Color(0.35, 0.55, 0.58), 1.1, 6.0)
	PocketGeo.omni(self, Vector3(0.0, 2.6, 13.4), Color(0.55, 0.7, 0.68), 1.6, 7.0)
