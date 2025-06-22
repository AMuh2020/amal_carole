extends ProgressBar

@onready var skeleton: CharacterBody2D = $".."


func _ready() -> void:
	max_value = skeleton.max_health
	value = skeleton.max_health

func update_health(health: int):
	value = health
