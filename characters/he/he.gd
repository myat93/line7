class_name HE
extends CharacterBody3D

## Protagonist. Starts unarmed. Weighty walk, short-reach fists. Jump on Space; roll on Ctrl.

enum State { FREE, ATTACK, ROLL, HITSTUN, DEAD }

var hp: int = Combat.PLAYER_MAX_HP
var stamina: float = Combat.PLAYER_MAX_STAMINA
var state: State = State.FREE

var _stam_delay: float = 0.0
var _state_time: float = 0.0
var _attack: Dictionary = {}
var _attack_hit: bool = false
var _roll_dir: Vector3 = Vector3.FORWARD
var _look_yaw: float = PI
var _look_pitch: float = -0.12
var _iframe: float = 0.0
var _roll_held: bool = false

const BLOCKOUT_SCENE: PackedScene = preload("res://characters/he/he_realistic.glb")
const POSE_PARTS: PackedStringArray = [
	"Hips", "Torso", "Head",
	"L_UpperArm", "L_Forearm", "L_Fist",
	"R_UpperArm", "R_Forearm", "R_Fist",
	"L_Thigh", "L_Shin", "R_Thigh", "R_Shin",
]

@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring: SpringArm3D = $CameraPivot/SpringArm3D
@onready var mesh_root: Node3D = $MeshRoot
@onready var jab_box: Hitbox = $Hitboxes/Jab
@onready var heavy_box: Hitbox = $Hitboxes/Heavy
@onready var pike_box: Hitbox = $Hitboxes/Pike
@onready var hurt: Hurtbox = $Hurtbox
@onready var ashpike_visual: Ashpike = $MeshRoot/Ashpike
@onready var pose_player: AnimationPlayer = $MeshRoot/PosePlayer

var _sprinting: bool = false
var _moving: bool = false
var _stride: float = 0.0
var _blockout: Node3D
var _rig := MeshPoseRig.new()


func _ready() -> void:
	add_to_group("player")
	Game.player = self
	collision_layer = Combat.LAYER_PLAYER
	collision_mask = Combat.LAYER_WORLD | Combat.LAYER_ENEMY
	hurt.team = &"player"
	hurt.host = self
	hurt.hit_received.connect(_on_hurt)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mesh_root.rotation.y = PI
	camera_pivot.rotation = Vector3(_look_pitch, _look_yaw, 0.0)
	_bind_blockout()
	_refresh_stance_visual()
	floor_snap_length = 0.3


func get_vitals() -> Dictionary:
	return {"hp": hp, "stamina": stamina}


func get_hurtbox() -> Hurtbox:
	return hurt


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_look_yaw -= event.relative.x * 0.0026
		_look_pitch = clampf(_look_pitch - event.relative.y * 0.0022, -1.15, 0.45)
	if state == State.DEAD:
		return
	if event.is_action_pressed("light_attack"):
		_try_attack(false)
	elif event.is_action_pressed("heavy_attack"):
		_try_attack(true)
	elif event.is_action_pressed("jump"):
		_try_jump()
	elif event_starts_roll(event):
		_try_roll()
	elif event.is_action_pressed("interact"):
		_try_interact()
	elif event.is_action_pressed("bind_ashpike"):
		if Game.bind_ashpike():
			_refresh_stance_visual()
	elif event.is_action_pressed("bind_fists"):
		Game.bind_fists()
		_refresh_stance_visual()


func _input(event: InputEvent) -> void:
	if state == State.DEAD:
		return
	## Ctrl is a modifier; it often never reaches _unhandled_input as "roll".
	if event_starts_roll(event):
		_try_roll()
		get_viewport().set_input_as_handled()


func event_starts_roll(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key := event as InputEventKey
		if not key.pressed or key.echo:
			return false
		if key.keycode == KEY_CTRL or key.physical_keycode == KEY_CTRL:
			return true
	return event.is_action_pressed("roll")


func is_roll_held() -> bool:
	if Input.is_physical_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_CTRL):
		return true
	return Input.is_action_pressed("roll")


func _poll_roll_edge() -> void:
	var held := is_roll_held()
	if held and not _roll_held:
		_try_roll()
	_roll_held = held


