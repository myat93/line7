class_name HollowHerald
extends CharacterBody3D

## Slow, readable bosslet. Telegraph swipe, then telegraph lunge.
## Visual is the realistic transit-coat mesh under MeshRoot. Capsule collision is unchanged.

enum Phase { WAIT, APPROACH, SWIPE_WIND, SWIPE, PAUSE, LUNGE_WIND, LUNGE, REST, DEAD }

const BLOCKOUT_SCENE: PackedScene = preload("res://enemies/hollow_herald/hollow_herald_realistic.glb")
const POSE_PARTS: PackedStringArray = [
	"Hips", "Torso", "Head", "Crown",
	"L_UpperArm", "L_Forearm", "L_Fist",
	"R_UpperArm", "R_Forearm", "R_Fist",
	"L_Thigh", "L_Shin", "R_Thigh", "R_Shin",
]

var hp: int = Combat.HERALD_MAX_HP
var phase: Phase = Phase.WAIT
var _time: float = 0.0
var _home: Vector3 = Vector3.ZERO
var _lunge_dir: Vector3 = Vector3.FORWARD
var _crown_pulse: float = 1.0

@onready var mesh_root: Node3D = $MeshRoot
@onready var swipe_box: Hitbox = $Hitboxes/Swipe
@onready var lunge_box: Hitbox = $Hitboxes/Lunge
@onready var hurt: Hurtbox = $Hurtbox
@onready var telegraph: OmniLight3D = $Telegraph
@onready var pose_player: AnimationPlayer = $MeshRoot/PosePlayer

var _blockout: Node3D
var _rig := MeshPoseRig.new()
var _crown: Node3D


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
	_bind_blockout()


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
	_update_visual_pose()


func take_hit(damage: int, knockback: float, from: Vector3) -> void:
	if phase == Phase.DEAD:
		return
	hp = maxi(hp - damage, 0)
	var push := global_position - from
	push.y = 0.0
	if push.length() > 0.01:
		velocity += push.normalized() * knockback * 0.45
	_crown_pulse = 1.18
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
	_face_player()
	if _time >= 1.15:
		_begin(Phase.SWIPE)
		_place_and_arm(swipe_box, Combat.HERALD_SWIPE_DAMAGE, 2.4, 1.6, 2.2)


func _tick_swipe() -> void:
	if _time >= 0.38:
		swipe_box.disarm()
		telegraph.light_energy = 0.2
		_begin(Phase.PAUSE)


func _tick_lunge_wind() -> void:
	telegraph.light_color = Color(0.85, 0.78, 0.45)
	telegraph.light_energy = 2.0 + sin(_time * 16.0) * 0.5
	_face_player()
	var target := Game.player
	if target:
		_lunge_dir = target.global_position - global_position
		_lunge_dir.y = 0.0
		if _lunge_dir.length() < 0.1:
			_lunge_dir = -mesh_root.global_transform.basis.z
		_lunge_dir = _lunge_dir.normalized()
	if _time >= 1.25:
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


func _bind_blockout() -> void:
	_blockout = mesh_root.get_node_or_null("HeraldBlockout") as Node3D
	if _blockout == null:
		_blockout = BLOCKOUT_SCENE.instantiate() as Node3D
		_blockout.name = "HeraldBlockout"
		mesh_root.add_child(_blockout)
	_apply_realistic_meters()
	_rig.bind_parts(_blockout, POSE_PARTS)
	_crown = _blockout.find_child("Crown", true, false) as Node3D
	if pose_player:
		pose_player.active = true


func _apply_realistic_meters() -> void:
	## Coat / crown are authored in meters on a 0.01 armature. Undo that scale
	## so the raincoat and horns stay ~2 m, then rebuild IBM from rest so the
	## Rocketbox Body can show at 2.05 m instead of collapsing.
	if _blockout == null:
		return
	_rig.prepare_realistic(_blockout, 2.05)


func _part_rot(part_name: String, extra: Vector3) -> void:
	_rig.set_rot(part_name, extra)


