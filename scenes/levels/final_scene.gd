extends CanvasLayer
@onready var label_2: Label = $ColorRect/Label2

func _ready() -> void:
	label_2.visible = false
	await get_tree().create_timer(3).timeout
	label_2.visible = true
