extends Node2D

@export var speed: float = 200

func _process(delta: float) -> void:
	position.x += speed * delta