func _part_pos(part_name: String, extra: Vector3) -> void:
	_rig.set_pos(part_name, extra)


func _update_visual_pose() -> void:
	mesh_root.rotation.x = 0.0
	mesh_root.scale = Vector3.ONE
	_crown_pulse = move_toward(_crown_pulse, 1.0, 0.02)
	if _crown:
		_crown.scale = Vector3.ONE * _crown_pulse
	match phase:
		Phase.SWIPE_WIND:
			_pose_swipe_wind()
		Phase.SWIPE:
			_pose_swipe()
		Phase.PAUSE:
			_pose_pause()
		Phase.LUNGE_WIND:
			_pose_lunge_wind()
		Phase.LUNGE:
			_pose_lunge()
		Phase.REST:
			_pose_idle()
			_part_rot("Torso", Vector3(0.08, 0.0, 0.0))
		Phase.DEAD:
			_part_pos("Hips", Vector3(0.0, -0.12, 0.0))
			_part_rot("Hips", Vector3(1.15, 0.0, 0.28))
			_part_rot("Torso", Vector3(0.35, 0.0, 0.18))
			_part_rot("Head", Vector3(0.4, 0.2, 0.0))
			_part_rot("R_UpperArm", Vector3(0.4, 0.5, -0.3))
			_part_rot("L_UpperArm", Vector3(0.35, -0.4, 0.3))
		Phase.APPROACH:
			_pose_walk()
		_:
			_pose_idle()


func _pose_idle() -> void:
	_part_pos("Hips", Vector3.ZERO)
	_part_rot("Hips", Vector3.ZERO)
	_part_rot("Torso", Vector3(0.06, 0.0, 0.0))
	_part_rot("Head", Vector3(-0.04, 0.0, 0.0))
	_part_rot("L_UpperArm", Vector3(0.22, 0.06, 0.28))
	_part_rot("L_Forearm", Vector3(0.22, 0.0, 0.0))
	_part_rot("L_Fist", Vector3.ZERO)
	_part_rot("R_UpperArm", Vector3(0.22, -0.06, -0.28))
	_part_rot("R_Forearm", Vector3(0.22, 0.0, 0.0))
	_part_rot("R_Fist", Vector3.ZERO)
	_part_rot("L_Thigh", Vector3.ZERO)
	_part_rot("L_Shin", Vector3.ZERO)
	_part_rot("R_Thigh", Vector3.ZERO)
	_part_rot("R_Shin", Vector3.ZERO)


func _pose_walk() -> void:
	var swing := sin(_time * 6.0)
	_pose_idle()
	_part_rot("Torso", Vector3(0.10, swing * 0.04, 0.0))
	_part_rot("L_UpperArm", Vector3(0.28 + swing * 0.22, 0.06, 0.24))
	_part_rot("R_UpperArm", Vector3(0.28 - swing * 0.22, -0.06, -0.24))
	_part_rot("L_Thigh", Vector3(swing * 0.28, 0.0, 0.0))
	_part_rot("R_Thigh", Vector3(-swing * 0.28, 0.0, 0.0))
	_part_rot("L_Shin", Vector3(maxf(-swing, 0.0) * 0.22, 0.0, 0.0))
	_part_rot("R_Shin", Vector3(maxf(swing, 0.0) * 0.22, 0.0, 0.0))


func _pose_swipe_wind() -> void:
	## Chamber the long right arm high and back for the full 1.15s punish window.
	var coil := clampf(_time / 0.28, 0.0, 1.0)
	coil = coil * coil
	_pose_idle()
	_part_rot("Hips", Vector3(-0.06, -0.22, 0.04) * coil)
	_part_rot("Torso", Vector3(0.08, -0.55, 0.10) * coil)
	_part_rot("Head", Vector3(0.10, 0.35, 0.0) * coil)
	_part_rot("R_UpperArm", Vector3(-1.15, -1.05, -1.85) * coil + Vector3(0.08, 0.0, -0.12))
	_part_rot("R_Forearm", Vector3(0.55, 0.20, -0.15) * coil)
	_part_rot("R_Fist", Vector3(0.30, 0.0, 0.0) * coil)
	_part_rot("L_UpperArm", Vector3(0.15, 0.28, 0.55) * coil + Vector3(0.12, 0.0, 0.18))
	_part_rot("L_Forearm", Vector3(0.35, 0.0, 0.0))


