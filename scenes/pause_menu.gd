class_name PauseMenu

extends Control

func _ready():
	get_tree().paused = true

func _on_continue_button_down() -> void:
	get_tree().paused = false
	queue_free()


func _on_settings_button_down() -> void:
	get_tree().paused = false
	pass # Replace with function body.


func _on_quit_button_down() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	
