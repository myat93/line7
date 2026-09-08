class_name Combat
extends RefCounted

## Shared numbers for the Line 7 first-playable combat slice.

## Playtest: leave these false so HE can spam attacks and move freely.
## Flip either back to true to restore spend/block and miss punish.
const STAMINA_GATING := false
const WHIFF_PUNISH := false

const PLAYER_MAX_HP := 100
const PLAYER_MAX_STAMINA := 100.0
const STAMINA_REGEN := 24.0
const STAMINA_REGEN_DELAY := 0.55
const WHIFF_REGEN_DELAY := 1.2
const SPRINT_DRAIN := 14.0
const ROLL_COST := 20.0
const ROLL_TIME := 0.4
const ROLL_IFRAMES := 0.22
const ROLL_SPEED := 8.6
const WALK_SPEED := 2.4
const SPRINT_SPEED := 6.4
const MOVE_ACCEL := 8.0
const SPRINT_ACCEL := 16.0
const MOVE_DECEL := 12.0
const GRAVITY := 28.0
const JUMP_VELOCITY := 8.8

const HERALD_MAX_HP := 72
const HERALD_WALK := 1.15
const HERALD_AGGRO := 10.5
const HERALD_SWIPE_DAMAGE := 20
const HERALD_LUNGE_DAMAGE := 32

const LAYER_WORLD := 1
const LAYER_PLAYER := 2
const LAYER_ENEMY := 4
const LAYER_PLAYER_HIT := 8
const LAYER_ENEMY_HIT := 16
const LAYER_HURT := 32
const LAYER_INTERACT := 64


static func fists_light() -> Dictionary:
	return {
		"id": "jab",
		"damage": 8,
		"stamina": 12.0,
		"whiff_stamina": 14.0,
		"windup": 0.08,
		"active": 0.12,
		"recovery": 0.22,
		"reach": 1.32,
		"width": 0.42,
		"knockback": 1.6,
		"heavy": false,
	}


static func fists_heavy() -> Dictionary:
	return {
		"id": "heavy",
		"damage": 18,
		"stamina": 26.0,
		"whiff_stamina": 18.0,
		"windup": 0.32,
		"active": 0.14,
		"recovery": 0.42,
		"reach": 1.52,
		"width": 0.5,
		"knockback": 3.2,
		"heavy": true,
	}


static func ashpike_light() -> Dictionary:
	return {
		"id": "pike_jab",
		"damage": 14,
		"stamina": 16.0,
		"whiff_stamina": 12.0,
		"windup": 0.12,
		"active": 0.12,
		"recovery": 0.28,
		"reach": 2.35,
		"width": 0.32,
		"knockback": 2.1,
		"heavy": false,
	}


static func ashpike_heavy() -> Dictionary:
	return {
		"id": "pike_thrust",
		"damage": 26,
		"stamina": 32.0,
		"whiff_stamina": 16.0,
		"windup": 0.38,
		"active": 0.16,
		"recovery": 0.48,
		"reach": 2.85,
		"width": 0.36,
		"knockback": 4.0,
		"heavy": true,
	}


static func attack_for(bound_ashpike: bool, heavy: bool) -> Dictionary:
	if bound_ashpike:
		return ashpike_heavy() if heavy else ashpike_light()
	return fists_heavy() if heavy else fists_light()
