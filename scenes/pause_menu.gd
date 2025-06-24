class_name PauseMenu

extends Control

@onready var margin_container = $MarginContainer as MarginContainer
@onready var vbox_container = $MarginContainer/VBoxContainer as VBoxContainer
@onready var continue_button = $MarginContainer/VBoxContainer/Continue as Button
@onready var quit_button = $MarginContainer/VBoxContainer/Quit as Button



func _ready():
	get_tree().paused = true
	handle_connecting_signals()


func _on_continue_button_down() -> void:
	get_tree().paused = false
	queue_free()


func _on_quit_button_down() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	
func on_exit_settings_menu() -> void:
	margin_container.visible = true

func handle_connecting_signals() -> void:
	continue_button.button_down.connect(_on_continue_button_down)
	quit_button.button_down.connect(_on_quit_button_down)
