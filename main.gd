extends Node3D

## Run scene. Places HE and the Hollow Herald into the Line 7 undercroft loop.

@onready var level: Line7Undercroft = $Line7Undercroft
@onready var he: HE = $HE
@onready var herald: HollowHerald = $HollowHerald


func _ready() -> void:
	he.global_position = level.player_spawn
	herald.global_position = level.herald_spawn
	herald._home = level.herald_spawn
	Game.player = he
	Game.herald = herald
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
