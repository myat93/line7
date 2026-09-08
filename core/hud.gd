extends CanvasLayer

@onready var hp_fill: ColorRect = $Root/Bars/HPBar/Fill
@onready var stam_fill: ColorRect = $Root/Bars/StaminaBar/Fill
@onready var herald_fill: ColorRect = $Root/Herald/Bar/Fill
@onready var herald_wrap: Control = $Root/Herald
@onready var stance: Label = $Root/Stance
@onready var prompt: Label = $Root/Prompt
@onready var banner: Label = $Root/Banner
@onready var death: ColorRect = $Root/DeathVeil

var _banner_left: float = 0.0


func _ready() -> void:
	Game.banner_changed.connect(_on_banner)
	Game.prompt_changed.connect(_on_prompt)
	Game.hud_dirty.connect(_refresh)
	Game.player_died.connect(_on_death)
	banner.text = ""
	prompt.text = ""
	death.visible = false
	_refresh()


func _process(delta: float) -> void:
	if _banner_left > 0.0:
		_banner_left -= delta
		if _banner_left <= 0.0:
			banner.text = ""
	_refresh()


func _refresh() -> void:
	var he := Game.player
	if he and he.has_method("get_vitals"):
		var vitals: Dictionary = he.get_vitals()
		_set_fill(hp_fill, float(vitals.get("hp", 0)) / float(Combat.PLAYER_MAX_HP), 280.0)
		_set_fill(stam_fill, float(vitals.get("stamina", 0.0)) / Combat.PLAYER_MAX_STAMINA, 280.0)
	stance.text = Game.stance_label()
	var herald := Game.herald
	if herald and is_instance_valid(herald) and herald.has_method("get_hp") and not Game.herald_dead:
		herald_wrap.visible = true
		_set_fill(herald_fill, float(herald.get_hp()) / float(Combat.HERALD_MAX_HP), 360.0)
	else:
		herald_wrap.visible = Game.herald != null and not Game.herald_dead


func _set_fill(rect: ColorRect, ratio: float, full_width: float) -> void:
	rect.size.x = full_width * clampf(ratio, 0.0, 1.0)


func _on_banner(text: String, duration: float) -> void:
	banner.text = text
	_banner_left = duration


func _on_prompt(text: String) -> void:
	prompt.text = text


func _on_death() -> void:
	death.visible = true
