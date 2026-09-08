@tool
extends EditorScript

## Editor helper: prints spawn / duel / shrine markers after opening the undercroft.

func _run() -> void:
	var packed: PackedScene = load("res://ruins/line7_undercroft/line7_undercroft.tscn")
	if packed == null:
		push_error("Could not load Line 7 undercroft.")
		return
	var level: Line7Undercroft = packed.instantiate()
	print("Player spawn: ", level.player_spawn)
	print("Herald spawn: ", level.herald_spawn)
	print("Shrine: ", level.shrine_pos)
	level.free()
