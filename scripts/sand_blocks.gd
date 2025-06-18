extends StaticBody2D

@onready var area = $Area2D
@onready var timer = $Timer

func _ready():
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	area.connect("body_exited", Callable(self, "_on_body_exited"))
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

var player_on_block := false

func _on_body_entered(body):
	if body.is_in_group("player"):  # Make sure your player node is in "player" group
		player_on_block = true
		timer.start()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_on_block = false
		timer.stop()

func _on_timer_timeout():
	if player_on_block:
		queue_free()  # Remove the block if player stayed for 3 seconds
