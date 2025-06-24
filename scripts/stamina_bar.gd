extends ProgressBar

@onready var player: CharacterBody2D = $".."

func _ready() -> void:
	if player.has_method("take_damage"):
		max_value = player.max_stamina
		value = player.max_stamina

func update_stamina(stamina: int):
	value = stamina
