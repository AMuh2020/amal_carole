extends CharacterBody2D

## Constants
const CROUCH_SPEED_MULTIPLIER = 0.5
const GRAVITY = 980 # Define a gravity constant for consistency

@onready var attack_sfx = $AudioStreamPlayer2D as AudioStreamPlayer2D

## Node References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle_shape: CollisionShape2D = $CollisionShape2DIdle
@onready var crouch_shape: CollisionShape2D = $CollisionShape2DCrouch
@onready var attack_timer: Timer = $Timer # Renamed for clarity
@onready var attack_collision_shape: CollisionShape2D = $AnimatedSprite2D/PlayerAttackArea/CollisionShape2D
@onready var health_bar: ProgressBar = $ProgressBar
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var item_count_label: Label = $"../UI_Container/ItemCountLabel"
@onready var next_level_portal: Area2D = $"../NextLevelPortal"
@onready var crouch_bug_raycast: RayCast2D = $CrouchBugRaycast
@onready var crouch_bug_raycast_2: RayCast2D = $CrouchBugRaycast2
@onready var crouch_bug_raycast_3: RayCast2D = $CrouchBugRaycast3

## Player Properties
@export var JUMP_VELOCITY = -330
@export var SPEED = 200.0
@export var can_crouch = true
var current_health: int = 100
@export var max_health: int = 100
var current_animation: String = ""
var previous_crouch_state: bool = false # Still useful for collision shape switching
var collectible_count = 0
var collectibles_needed: int
var attack_damage: int = 20
var max_stamina:int = 100
var stamina:int = 100
var attack_stamina_drain: int = 20
## Player States Enum

enum PlayerState {
	IDLE,
	WALKING,
	CROUCHING,
	ATTACKING,
	JUMPING,
	FALLING,
	DEATH
}

var current_state: PlayerState = PlayerState.IDLE

func _ready() -> void:
	# Set initial state
	transition_to_state(PlayerState.IDLE)
	current_health = max_health
	if next_level_portal:
		collectibles_needed = next_level_portal.collectibles_needed
	if item_count_label:
		item_count_label.text = "Item count: " + str(collectible_count) + "/" + str(collectibles_needed)

func _physics_process(delta: float) -> void:
	# Apply gravity if not on floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle state-specific physics logic
	match current_state:
		PlayerState.IDLE:
			handle_idle_physics(delta)
		PlayerState.WALKING:
			handle_walking_physics(delta)
		PlayerState.CROUCHING:
			if can_crouch:
				handle_crouching_physics(delta)
		PlayerState.ATTACKING:
			handle_attacking_physics(delta)
		PlayerState.JUMPING:
			handle_jumping_physics(delta)
		PlayerState.FALLING:
			handle_falling_physics(delta)
		PlayerState.DEATH:
			handle_death_physics(delta) # Death state might not need delta updates, but good to have a placeholder
	
	if can_crouch:
		# Handle general collision shape switching based on crouching
		var is_currently_crouching = Input.is_action_pressed("crouch") and is_on_floor()
		if is_currently_crouching != previous_crouch_state and not crouch_bug_ray_check():
			idle_shape.disabled = is_currently_crouching
			crouch_shape.disabled = not is_currently_crouching
			previous_crouch_state = is_currently_crouching

	move_and_slide()

func crouch_bug_ray_check() -> bool:
	if crouch_bug_raycast.is_colliding() or crouch_bug_raycast_2.is_colliding() or crouch_bug_raycast_3.is_colliding():
		print("remain crouching")
		return true
	return false

func _input(event: InputEvent) -> void:
	# Handle state-specific input
	match current_state:
		PlayerState.IDLE:
			handle_idle_input(event)
		PlayerState.WALKING:
			handle_walking_input(event)
		PlayerState.CROUCHING:
				handle_crouching_input(event)
		# ATTACKING, JUMPING, FALLING, DEATH typically don't allow new actions via input
		# but you can add functions if they do (e.g., jump cancelling an attack)
		PlayerState.ATTACKING:
			handle_attacking_input(event)
		PlayerState.JUMPING:
			handle_jumping_input(event)
		PlayerState.FALLING:
			handle_falling_input(event)

