extends Node3D

## Run scene. F5 is the undercroft. Fallen castle is instanced and swapped in via the breach.

const CASTLE_SCENE := preload("res://ruins/fallen_castle/fallen_castle.tscn")

@onready var level: Line7Undercroft = $Line7Undercroft
@onready var he: HE = $HE
@onready var herald: HollowHerald = $HollowHerald

var castle
var _under_env: Environment
var _castle_env: Environment


func _ready() -> void:
	he.global_position = level.player_spawn
	herald.global_position = level.herald_spawn
	herald._home = level.herald_spawn
	Game.player = he
	Game.herald = herald
	Game.current_pocket = "undercroft"
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	castle = CASTLE_SCENE.instantiate()
	castle.visible = false
	castle.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(castle)
	_under_env = level.world_env.environment
	_castle_env = castle.get_node("WorldEnvironment").environment
	castle.get_node("WorldEnvironment").environment = null
	Game.pocket_requested.connect(_on_pocket)


func _on_pocket(pocket_id: String) -> void:
	if pocket_id == "fallen_castle":
		_show_castle()
	else:
		_show_undercroft()


func _show_castle() -> void:
	level.visible = false
	level.process_mode = Node.PROCESS_MODE_DISABLED
	herald.visible = false
	herald.process_mode = Node.PROCESS_MODE_DISABLED
	castle.visible = true
	castle.process_mode = Node.PROCESS_MODE_INHERIT
	level.world_env.environment = null
	castle.get_node("WorldEnvironment").environment = _castle_env
	var spawn: Vector3 = castle.get("player_spawn")
	if typeof(spawn) != TYPE_VECTOR3:
		spawn = Vector3(0.0, 1.05, 2.4)
	he.global_position = spawn
	he.velocity = Vector3.ZERO
	Game.banner("GUARD CAMP\nPalisade watch. Lean-tos still stand.")


func _show_undercroft() -> void:
	castle.visible = false
	castle.process_mode = Node.PROCESS_MODE_DISABLED
	level.visible = true
	level.process_mode = Node.PROCESS_MODE_INHERIT
	herald.visible = true
	herald.process_mode = Node.PROCESS_MODE_INHERIT
	castle.get_node("WorldEnvironment").environment = null
	level.world_env.environment = _under_env
	he.global_position = Game.undercroft_return
	he.velocity = Vector3.ZERO
	Game.banner("LINE 7 — UNDERCROFT")
