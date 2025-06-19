class_name HotkeyRebindButton
extends Control

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button

@export var action_name : String = "move_left"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_unhandled_key_input(false)
	set_action_name()

func set_action_name() -> void:
	label.text = "unassigned"
	match action_name:
		"move_left":
			label.text = "Move Left"
		"move_right":
			label.text = "Move right"
		"jump":
			label.text = "Jump"
		"attack":
			label.text = "Attack"
		"interact":
			label.text = "Interact"
		"crouch":
			label.text = "Crouch"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
