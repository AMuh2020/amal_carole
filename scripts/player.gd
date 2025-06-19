extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -330.0
const CROUCH_SPEED_MULTIPLIER = 0.5

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle_shape: CollisionShape2D = $CollisionShape2DIdle
@onready var crouch_shape: CollisionShape2D = $CollisionShape2DCrouch
@onready var timer: Timer = $Timer

var is_attacking: bool = false
var is_crouching: bool = false
var current_animation: String = ""
var previous_crouch_state: bool = false

var health: int = 3

func _play_animation(anim_name: String) -> void:
	if current_animation != anim_name:
		#print("Playing animation: ", anim_name)
		animated_sprite.play(anim_name)
		current_animation = anim_name
		

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.x = 0
	#Global.skeletonDamageZone = $AnimatedSprite2D/SkeletonDamage
	
	is_crouching = Input.is_action_pressed("crouch") and is_on_floor()

	# Switch active collision shape only if crouch state changed
	if is_crouching != previous_crouch_state:
		idle_shape.disabled = is_crouching
		crouch_shape.disabled = not is_crouching
		previous_crouch_state = is_crouching

	if Input.is_action_just_pressed("attack") and not is_attacking:
		#print("attack pressed")
		is_attacking = true
		_play_animation("attack")
		$AnimatedSprite2D/AttackArea/CollisionShape2D.disabled = false
		timer.start(0.5)
		
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching and not is_attacking:
		velocity.y = JUMP_VELOCITY
		_play_animation("jump")

	var direction := Input.get_axis("move_left", "move_right")

	if direction > 0:
		#animated_sprite.flip_h = false
		animated_sprite.scale.x = 1
	elif direction < 0:
		#animated_sprite.flip_h = true
		animated_sprite.scale.x = -1

	if is_attacking:
		#print('still attacking')
		velocity.x = 0
	else:
		if is_crouching:
			if direction == 0:
				_play_animation("crouch")
				velocity.x = 0
			else:
				_play_animation("crouch_walk")
				velocity.x = direction * SPEED * CROUCH_SPEED_MULTIPLIER
		else:
			if is_on_floor():
				if direction == 0:
					_play_animation("idle")
				else:
					_play_animation("run")
			else:
				if velocity.y < 0:
					_play_animation("jump")
				else:
					_play_animation("jump_falling")

			if direction != 0:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	check_hitbox()
	move_and_slide()

func check_hitbox():
	var hitbox_areas = $PlayerHitbox.get_overlapping_areas()
	var damage: int
	#print(str(hitbox_areas))
	if hitbox_areas:
		var hitbox = hitbox_areas.front()
		#print(str(hitbox))
		if hitbox.get_parent().get_parent() is SkeltonEnemy:
			#print("Hit by skeleton")
			#take_damage(1)
			pass

func take_damage(damage):
	if health > 0:
		health -= damage
	print("player health", str(health))

func _on_animated_sprite_2d_animation_finished() -> void:
	#print("animation finished: ", animated_sprite.animation)
	if animated_sprite.animation == "attack":
		#print("attack animation cleared")
		$AnimatedSprite2D/AttackArea/CollisionShape2D.disabled = true
		is_attacking = false


func _on_timer_timeout() -> void:
	if is_attacking:
		print("Failsafe reset triggered")
		is_attacking = false
		$AnimatedSprite2D/AttackArea/CollisionShape2D.disabled = true # Replace with function body.


func _on_attack_area_area_entered(area: Area2D) -> void:
	print(str(area))
	if area.is_in_group("enemy") and is_attacking:
		var enemy = area.get_parent()
		print(str(enemy))
