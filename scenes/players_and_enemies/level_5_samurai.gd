extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Smooth change tracking
var last_y_pos := 0.0
var velocity_y := 0.0

func _ready() -> void:
	last_y_pos = global_position.y

func _process(delta: float) -> void:
	# Flip & animation decision only if child of PathFollow2D
	if get_parent() is PathFollow2D:
		var path_follow = get_parent()
		var path2d = path_follow.get_parent()
		var curve = path2d.curve if path2d is Path2D else null
		if curve == null:
			return

		# Determine direction (X difference between two sample points)
		var progress = path_follow.progress
		var baked_len = curve.get_baked_length()
		var prev_pos = curve.sample_baked(clamp(progress - 10, 0, baked_len))
		var next_pos = curve.sample_baked(clamp(progress + 10, 0, baked_len))
		var dx = next_pos.x - prev_pos.x
		var dy = next_pos.y - prev_pos.y

		# Flip based on direction
		if dx > 0:
			animated_sprite.scale.x = 1
		elif dx < 0:
			animated_sprite.scale.x = -1

		# Calculate vertical velocity (to distinguish jump/fall)
		velocity_y = (global_position.y - last_y_pos) / delta
		last_y_pos = global_position.y

		# Animation logic based on vertical motion
		if abs(velocity_y) < 10:
			if animated_sprite.animation != "run":
				animated_sprite.play("run")
		elif velocity_y < -10:
			if animated_sprite.animation != "jump":
				animated_sprite.play("jump")
		elif velocity_y > 10:
			if animated_sprite.animation != "jump_falling":
				animated_sprite.play("jump_falling")
