class_name WeaponProfile
extends RefCounted

## Stance table for the slice. Fists are the start. Ashpike is shrine-only.

const FISTS := "fists"
const ASHPIKE := "ashpike"


static func is_starting_weapon() -> String:
	return FISTS


static func pickup_only() -> String:
	return ASHPIKE
