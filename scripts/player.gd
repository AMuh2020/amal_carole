extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0
#var attacking = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# player attack - kinda complex cant get it to work right along with other
	# along with idle, ill watch vid to do this properly was just experimenting here
	#if Input.is_action_just_pressed("attack"):
		##attacking = true
		#$AnimatedSprite2D.animation = "attack"
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.animation = "jump"
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		#print(direction)
		velocity.x = direction * SPEED
		if velocity.y == 0:
			$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.flip_h = direction < 0
	else:
		#print(velocity.y)
		if velocity.y == 0:
			$AnimatedSprite2D.animation = "idle"
		elif velocity.y > 0:
			$AnimatedSprite2D.animation = "jump_falling"
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