func transition_to_state(new_state: PlayerState) -> void:
	if current_state == new_state:
		return # No need to transition if already in this state
	
	# Exit logic for the old state (if any)
	match current_state:
		PlayerState.ATTACKING:
			print("PLAYER: OLD STATE ATTACK EXIITING")
			_exit_attacking_state()
		PlayerState.DEATH:
			_exit_death_state()
		# Add any other exit logic here if needed
	print("PLAYER: old state: ", PlayerState.keys()[current_state])
	current_state = new_state
	print("PLAYER: Transitioned to state: ", PlayerState.keys()[current_state]) # For debugging

	# Enter logic for the new state
	match current_state:
		PlayerState.IDLE:
			_enter_idle_state()
		PlayerState.WALKING:
			_enter_walking_state()
		PlayerState.CROUCHING:
				_enter_crouching_state()
		PlayerState.ATTACKING:
			_enter_attacking_state()
		PlayerState.JUMPING:
			_enter_jumping_state()
		PlayerState.FALLING:
			_enter_falling_state()
		PlayerState.DEATH:
			_enter_death_state()

## Animation Helper
func _play_animation(anim_name: String) -> void:
	if current_animation != anim_name:
		animated_sprite.play(anim_name)
		current_animation = anim_name

## Damage Handling
func take_damage(damage: int) -> void:
	if current_health > 0:
		current_health -= damage
		print("Player taken ", str(damage))
	if current_health <= 0:
		print("Player died!")
		transition_to_state(PlayerState.DEATH)
	health_bar.update_health(current_health)
	print("Player health: ", str(current_health))

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health) # Heal, but don't exceed max_health
	print("PLAYER: healed for ", amount, " health. Current health: ", current_health)
	health_bar.update_health(current_health)
	# Add any visual effects (particles), sound effects, or UI updates here.
	if current_health >= max_health:
		print("Player is at full health!")

func pickup_collectible() -> void:
	print("picked it up")
	collectible_count += 1
	item_count_label.text = "Item count: " + str(collectible_count) + "/" + str(collectibles_needed)
	#if collectible_count >= level.collectible:
		#something something

## Signal Connections
func _on_animated_sprite_2d_animation_finished() -> void:
	# Handle animation finished events relevant to the current state
	match current_state:
		PlayerState.ATTACKING:
			
			if animated_sprite.animation == "attack":
				print("PLAYER: transitioned back to idle")
				transition_to_state(PlayerState.IDLE) # Go back to idle after attack anim

func _on_attack_timer_timeout() -> void:
	# This timer is specifically for resetting the attack state (failsafe)
	if current_state == PlayerState.ATTACKING:
		_exit_attacking_state()
		# Consider if you want to transition out of attacking immediately on timeout
		# or wait for animation finished. If this is a failsafe, it might just reset the hitbox.
		# For simplicity here, we'll just ensure hitbox is disabled.
		print("Attack failsafe timer triggered.")
		if current_state == PlayerState.ATTACKING: # Only transition if still attacking
			transition_to_state(PlayerState.IDLE)


func _on_attack_area_area_entered(area: Area2D) -> void:
	print("PLAYER: AREA IN RANGE ", area)
	if area.is_in_group("enemy") and current_state == PlayerState.ATTACKING:
		var enemy = area.get_parent()
		if enemy and enemy.has_method("take_damage"): # Defensive check
			enemy.take_damage(attack_damage)

## State-Specific Functions (Cont.)

func _enter_idle_state() -> void:
	_play_animation("idle")
	velocity.x = 0

func handle_idle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		transition_to_state(PlayerState.JUMPING)
	elif event.is_action_pressed("attack"):
		if stamina-attack_stamina_drain > 0:
			stamina -= attack_stamina_drain
			stamina_bar.update_stamina(stamina)
			transition_to_state(PlayerState.ATTACKING)

