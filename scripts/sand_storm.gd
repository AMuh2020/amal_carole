extends Node2D

@export var speed: float = 200
@onready var kill_zone: Area2D = $KillZone

func _process(delta: float) -> void:
	position.x += speed * delta

func _on_body_entered(body: Node2D) -> void:
	print("you died")
	if body.is_in_group("player"):
		body.take_damage(99)