func _physics_process(delta: float) -> void:
	_poll_roll_edge()
	if not is_on_floor():
		velocity.y -= Combat.GRAVITY * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0

	if global_position.y < -2.0:
		Game.banner("The flood takes you. Press R.")
		take_hit(999, 0.0, global_position)
		return

	_iframe = maxf(_iframe - delta, 0.0)
	_state_time += delta
	camera_pivot.rotation = Vector3(_look_pitch, _look_yaw, 0.0)

	match state:
		State.DEAD:
			velocity.x = move_toward(velocity.x, 0.0, Combat.MOVE_DECEL * delta)
			velocity.z = move_toward(velocity.z, 0.0, Combat.MOVE_DECEL * delta)
		State.ROLL:
			_tick_roll(delta)
		State.ATTACK:
			_tick_attack(delta)
		State.HITSTUN:
			if _state_time >= 0.38:
				state = State.FREE
			_dampen_move(delta)
		State.FREE:
			_tick_free(delta)

	_regen(delta)
	move_and_slide()
	var planar := Vector2(velocity.x, velocity.z).length()
	if state == State.FREE and planar > 0.15:
		_stride += planar * delta * (2.8 if _sprinting else 2.2)
	_update_visual_pose()


func _tick_free(delta: float) -> void:
	var input_dir := _move_vector()
	var sprinting := is_sprint_held() and input_dir.length() > 0.1
	_sprinting = sprinting
	_moving = input_dir.length() > 0.12
	if sprinting and Combat.STAMINA_GATING:
		if stamina <= 4.0:
			sprinting = false
		else:
			stamina = maxf(stamina - Combat.SPRINT_DRAIN * delta, 0.0)
			_stam_delay = 0.25
	var speed := target_move_speed(sprinting)
	var target := input_dir * speed
	var accel := Combat.MOVE_DECEL
	if input_dir.length() > 0.1:
		accel = Combat.SPRINT_ACCEL if sprinting else Combat.MOVE_ACCEL
	velocity.x = move_toward(velocity.x, target.x, accel * delta)
	velocity.z = move_toward(velocity.z, target.z, accel * delta)
	if input_dir.length() > 0.12:
		_face_direction(input_dir, delta)


func is_sprint_held() -> bool:
	## Shift is a modifier. Poll the key directly so sprint cannot miss InputMap match.
	if Input.is_physical_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_SHIFT):
		return true
	return Input.is_action_pressed("sprint")


func target_move_speed(sprinting: bool) -> float:
	return Combat.SPRINT_SPEED if sprinting else Combat.WALK_SPEED


func _face_direction(dir: Vector3, delta: float) -> void:
	dir.y = 0.0
	if dir.length() < 0.05:
		return
	## Godot forward is -Z. atan2(x, z) is +Z-forward and made HE moonwalk.
	var desired := atan2(-dir.x, -dir.z)
	mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, desired, 1.0 - exp(-14.0 * delta))


func _tick_roll(_delta: float) -> void:
	var planar := _roll_dir * Combat.ROLL_SPEED
	velocity.x = planar.x
	velocity.z = planar.z
	if _state_time >= Combat.ROLL_TIME:
		state = State.FREE
		velocity.x *= 0.4
		velocity.z *= 0.4


func _tick_attack(delta: float) -> void:
	_dampen_move(delta)
	var wind: float = _attack.windup
	var active_end: float = wind + _attack.active
	var total: float = active_end + _attack.recovery
	var box := _active_box()
	if _state_time >= wind and _state_time < active_end:
		if not box.monitoring:
			box.arm(int(_attack.damage), float(_attack.knockback), &"player", self)
			if not box.landed.is_connected(_on_attack_landed):
				box.landed.connect(_on_attack_landed)
	elif box.monitoring:
		box.disarm()
		if not _attack_hit and Combat.WHIFF_PUNISH:
			_apply_whiff()
	if _state_time >= total:
		box.disarm()
		state = State.FREE


func _try_attack(heavy: bool) -> void:
	if state != State.FREE:
		return
	var profile := Combat.attack_for(Game.ashpike_bound, heavy)
	if Combat.STAMINA_GATING:
		if stamina < profile.stamina:
			Game.banner("Winded.")
			return
		stamina -= profile.stamina
		_stam_delay = Combat.STAMINA_REGEN_DELAY
	_attack = profile
	_attack_hit = false
	_state_time = 0.0
	state = State.ATTACK
	_face_herald()
	_place_hitbox(_active_box(), float(profile.reach), float(profile.width))


func _try_jump() -> void:
	if state == State.DEAD or state == State.ROLL:
		return
	if not is_on_floor():
		return
	velocity.y = Combat.JUMP_VELOCITY


func _try_roll() -> void:
	if state != State.FREE:
		return
	if Combat.STAMINA_GATING:
		if stamina < Combat.ROLL_COST:
			Game.banner("Winded.")
			return
		stamina -= Combat.ROLL_COST
		_stam_delay = Combat.STAMINA_REGEN_DELAY
	var dir := _move_vector()
	if dir.length() < 0.1:
		dir = -mesh_root.global_transform.basis.z
	dir.y = 0.0
	_roll_dir = dir.normalized()
	_face_direction(_roll_dir, 1.0)
	_iframe = Combat.ROLL_IFRAMES
	_state_time = 0.0
	state = State.ROLL