func handle_idle_physics(_delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		transition_to_state(PlayerState.WALKING)
	elif Input.is_action_pressed("crouch"):
		if can_crouch:
			transition_to_state(PlayerState.CROUCHING)

	# If falling due to walking off a ledge while idle (no input)
	if not is_on_floor() and velocity.y > 0:
		transition_to_state(PlayerState.FALLING)


func _enter_walking_state() -> void:
	_play_animation("run")

func handle_walking_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		transition_to_state(PlayerState.JUMPING)
	elif event.is_action_pressed("attack"):
		transition_to_state(PlayerState.ATTACKING)

func handle_walking_physics(_delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")

	if direction == 0:
		transition_to_state(PlayerState.IDLE)
	elif Input.is_action_pressed("crouch"):
		if can_crouch:
			transition_to_state(PlayerState.CROUCHING)
	else:
		velocity.x = direction * SPEED
		if direction > 0:
			animated_sprite.scale.x = 1
		elif direction < 0:
			animated_sprite.scale.x = -1

	if not is_on_floor() and velocity.y > 0:
		transition_to_state(PlayerState.FALLING)
		

func _enter_crouching_state() -> void:
	_play_animation("crouch")
	velocity.x = 0 # Stop horizontal movement when entering crouch

func handle_crouching_input(_event: InputEvent) -> void:
	# No jump or attack while crouching in this implementation
	pass

func handle_crouching_physics(_delta: float) -> void:
	if (not Input.is_action_pressed("crouch") or not is_on_floor()) and not crouch_bug_ray_check():
		# If you release crouch or walk off a ledge
		if Input.get_axis("move_left", "move_right") != 0:
			transition_to_state(PlayerState.WALKING)
		else:
			transition_to_state(PlayerState.IDLE)
		return

	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		_play_animation("crouch_walk")
		velocity.x = direction * SPEED * CROUCH_SPEED_MULTIPLIER
		if direction > 0:
			animated_sprite.scale.x = 1
		elif direction < 0:
			animated_sprite.scale.x = -1
	else:
		_play_animation("crouch")
		velocity.x = 0

func _enter_attacking_state() -> void:
	print("PLAYER: ENTERING ATTACK")
	_play_animation("attack")
	if attack_sfx:
		attack_sfx.play()
	print("PLAYER: ATTACK ANIMATION COMPLETE")
	attack_collision_shape.disabled = false
	print("PLAYER: COLLISION SHAPE DISABLED")
	attack_timer.start(0.5) # Assuming your attack animation lasts 0.5 seconds
	print("PLAYER: ATTACK TIMER STARTED")
	velocity.x = 0 # Stop movement during attack

func _exit_attacking_state() -> void:
	print("PLAYER: EXITING ATTACK")
	attack_collision_shape.disabled = true
	if attack_timer.time_left > 0: # Stop timer if it's still running
		attack_timer.stop()

func handle_attacking_input(_event: InputEvent) -> void:
	pass # Cannot initiate new actions while attacking

func handle_attacking_physics(_delta: float) -> void:
	# No horizontal movement during attack, just gravity
	velocity.x = 0

func _enter_jumping_state() -> void:
	velocity.y = JUMP_VELOCITY
	print("PLAYER: enter jumping")
	_play_animation("jump")

func handle_jumping_input(_event: InputEvent) -> void:
	pass # Cannot jump again or attack in mid-jump here

func handle_jumping_physics(_delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED

	if velocity.y >= 0 and not is_on_floor(): # Transition to falling when upward velocity stops
		transition_to_state(PlayerState.FALLING)
	elif is_on_floor(): # Landed
		if direction != 0:
			transition_to_state(PlayerState.WALKING)
		else:
			transition_to_state(PlayerState.IDLE)

	if direction > 0:
		animated_sprite.scale.x = 1
	elif direction < 0:
		animated_sprite.scale.x = -1

func _enter_falling_state() -> void:
	_play_animation("jump_falling")

func handle_falling_input(_event: InputEvent) -> void:
	pass # No input actions while falling (e.g., double jump or attack in air)

func handle_falling_physics(_delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED

	if is_on_floor(): # Landed
		if direction != 0:
			transition_to_state(PlayerState.WALKING)
		else:
			transition_to_state(PlayerState.IDLE)

	if direction > 0:
		animated_sprite.scale.x = 1
	elif direction < 0:
		animated_sprite.scale.x = -1

func _enter_death_state() -> void:
	_play_animation("death")
	set_collision_mask_value(3, false) # Disable collision with enemies/obstacles
	velocity = Vector2.ZERO # Stop all movement

	# Wait for animation to finish then reload scene
	await animated_sprite.animation_finished
	await get_tree().create_timer(1.0).timeout # A small delay
	TransitionScene.transition()

	# Wait for transition to finish (adjust timing if needed)
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

func _exit_death_state() -> void:
	# This might be called if the scene reloads, or if you had a respawn mechanic
	pass

func handle_death_input(_event: InputEvent) -> void:
	pass # Ignore all input when dead

func handle_death_physics(_delta: float) -> void:
	pass # Do nothing when dead


func _on_stamina_recover_timeout() -> void:
	#print("recovering check")
	if stamina < max_stamina:
		if stamina + 5 > max_stamina:
			stamina = max_stamina
			
		else:
			stamina += 5
			print("Updating stamina to", stamina)
		stamina_bar.update_stamina(stamina)
