class_name HollowHerald
extends CharacterBody3D

## Slow, readable bosslet. Telegraph swipe, then telegraph lunge.

enum Phase { WAIT, APPROACH, SWIPE_WIND, SWIPE, PAUSE, LUNGE_WIND, LUNGE, REST, DEAD }

var hp: int = Combat.HERALD_MAX_HP
var phase: Phase = Phase.WAIT
var _time: float = 0.0
var _home: Vector3 = Vector3.ZERO
var _lunge_dir: Vector3 = Vector3.FORWARD

@onready var mesh_root: Node3D = $MeshRoot
@onready var swipe_box: Hitbox = $Hitboxes/Swipe
@onready var lunge_box: Hitbox = $Hitboxes/Lunge
@onready var hurt: Hurtbox = $Hurtbox
@onready var telegraph: OmniLight3D = $Telegraph
@onready var arm: MeshInstance3D = $MeshRoot/Arm
@onready var crown: MeshInstance3D = $MeshRoot/Crown


func _ready() -> void:
	add_to_group("enemy")
	Game.herald = self
	collision_layer = Combat.LAYER_ENEMY
	collision_mask = Combat.LAYER_WORLD | Combat.LAYER_PLAYER
	hurt.team = &"enemy"
	hurt.host = self
	_home = global_position
	telegraph.light_energy = 0.15
	telegraph.light_color = Color(0.55, 0.5, 0.7)


func get_hp() -> int:
	return hp


func get_hurtbox() -> Hurtbox:
	return hurt


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= Combat.GRAVITY * delta
	else:
		velocity.y = 0.0
	_time += delta
	match phase:
		Phase.DEAD:
			velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
			velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
			mesh_root.position.y = move_toward(mesh_root.position.y, -0.35, delta * 0.4)
		Phase.WAIT, Phase.APPROACH:
			_tick_seek(delta)
		Phase.SWIPE_WIND:
			_tick_swipe_wind()
		Phase.SWIPE:
			_tick_swipe()
		Phase.PAUSE:
			_hold_then(Phase.LUNGE_WIND, 0.55)
			_brake(delta)
		Phase.LUNGE_WIND:
			_tick_lunge_wind()
		Phase.LUNGE:
			_tick_lunge()
		Phase.REST:
			_hold_then(Phase.WAIT, 1.35)
			_brake(delta)
	_clamp_arena()
	move_and_slide()


func take_hit(damage: int, knockback: float, from: Vector3) -> void:
	if phase == Phase.DEAD:
		return
	hp = maxi(hp - damage, 0)
	var push := global_position - from
	push.y = 0.0
	if push.length() > 0.01:
		velocity += push.normalized() * knockback * 0.45
	crown.scale = Vector3(1.15, 1.15, 1.15)
	if hp <= 0:
		_die()
	Game.hud_dirty.emit()


func _die() -> void:
	phase = Phase.DEAD
	swipe_box.disarm()
	lunge_box.disarm()
	telegraph.light_energy = 0.05
	Game.mark_herald_dead()


func _tick_seek(delta: float) -> void:
	var target := Game.player
	if target == null or Game.player_dead:
		_brake(delta)
		return
	var to := target.global_position - global_position
	to.y = 0.0
	var dist := to.length()
	if dist > 0.1:
		mesh_root.look_at(global_position + to, Vector3.UP)
	if dist > Combat.HERALD_AGGRO:
		phase = Phase.WAIT
		_brake(delta)
		return
	if dist > 2.15:
		phase = Phase.APPROACH
		var step := to.normalized() * Combat.HERALD_WALK
		velocity.x = step.x
		velocity.z = step.z
	else:
		_begin(Phase.SWIPE_WIND)
		_brake(delta)


func _tick_swipe_wind() -> void:
	telegraph.light_color = Color(0.85, 0.28, 0.18)
	telegraph.light_energy = 1.6 + sin(_time * 14.0) * 0.4
	arm.rotation_degrees.y = lerpf(arm.rotation_degrees.y, 95.0, 0.12)
	arm.scale = Vector3(1.2, 1.2, 1.4)
	_face_player()
	if _time >= 1.15:
		_begin(Phase.SWIPE)
		_place_and_arm(swipe_box, Combat.HERALD_SWIPE_DAMAGE, 2.4, 1.6, 2.2)


func _tick_swipe() -> void:
	arm.rotation_degrees.y = move_toward(arm.rotation_degrees.y, -80.0, 9.0)
	if _time >= 0.38:
		swipe_box.disarm()
		arm.scale = Vector3.ONE
		telegraph.light_energy = 0.2
		_begin(Phase.PAUSE)


func _tick_lunge_wind() -> void:
	telegraph.light_color = Color(0.85, 0.78, 0.45)
	telegraph.light_energy = 2.0 + sin(_time * 16.0) * 0.5
	mesh_root.scale = Vector3(1.05, 0.82, 1.05)
	_face_player()
	var target := Game.player
	if target:
		_lunge_dir = target.global_position - global_position
		_lunge_dir.y = 0.0
		if _lunge_dir.length() < 0.1:
			_lunge_dir = -mesh_root.global_transform.basis.z
		_lunge_dir = _lunge_dir.normalized()
	if _time >= 1.25:
		mesh_root.scale = Vector3.ONE
		_begin(Phase.LUNGE)
		_place_and_arm(lunge_box, Combat.HERALD_LUNGE_DAMAGE, 1.4, 0.8, 2.6)


func _tick_lunge() -> void:
	velocity.x = _lunge_dir.x * 9.2
	velocity.z = _lunge_dir.z * 9.2
	if _time >= 0.42:
		lunge_box.disarm()
		telegraph.light_energy = 0.15
		telegraph.light_color = Color(0.55, 0.5, 0.7)
		_begin(Phase.REST)


func _place_and_arm(box: Hitbox, damage: int, reach: float, width: float, knock: float) -> void:
	var forward := -mesh_root.global_transform.basis.z
	box.global_position = global_position + Vector3(0, 1.15, 0) + forward * (reach * 0.5)
	box.look_at(box.global_position + forward, Vector3.UP)
	var shape := box.get_node("CollisionShape3D") as CollisionShape3D
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(width, 0.7, reach)
	shape.shape = box_shape
	box.arm(damage, knock, &"enemy", self)


func _face_player() -> void:
	var target := Game.player
	if target == null:
		return
	var to := target.global_position - global_position
	to.y = 0.0
	if to.length() > 0.1:
		mesh_root.look_at(global_position + to, Vector3.UP)


func _begin(next: Phase) -> void:
	phase = next
	_time = 0.0


func _hold_then(next: Phase, duration: float) -> void:
	if _time >= duration:
		_begin(next)


func _brake(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)


func _clamp_arena() -> void:
	global_position.x = clampf(global_position.x, -6.2, 6.2)
	global_position.z = clampf(global_position.z, 10.0, 26.0)
	if global_position.distance_to(_home) > 14.0 and phase == Phase.WAIT:
		global_position = _home
