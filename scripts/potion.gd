extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	
func _on_interact():
	print("drinking potions")
	#get player to drink potion
	var player = get_tree().get_first_node_in_group("player")
	player.heal(10)
	queue_free()
