class_name SettingsMenu
extends Control

@onready var exit_button = $MarginContainer/VBoxContainer/Exit_Button as Button

signal exit_settings_menu


# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Make sure the button can receive input
	exit_button.focus_mode = Control.FOCUS_ALL
	
	exit_button.button_down.connect(_on_quit_button_pressed)

func _on_quit_button_pressed() -> void:
	exit_settings_menu.emit()
