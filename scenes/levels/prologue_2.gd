extends Control

@onready var samurai_music = $AudioStreamPlayer2D as AudioStreamPlayer2D
@onready var skip_button: Button = $CanvasLayer/SkipButton

func _ready() -> void:
	# Start the 36-second delay on scene load
	start_prologue_timer()
	skip_button.pressed.connect(_on_skip_pressed)
	samurai_music.play

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_cutscene"):
		skip_button.disabled = true
		_transition_to_next_scene()

func start_prologue_timer() -> void:
	await get_tree().create_timer(37.5).timeout

	_transition_to_next_scene()

func _on_skip_pressed() -> void:
	_transition_to_next_scene()

func _transition_to_next_scene() -> void:
	# Prevent multiple calls
	skip_button.disabled = true
	
	# Trigger transition
	TransitionScene.transition()
	samurai_music.stop()

	# Wait for transition to finish (adjust timing if needed)
	await get_tree().create_timer(0.5).timeout

	# Change to the next scene
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
