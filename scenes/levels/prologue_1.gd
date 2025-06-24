extends Control

@onready var mediaval_music = $AudioStreamPlayer2D as AudioStreamPlayer2D

func _ready() -> void:
	# Start the 36-second delay on scene load
	start_prologue_timer()
	mediaval_music.play()

func start_prologue_timer() -> void:
	await get_tree().create_timer(37.5).timeout
	# Trigger transition
	TransitionScene.transition()
	mediaval_music.stop()

	# Wait for transition to finish (adjust timing if needed)
	await get_tree().create_timer(0.5).timeout

	# Change to the next scene
	get_tree().change_scene_to_file("res://scenes/levels/prologue_2.tscn")