func _try_interact() -> void:
	for node in get_tree().get_nodes_in_group("interactable"):
		if node.has_method("can_interact") and node.can_interact():
			if node is Area3D and node.overlaps_body(self):
				node.interact()
				return
			if node is Node3D and global_position.distance_to(node.global_position) < 2.2:
				node.interact()
				return


func take_hit(damage: int, knockback: float, from: Vector3) -> void:
	if state == State.DEAD or _iframe > 0.0:
		return
	hp = maxi(hp - damage, 0)
	var push := global_position - from
	push.y = 0.0
	if push.length() < 0.01:
		push = mesh_root.global_transform.basis.z
	velocity += push.normalized() * knockback
	_state_time = 0.0
	state = State.HITSTUN
	_stam_delay = 0.4
	if hp <= 0:
		state = State.DEAD
		Game.mark_player_dead()
	Game.hud_dirty.emit()


func _on_hurt(damage: int, knockback: float, from: Vector3) -> void:
	take_hit(damage, knockback, from)


func _on_attack_landed(_hurtbox: Hurtbox) -> void:
	_attack_hit = true


func _apply_whiff() -> void:
	if not Combat.WHIFF_PUNISH:
		return
	stamina = maxf(stamina - float(_attack.get("whiff_stamina", 12.0)), 0.0)
	_stam_delay = Combat.WHIFF_REGEN_DELAY
	_attack.recovery = float(_attack.recovery) + 0.28
	Game.banner("Whiff — stamina punished.", 1.4)


func _active_box() -> Hitbox:
	if Game.ashpike_bound:
		return pike_box
	return heavy_box if bool(_attack.get("heavy", false)) else jab_box


func _place_hitbox(box: Hitbox, reach: float, width: float) -> void:
	var forward := -mesh_root.global_transform.basis.z
	box.global_position = global_position + Vector3(0, 1.05, 0) + forward * (reach * 0.55)
	box.look_at(box.global_position + forward, Vector3.UP)
	var shape := box.get_node("CollisionShape3D") as CollisionShape3D
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(width, 0.55, reach)
	shape.shape = box_shape


func _face_herald() -> void:
	var herald := Game.herald
	if herald and is_instance_valid(herald) and global_position.distance_to(herald.global_position) < 8.0:
		var to := herald.global_position - global_position
		to.y = 0.0
		if to.length() > 0.1:
			mesh_root.look_at(global_position + to, Vector3.UP)


func _move_vector() -> Vector3:
	var raw := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var basis := Basis(Vector3.UP, _look_yaw)
	var dir := (basis * Vector3(raw.x, 0.0, raw.y))
	dir.y = 0.0
	if dir.length() > 1.0:
		dir = dir.normalized()
	return dir


func _dampen_move(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, Combat.MOVE_DECEL * 0.65 * delta)
	velocity.z = move_toward(velocity.z, 0.0, Combat.MOVE_DECEL * 0.65 * delta)


func _regen(delta: float) -> void:
	if state == State.DEAD:
		return
	if _stam_delay > 0.0:
		_stam_delay -= delta
		return
	if state == State.ATTACK or state == State.ROLL:
		return
	stamina = minf(stamina + Combat.STAMINA_REGEN * delta, Combat.PLAYER_MAX_STAMINA)


func _bind_blockout() -> void:
	_blockout = mesh_root.get_node_or_null("HEBlockout") as Node3D
	if _blockout == null:
		_blockout = BLOCKOUT_SCENE.instantiate() as Node3D
		_blockout.name = "HEBlockout"
		mesh_root.add_child(_blockout)
	## Undo the 0.01 armature so the authored 100× IBM skins Body at 1.8 m.
	_rig.prepare_realistic(_blockout, 1.8)
	_rig.bind_parts(_blockout, POSE_PARTS)
	## PosePlayer is the hook for authored clips. The GLB has none yet, so
	## _update_visual_pose() drives jab / heavy / roll / sprint procedurally.
	if pose_player:
		pose_player.active = true


func _part_rot(part_name: String, extra: Vector3) -> void:
	_rig.set_rot(part_name, extra)


func _part_pos(part_name: String, extra: Vector3) -> void:
	_rig.set_pos(part_name, extra)


func _refresh_stance_visual() -> void:
	if ashpike_visual:
		ashpike_visual.set_bound(Game.ashpike_bound)


