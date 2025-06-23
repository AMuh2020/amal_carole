class_name PauseMenu

extends Control

@onready var vbox_container = $MarginContainer/VBoxContainer as VBoxContainer
@onready var settings_menu = $SettingsMenu as SettingsMenu
@onready var continue_button = $MarginContainer/VBoxContainer/Continue as Button
@onready var settings_button = $MarginContainer/VBoxContainer/Settings as Button
@onready var quit_button = $MarginContainer/VBoxContainer/Quit as Button



func _ready():
	get_tree().paused = true
	settings_menu.visible = false
	settings_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	handle_connecting_signals()

func _on_settings_button_down() -> void:
	get_tree().paused = true
	vbox_container.visible = false
	settings_menu.set_process(true)
	settings_menu.visible = true

func _on_continue_button_down() -> void:
	get_tree().paused = false
	queue_free()


func _on_quit_button_down() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	
func on_exit_settings_menu() -> void:
	vbox_container.visible = true
	settings_menu.visible = false

func handle_connecting_signals() -> void:
	continue_button.button_down.connect(_on_continue_button_down)
	settings_button.button_down.connect(_on_settings_button_down)
	quit_button.button_down.connect(_on_quit_button_down)
	settings_menu.exit_settings_menu.connect(on_exit_settings_menu)
