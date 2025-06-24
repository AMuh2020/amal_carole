extends Control

@onready var mediaval_music = $AudioStreamPlayer2D
@onready var skip_button: Button = $CanvasLayer/SkipButton

var scene_timer: Timer

func _ready() -> void:
	mediaval_music.play()
	skip_button.pressed.connect(_on_skip_pressed)
	start_prologue_timer()
	
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
	mediaval_music.stop()
	TransitionScene.transition()

	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/levels/prologue_2.tscn")
