extends CanvasLayer
@onready var label_2: Label = $ColorRect/Label2
@onready var quit_button = $Button as Button


func _ready() -> void:
	label_2.visible = false
	await get_tree().create_timer(3).timeout
	label_2.visible = true
	handle_connecting_signals()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
func handle_connecting_signals() -> void:
	quit_button.button_down.connect(_on_quit_button_pressed)
