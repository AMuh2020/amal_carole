extends ProgressBar

@onready var player: CharacterBody2D = $".."

func _ready() -> void:
	max_value = player.max_health
	value = player.max_health

func update_health(health: int):
	value = health
