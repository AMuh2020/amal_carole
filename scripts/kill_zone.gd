extends Area2D

@onready var timer: Timer = $Timer
@onready var lava_sfx = $AudioStreamPlayer2D as AudioStreamPlayer2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("you died")
		body.take_damage(99)
		lava_sfx.play()
		$CollisionShape2D.disabled = true
		visible = false

		# Set timer to sound duration, then start it
		timer.wait_time = lava_sfx.stream.get_length()
		timer.start()

func _on_WaitTimer_timeout() -> void:
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)
