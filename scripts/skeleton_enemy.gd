extends CharacterBody2D

class_name SkeltonEnemy

var player_path = "../Player"
@onready var player: CharacterBody2D = $"../Player"
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

# References to your Area2D nodes
@onready var skeleton_detection_area: Area2D = $DetectionArea # Assuming you have a DetectionArea child
@onready var skeleton_damage_area: Area2D = $AnimatedSprite2D/AttackDetection # This is the attack hitbox
@onready var skeleton_hitbox: Area2D = $SkeletonHitbox # Assuming this is the enemy's hurtbox


const speed = 60


var health = 10
var health_max = 10
var health_min = 0


var is_pursuing: bool = false
var dead: bool = false
var taking_damage: bool = false
var knockback_force = -100
var attack_delay_seconds = 0.8
var damage_to_deal = 1
var is_idle: bool = false
var is_attacking: bool = false
var is_player_in_detection_area: bool = false
#var is_player_in_range: bool = false
var player_in_area = false
var is_attack_on_cooldown: bool = false

var dir: Vector2 = Vector2.LEFT

var is_roaming:bool = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.x = 0
	
	if not (is_pursuing or taking_damage or is_attacking):
		velocity.x = 0
	Global.skeletonDamageZone = $AnimatedSprite2D/AttackDetection
	
	move(delta)
	
	move_and_slide()
	handle_animation()
	
	if is_player_in_range() and not dead and not is_attacking and not is_attack_on_cooldown:
		start_attack_sequence()

func move(delta):
	if not dead and not is_attacking:
		#print("not dealing")
		if not is_pursuing and not is_idle:
			#roaming behavior
			if ray_cast_right.is_colliding():
				dir = Vector2.LEFT
				
			if ray_cast_left.is_colliding():
				dir = Vector2.RIGHT
			velocity += dir * speed
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback_force
			velocity.x = knockback_dir.x
		elif is_pursuing and not taking_damage and not is_attacking:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x 
			dir.x = abs(velocity.x) / velocity.x
		
		is_roaming = true
	elif dead or is_attacking:
		velocity.x = 0
	# Clamp velocity to prevent excessive speed if needed
	#velocity.x = clamp(velocity.x, -speed, speed)

func handle_animation():
	if dead:
		if is_roaming:
			is_roaming = false
			animated_sprite.play("death")
			await get_tree().create_timer(1.4).timeout
			handle_death()
	elif taking_damage:
		#print("taking damage")
		animated_sprite.play("taking_damage")
		#is_pursuing = false
		await get_tree().create_timer(0.1).timeout
		taking_damage = false
		#is_pursuing = true
	elif is_attacking:
		#print("dealing damage")
		animated_sprite.play("attack")
		#pass
	elif is_idle and not taking_damage and not dead and not is_attacking:
		animated_sprite.play("idle")
	elif not dead and not taking_damage and not is_attacking:
		#print(str(is_dealing_damage))
		animated_sprite.play("walk")
		if dir.x == 1:
			animated_sprite.scale.x = 1
		elif dir.x == -1:
			animated_sprite.scale.x = -1
	
	
func handle_death():
	self.queue_free()

func _on_direction_timer_timeout() -> void:
	#print("directopm timed out")
	$DirectionTimer.wait_time=choose([1.5,2.0,2.5])
	if !is_pursuing:
		is_idle = true
		$IdleTimer.wait_time=choose([2,2.5,3])
		$IdleTimer.start()
		$DirectionTimer.stop()
		dir = choose([Vector2.RIGHT,Vector2.LEFT])
		velocity.x = 0

func _on_idle_timer_timeout() -> void:
	#print("idle time over")
	is_idle = false
	$DirectionTimer.start()

func choose(array):
	array.shuffle()
	return array.front()

# Helper function to check if player is currently within the attack damage area
func is_player_in_range() -> bool:
	var overlapping_areas = skeleton_damage_area.get_overlapping_areas()
	for area in overlapping_areas:
		if area == $"../Player/PlayerHitbox": # Direct comparison to PlayerHitbox Area2D node
			return true
	return false

func _on_skeleton_damage_area_entered(area: Area2D) -> void:
	#print(str(area))
	if area == $"../Player/PlayerHitbox":
		print("player entered attack range")
		#is_player_in_range = true
		#is_attacking = true
		#attack_timer.wait_time = attack_delay_seconds
		#attack_timer.start()

func attack():
	pass

func _on_skeleton_damage_area_exited(area: Area2D) -> void:
	if area == $"../Player/PlayerHitbox":
		print("player left attack range")
		# If player leaves, cancel any pending attack
		if is_attacking:
			is_attacking = false

# This function starts the attack sequence (animation and timer for damage)
func start_attack_sequence() -> void:
	if dead or taking_damage or is_attacking or is_attack_on_cooldown:
		return # Don't start attack if already busy, dead, or on cooldown

	print("Initiating attack sequence...")
	is_attacking = true
	is_attack_on_cooldown = true # Immediately put attack on cooldown
	
	#animated_sprite.play("attack")
	
	attack_timer.wait_time = attack_delay_seconds
	attack_timer.start() # Start the wind-up timer for damage
	
	attack_cooldown_timer.start() # Start the cooldown timer for the next attack
	await animated_sprite.animation_finished
	is_attacking = false
	
func _on_attack_timer_timeout() -> void:
	print("Attack timer ended. Checking for hit.")
	# Only deal damage if the player is *still* in the attack area
	if is_player_in_range():
		# IMPORTANT: Get a reference to the player's hitbox Area2D, not the player CharacterBody2D directly.
		# Then call take_damage on its parent (the player CharacterBody2D).
		# You need to ensure 'PlayerHitbox' area has 'get_parent()' to get the main player node.
		var player_hitbox_area = skeleton_damage_area.get_overlapping_areas().filter(func(a): return a == $"../Player/PlayerHitbox").front()
		if player_hitbox_area:
			player.take_damage(damage_to_deal) # Call take_damage on the main Player node
	
	#is_attacking = false # Attack animation/wind-up is over

func _on_attack_cooldown_timer_timeout() -> void:
	print("attack cooldown ended")
	is_attack_on_cooldown = false

func _on_skeleton_hitbox_area_entered(area: Area2D) -> void:
	var damage = 1
	#print(str(area))
	if area == $"../Player/AnimatedSprite2D/AttackArea":
		take_damage()

func take_damage():
	health -= 1
	taking_damage = true
	
	# Trigger a visual knockback, if player's attack has a position
	#if player and player.global_position: # Assuming player is valid
		#var knockback_direction = (self.global_position - player.global_position).normalized()
		## Apply a temporary velocity based on knockback
		#velocity.x = knockback_direction.x * abs(knockback_force)
		#velocity.y = -abs(knockback_force) * 0.5 # Add a small vertical lift for knockback
	
	if health <= health_min:
		health = health_min
		dead = true
		print(str(self), "IS DEAD")
	print(str(self), "current health is ", health)


func _on_detection_area_entered(area: Area2D) -> void:
	#$IdleTimer.stop()
	is_idle = false
	if area == $"../Player/PlayerHitbox" and not taking_damage:
		is_pursuing = true

func _on_detection_area_exited(area: Area2D) -> void:
	if area == $"../Player/PlayerHitbox":
		print("no longer pursuing")
		is_pursuing = false
