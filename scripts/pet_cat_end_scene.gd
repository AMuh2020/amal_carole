extends CharacterBody2D

@onready var prologue_timer: Timer = $"../../PrologueTimer"
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
func _ready() -> void:
	pass

func _on_prologue_timer_timeout() -> void:
	for i in range(5):
		anim_sprite.play("ju")
