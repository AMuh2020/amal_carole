extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("you died")
		body.take_damage(200)
		$CollisionShape2D.set_deferred("disabled", true)
		visible = false

		# Set timer to sound duration, then start it
		timer.wait_time = 0
		#timer.start()

func _on_WaitTimer_timeout() -> void:
	pass
	#get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)