func _update_visual_pose() -> void:
	mesh_root.rotation.x = 0.0
	if Game.ashpike_bound and ashpike_visual:
		ashpike_visual.rotation_degrees = Vector3(-18, 0, 12)
		if state == State.ATTACK:
			var t := clampf(_state_time / maxf(float(_attack.get("windup", 0.1)), 0.05), 0.0, 1.0)
			ashpike_visual.position = Vector3(0.22, 0.95, -0.15 - t * 0.35)
		else:
			ashpike_visual.position = Vector3(0.22, 0.95, -0.1)
	match state:
		State.ROLL:
			_pose_roll()
		State.ATTACK:
			if bool(_attack.get("heavy", false)):
				_pose_heavy()
			else:
				_pose_jab()
		State.HITSTUN:
			_pose_idle()
			_part_rot("Torso", Vector3(0.18, 0.12, 0.08))
			_part_rot("Head", Vector3(-0.2, 0.15, 0.0))
		State.DEAD:
			_part_rot("Hips", Vector3(1.2, 0.0, 0.35))
			_part_rot("Torso", Vector3(0.4, 0.0, 0.2))
		_:
			if not is_on_floor() and velocity.y > 0.4:
				_pose_jump()
			elif _sprinting:
				_pose_sprint()
			elif _moving or Vector2(velocity.x, velocity.z).length() > 0.35:
				_pose_walk()
			else:
				_pose_idle()


func _pose_idle() -> void:
	if _rig.skeleton:
		_rig.reset_to_bind()
		return
	_part_pos("Hips", Vector3.ZERO)
	_part_rot("Hips", Vector3.ZERO)
	_part_rot("Torso", Vector3.ZERO)
	_part_rot("Head", Vector3.ZERO)
	_part_rot("L_UpperArm", Vector3(0.28, 0.05, 0.22))
	_part_rot("L_Forearm", Vector3(0.18, 0.0, 0.0))
	_part_rot("L_Fist", Vector3.ZERO)
	_part_rot("R_UpperArm", Vector3(0.28, -0.05, -0.22))
	_part_rot("R_Forearm", Vector3(0.18, 0.0, 0.0))
	_part_rot("R_Fist", Vector3.ZERO)
	_part_rot("L_Thigh", Vector3.ZERO)
	_part_rot("L_Shin", Vector3.ZERO)
	_part_rot("R_Thigh", Vector3.ZERO)
	_part_rot("R_Shin", Vector3.ZERO)


func _pose_walk() -> void:
	## Distance-driven stride so feet read against walk speed (no clock skate).
	_pose_idle()
	var swing := sin(_stride)
	## Legs only — torso extras stretch the 100×-IBM sleeves.
	_part_rot("L_Thigh", Vector3(swing * 0.34, 0.0, 0.0))
	_part_rot("R_Thigh", Vector3(-swing * 0.34, 0.0, 0.0))
	_part_rot("L_Shin", Vector3(maxf(-swing, 0.0) * 0.28, 0.0, 0.0))
	_part_rot("R_Shin", Vector3(maxf(swing, 0.0) * 0.28, 0.0, 0.0))


func _pose_sprint() -> void:
	## Forward lean is negative local Z (Bip01 +X / MeshRoot −Z). Opposite swing.
	## Modest extras only — large ones stretch the 100×-IBM skin.
	_pose_idle()
	var swing := sin(_stride)
	## Legs only. Hip/torso extras stretch the 100×-IBM sleeves across the back.
	_part_rot("L_Thigh", Vector3(swing * 0.42, 0.0, 0.0))
	_part_rot("R_Thigh", Vector3(-swing * 0.42, 0.0, 0.0))
	_part_rot("L_Shin", Vector3(maxf(-swing, 0.0) * 0.40, 0.0, 0.0))
	_part_rot("R_Shin", Vector3(maxf(swing, 0.0) * 0.40, 0.0, 0.0))


