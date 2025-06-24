extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_y_pos := 0.0
var velocity_y := 0.0

func _ready() -> void:
	last_y_pos = global_position.y

func _process(delta: float) -> void:
	var parent = get_parent()
	if parent is PathFollow2D and parent.get_parent() is Path2D:
		var curve = parent.get_parent().curve
		if not curve:
			return

		var progress = parent.progress
		var baked_len = curve.get_baked_length()
		var prev_pos = curve.sample_baked(clamp(progress - 10, 0, baked_len))
		var next_pos = curve.sample_baked(clamp(progress + 10, 0, baked_len))
		var dx = next_pos.x - prev_pos.x

		# Flip based on direction
		animated_sprite.scale.x = 1 if dx >= 0 else -1

		# Vertical animation logic
		velocity_y = (global_position.y - last_y_pos) / delta
		last_y_pos = global_position.y

		if abs(velocity_y) < 10:
			animated_sprite.play("run")
		elif velocity_y < -10:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("jump_falling")