func _pose_swipe() -> void:
	var slash := clampf(_time / 0.20, 0.0, 1.0)
	slash = 1.0 - pow(1.0 - slash, 2.0)
	_pose_idle()
	_part_rot("Hips", Vector3(0.10, 0.28, 0.0) * slash)
	_part_rot("Torso", Vector3(0.16, 0.72, -0.08) * slash)
	_part_rot("Head", Vector3(-0.06, -0.18, 0.0) * slash)
	_part_rot("R_UpperArm", Vector3(0.55, 1.45, 0.15) * slash + Vector3(0.2, 0.0, -0.1))
	_part_rot("R_Forearm", Vector3(0.18, 0.0, 0.0))
	_part_rot("R_Fist", Vector3(0.2, 0.0, 0.0) * slash)
	_part_rot("L_UpperArm", Vector3(0.35, 0.15, 0.42))


func _pose_pause() -> void:
	_pose_idle()
	_part_rot("Torso", Vector3(0.10, 0.12, 0.0))
	_part_rot("R_UpperArm", Vector3(0.35, 0.18, -0.22))
	_part_rot("L_UpperArm", Vector3(0.28, 0.10, 0.32))


func _pose_lunge_wind() -> void:
	## Crouch-coil on joints (do not squash MeshRoot — that flattened the capsule tell).
	var coil := clampf(_time / 0.32, 0.0, 1.0)
	coil = coil * coil
	_pose_idle()
	_part_pos("Hips", Vector3(0.0, -0.22, 0.10) * coil)
	_part_rot("Hips", Vector3(0.28, 0.0, 0.0) * coil)
	_part_rot("Torso", Vector3(0.42, 0.0, 0.0) * coil)
	_part_rot("Head", Vector3(-0.18, 0.0, 0.0) * coil)
	_part_rot("L_Thigh", Vector3(-0.85, 0.0, 0.08) * coil)
	_part_rot("R_Thigh", Vector3(-0.90, 0.0, -0.08) * coil)
	_part_rot("L_Shin", Vector3(1.05, 0.0, 0.0) * coil)
	_part_rot("R_Shin", Vector3(1.10, 0.0, 0.0) * coil)
	_part_rot("L_UpperArm", Vector3(-0.55, 0.35, 0.55) * coil + Vector3(0.1, 0.0, 0.15))
	_part_rot("R_UpperArm", Vector3(-0.62, -0.35, -0.55) * coil + Vector3(0.1, 0.0, -0.15))
	_part_rot("L_Forearm", Vector3(0.75, 0.0, 0.0) * coil)
	_part_rot("R_Forearm", Vector3(0.80, 0.0, 0.0) * coil)


func _pose_lunge() -> void:
	var commit := 1.0 - pow(1.0 - clampf(_time / 0.10, 0.0, 1.0), 2.0)
	_pose_idle()
	_part_pos("Hips", Vector3(0.0, 0.04, -0.08) * commit)
	_part_rot("Hips", Vector3(0.22, 0.0, 0.0) * commit)
	_part_rot("Torso", Vector3(0.55, 0.0, 0.0) * commit)
	_part_rot("Head", Vector3(-0.12, 0.0, 0.0) * commit)
	_part_rot("L_UpperArm", Vector3(1.35, 0.12, 0.08) * commit)
	_part_rot("R_UpperArm", Vector3(1.42, -0.10, -0.08) * commit)
	_part_rot("L_Forearm", Vector3(0.15, 0.0, 0.0))
	_part_rot("R_Forearm", Vector3(0.12, 0.0, 0.0))
	_part_rot("L_Thigh", Vector3(0.35, 0.0, 0.0) * commit)
	_part_rot("R_Thigh", Vector3(-0.15, 0.0, 0.0) * commit)
