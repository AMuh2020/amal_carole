extends StaticBody2D

@onready var area = $Area2D
@onready var timer = $Timer
@onready var sand_sfx = $AudioStreamPlayer2D as AudioStreamPlayer2D

func _ready():
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	area.connect("body_exited", Callable(self, "_on_body_exited"))
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	sand_sfx.finished.connect(_on_sfx_finished)

# Remove this variable since we don't need to track if the player stays
# var player_on_block := false

func _on_body_entered(body):
	if body.is_in_group("player"):  # Ensure your player node is in "player" group
		timer.start()  # Start the timer immediately when player steps on the block

func _on_body_exited(body):
	if body.is_in_group("player"):
		# No need to stop the timer; it will run for 3 seconds regardless
		pass

func _on_timer_timeout():
	sand_sfx.play()
	visible = false

func _on_sfx_finished() -> void:
	queue_free()
