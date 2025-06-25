extends Area2D

@export var collectibles_needed:int = 3

func _on_body_entered(body: Node2D) -> void:
	print("body entered")
	if body.is_in_group("player"):
		if body.collectible_count >= collectibles_needed:
			var current_scene_file = get_tree().current_scene.scene_file_path
			var next_level_number = current_scene_file.to_int() + 1
			var next_level_path = "res://scenes/levels/level_" + str(next_level_number) + ".tscn"
			TransitionScene.transition()

			# Wait for transition to finish (adjust timing if needed)
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file(next_level_path)
