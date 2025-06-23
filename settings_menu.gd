class_name SettingsMenu
extends Control

@onready var exit_button = $MarginContainer/VBoxContainer/Exit_Button as Button


signal exit_settings_menu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	exit_button.button_down.connect(_on_quit_button_down)
	set_process(false)

func _on_quit_button_down() -> void:
	exit_settings_menu.emit()
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
