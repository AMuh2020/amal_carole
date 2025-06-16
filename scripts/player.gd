extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0
#var attacking = false
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking: bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# player attack - kinda complex cant get it to work right along with other
	# along with idle, ill watch vid to do this properly was just experimenting here
	if Input.is_action_just_pressed("attack"):
		#attacking = true
		animated_sprite.play("attack")
		is_attacking = true
		await animated_sprite.animation_finished
		is_attacking = false
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	# make sure an attack isn't happening
	if not is_attacking:
		# then check for floor (on floor animations happen here), if not on floor its jump animations
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
				pass
			else:
				animated_sprite.play("run")
		else:
			if velocity.y < 0:
				animated_sprite.play("jump")
			elif velocity.y > 0:
				animated_sprite.play("jump_falling")
		
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true
	
	
	if direction:
		#print(direction)
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