func _pose_jab() -> void:
	## Hit window is wind 0.08 + active 0.12. Rest-relative left snap; no IBM flip.
	var wind: float = float(_attack.get("windup", 0.08))
	var active: float = float(_attack.get("active", 0.12))
	var recover: float = float(_attack.get("recovery", 0.22))
	var snap := 1.0
	if _state_time < wind:
		snap = 1.0 - pow(1.0 - clampf(_state_time / maxf(wind, 0.04), 0.0, 1.0), 3.0)
	elif _state_time > wind + active:
		snap = 1.0 - clampf((_state_time - wind - active) / maxf(recover, 0.05), 0.0, 1.0)
	_pose_idle()
	_part_rot("Torso", Vector3(0.0, 0.16, -0.06) * snap)
	_part_rot("Hips", Vector3(0.0, 0.08, -0.03) * snap)
	_part_rot("Head", Vector3(0.04, -0.06, 0.0) * snap)
	_part_rot("L_UpperArm", Vector3(-0.35, 0.22, 0.28) * snap)
	_part_rot("L_Forearm", Vector3(0.22, 0.0, 0.0) * snap)
	_part_rot("L_Fist", Vector3(0.08, 0.0, 0.0) * snap)
	_rig.aim_along_y("L_UpperArm", Vector3(0.05, 0.08, -1.0), snap * 0.34)
	_part_rot("R_UpperArm", Vector3(0.08, -0.06, -0.06))


func _pose_heavy() -> void:
	## Coil through wind 0.32; commit on active 0.14. Rest-relative right arm.
	var wind: float = float(_attack.get("windup", 0.32))
	var active: float = float(_attack.get("active", 0.14))
	var recover: float = float(_attack.get("recovery", 0.42))
	_pose_idle()
	if _state_time < wind:
		var coil := clampf(_state_time / maxf(wind, 0.05), 0.0, 1.0)
		coil = coil * coil
		_part_rot("Torso", Vector3(0.0, -0.16, 0.06) * coil)
		_part_rot("Hips", Vector3(0.0, -0.08, 0.04) * coil)
		_part_rot("Head", Vector3(-0.04, -0.08, 0.0) * coil)
		_part_rot("R_UpperArm", Vector3(0.28, 0.18, 0.20) * coil)
		_part_rot("R_Forearm", Vector3(0.35, 0.0, 0.0) * coil)
		_part_rot("L_UpperArm", Vector3(0.10, 0.06, 0.08) * coil)
	else:
		var commit := 1.0 - pow(1.0 - clampf((_state_time - wind) / 0.10, 0.0, 1.0), 2.0)
		if _state_time > wind + active:
			commit = 1.0 - clampf((_state_time - wind - active) / maxf(recover, 0.05), 0.0, 1.0) * 0.55
		_part_rot("Torso", Vector3(0.0, 0.16, -0.08) * commit)
		_part_rot("Hips", Vector3(0.0, 0.08, -0.04) * commit)
		_part_rot("Head", Vector3(0.05, -0.05, 0.0) * commit)
		_part_rot("R_UpperArm", Vector3(-0.28, -0.12, -0.10) * commit)
		_rig.aim_along_y("R_UpperArm", Vector3(-0.08, 0.06, -1.0), commit * 0.34)
		_part_rot("R_Forearm", Vector3(0.12, 0.0, 0.0))
		_part_rot("R_Fist", Vector3(0.08, 0.0, 0.0) * commit)
		_part_rot("L_UpperArm", Vector3(0.10, 0.06, 0.08))


func _pose_roll() -> void:
	## Crouch-tuck, not a full somersault — large hip extras crumple the IBM skin.
	var tuck := 1.0
	if _state_time > 0.26:
		tuck = 1.0 - clampf((_state_time - 0.26) / 0.14, 0.0, 1.0)
	_pose_idle()
	_part_rot("Head", Vector3(0.08, 0.0, 0.0) * tuck)
	_part_rot("L_Thigh", Vector3(-0.42, 0.0, 0.05) * tuck)
	_part_rot("R_Thigh", Vector3(-0.44, 0.0, -0.05) * tuck)
	_part_rot("L_Shin", Vector3(0.48, 0.0, 0.0) * tuck)
	_part_rot("R_Shin", Vector3(0.46, 0.0, 0.0) * tuck)
	_part_rot("L_Forearm", Vector3(0.18, 0.0, 0.0) * tuck)
	_part_rot("R_Forearm", Vector3(0.18, 0.0, 0.0) * tuck)


func _pose_jump() -> void:
	_pose_idle()
	_part_rot("Hips", Vector3(0.06, 0.0, 0.0))
	_part_rot("Torso", Vector3(0.04, 0.0, 0.0))
	_part_rot("Head", Vector3(-0.06, 0.0, 0.0))
	_part_rot("L_UpperArm", Vector3(-0.18, 0.14, 0.10))
	_part_rot("R_UpperArm", Vector3(-0.18, -0.14, -0.10))
	_part_rot("L_Forearm", Vector3(0.16, 0.0, 0.0))
	_part_rot("R_Forearm", Vector3(0.16, 0.0, 0.0))
	_part_rot("L_Thigh", Vector3(-0.14, 0.0, 0.04))
	_part_rot("R_Thigh", Vector3(0.10, 0.0, -0.04))
