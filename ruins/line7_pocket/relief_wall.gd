class_name ReliefWall
extends Node3D

## Landmark B — angel-stone relief set in modern tile. Look only. No systems.

const TILE := preload("res://ruins/line7_pocket/materials/tile.tres")
const ANGEL := preload("res://ruins/line7_undercroft/materials/angel_stone.tres")
const CONCRETE := preload("res://ruins/line7_undercroft/materials/concrete.tres")


func _ready() -> void:
	name = "relief_wall"
	_build()


func _build() -> void:
	PocketGeo.box(self, Vector3(0.0, 0.48, 0.0), Vector3(3.2, 0.96, 4.2), TILE, true)
	## Tile wall on +X. No Area3D — nothing to E.
	PocketGeo.box(self, Vector3(1.55, 1.9, 0.0), Vector3(0.22, 2.6, 3.4), TILE, true)
	PocketGeo.box(self, Vector3(-1.55, 1.9, 0.0), Vector3(0.22, 2.6, 3.4), CONCRETE, true)
	## Recessed angel-stone figure.
	PocketGeo.box(self, Vector3(1.38, 1.85, 0.0), Vector3(0.1, 1.9, 1.15), ANGEL, false)
	PocketGeo.box(self, Vector3(1.36, 2.85, 0.0), Vector3(0.16, 0.38, 0.38), ANGEL, false)
	PocketGeo.box(self, Vector3(1.34, 2.15, -0.42), Vector3(0.08, 0.12, 0.7), ANGEL, false)
	PocketGeo.box(self, Vector3(1.34, 2.15, 0.42), Vector3(0.08, 0.12, 0.7), ANGEL, false)
	PocketGeo.omni(self, Vector3(0.6, 2.4, 0.0), Color(1.0, 0.86, 0.55), 1.6, 6.5)
	PocketGeo.label(self, Vector3(0.4, 1.55, 0.0), "RELIEF", Color(0.9, 0.82, 0.6), 28)
