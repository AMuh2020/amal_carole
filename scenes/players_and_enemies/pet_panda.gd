extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -330.0
const GRAVITY = 980.0

@onready var meow_sfx = $AudioStreamPlayer2D as AudioStreamPlayer2D
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Horizontal input
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED

	# Jumping
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		meow_sfx.play()

	# Animation
	if not is_on_floor():
		sprite.play("jump" if velocity.y < 0 else "jump_falling")
	elif direction != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

	# Flip sprite
	if direction > 0:
		sprite.scale.x = 1
	elif direction < 0:
		sprite.scale.x = -1

	# Move the body
	move_and_slide()
