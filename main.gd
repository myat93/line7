extends Node3D

## Run scene. F5 is the undercroft. Pockets instance here and swap via gates.

const CASTLE_SCENE := preload("res://ruins/fallen_castle/fallen_castle.tscn")
const POCKET_SCENE := preload("res://ruins/line7_pocket/line7_pocket.tscn")

@onready var level: Line7Undercroft = $Line7Undercroft
@onready var he: HE = $HE
@onready var herald: HollowHerald = $HollowHerald

var castle
var pocket
var _under_env: Environment
var _castle_env: Environment
var _pocket_env: Environment


func _ready() -> void:
	he.global_position = level.player_spawn
	herald.global_position = level.herald_spawn
	herald._home = level.herald_spawn
	Game.player = he
	Game.herald = herald
	Game.current_pocket = "undercroft"
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	castle = CASTLE_SCENE.instantiate()
	pocket = POCKET_SCENE.instantiate()
	_stash(castle)
	_stash(pocket)
	_under_env = level.world_env.environment
	_castle_env = castle.get_node("WorldEnvironment").environment
	_pocket_env = pocket.get_node("WorldEnvironment").environment
	castle.get_node("WorldEnvironment").environment = null
	pocket.get_node("WorldEnvironment").environment = null
	Game.pocket_requested.connect(_on_pocket)


func _stash(node: Node) -> void:
	node.visible = false
	node.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(node)


func _on_pocket(pocket_id: String) -> void:
	match pocket_id:
		"fallen_castle":
			_show_castle()
		"line7_pocket":
			_show_tunnel()
		_:
			_show_undercroft()


func _hide_level() -> void:
	level.visible = false
	level.process_mode = Node.PROCESS_MODE_DISABLED
	herald.visible = false
	herald.process_mode = Node.PROCESS_MODE_DISABLED
	level.world_env.environment = null


func _hide_castle() -> void:
	castle.visible = false
	castle.process_mode = Node.PROCESS_MODE_DISABLED
	castle.get_node("WorldEnvironment").environment = null


func _hide_tunnel() -> void:
	pocket.visible = false
	pocket.process_mode = Node.PROCESS_MODE_DISABLED
	pocket.get_node("WorldEnvironment").environment = null


func _show_castle() -> void:
	_hide_level()
	_hide_tunnel()
	castle.visible = true
	castle.process_mode = Node.PROCESS_MODE_INHERIT
	castle.get_node("WorldEnvironment").environment = _castle_env
	var spawn: Vector3 = castle.get("player_spawn")
	if typeof(spawn) != TYPE_VECTOR3:
		spawn = Vector3(0.0, 1.05, 2.4)
	he.global_position = spawn
	he.velocity = Vector3.ZERO
	Game.banner("GUARD CAMP\nPalisade watch. Lean-tos still stand.")


func _show_tunnel() -> void:
	_hide_level()
	_hide_castle()
	pocket.visible = true
	pocket.process_mode = Node.PROCESS_MODE_INHERIT
	pocket.get_node("WorldEnvironment").environment = _pocket_env
	he.global_position = pocket.player_spawn
	he.velocity = Vector3.ZERO
	Game.banner("SERVICE TUNNEL\nFlooded corridor. Watch the gap.")


func _show_undercroft() -> void:
	_hide_castle()
	_hide_tunnel()
	level.visible = true
	level.process_mode = Node.PROCESS_MODE_INHERIT
	herald.visible = true
	herald.process_mode = Node.PROCESS_MODE_INHERIT
	level.world_env.environment = _under_env
	he.global_position = Game.undercroft_return
	he.velocity = Vector3.ZERO
	Game.banner("LINE 7 — UNDERCROFT")
