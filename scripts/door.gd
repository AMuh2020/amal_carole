extends StaticBody2D



@onready var door_opening: Timer = $DoorOpening
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	#open_door()
	pass

func open_door():
	anim_sprite.play("door")
	door_opening.start()




func _on_door_opening_timeout() -> void:
	set_collision_layer_value(1, false)
