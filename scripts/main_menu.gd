extends Control

@onready var start_button = $CanvasLayer/VBoxContainer/StartButton as Button
@onready var options_button = $CanvasLayer/VBoxContainer/OptionsButton as Button
@onready var quit_button = $CanvasLayer/VBoxContainer/QuitButton as Button
@onready var vbox_container = $CanvasLayer/VBoxContainer as VBoxContainer
@onready var options_menu = $CanvasLayer/options_menu as OptionsMenu
@onready var background = $Panel as Panel
@onready var canvas_layer: CanvasLayer = $CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	handle_connecting_signals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed():
	MainMenuMusic.stop()
	TransitionScene.transition()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/levels/prologue_1.tscn")


func _on_options_button_pressed() -> void:
	#canvas_layer.visible = false
	vbox_container.visible = false
	background.visible = false
	options_menu.set_process(true)
	options_menu.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func on_exit_options_menu() -> void:
	#canvas_layer.visible = true
	vbox_container.visible = true
	background.visible = true
	options_menu.visible = false

func handle_connecting_signals() -> void:
	start_button.button_down.connect(_on_start_button_pressed)
	options_button.button_down.connect(_on_options_button_pressed)
	quit_button.button_down.connect(_on_quit_button_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
