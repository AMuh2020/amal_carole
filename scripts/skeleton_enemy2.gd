# enemy.gd
# This script controls the behavior of an enemy CharacterBody2D.

extends CharacterBody2D

# --- Exported Variables ---
@export var speed: float = 50.0 # Movement speed of the enemy.
@export var gravity: float = 980.0 # Gravity applied to the enemy.
@export var walk_times: Array[float] = [2.0, 3.0, 4.0] # Possible durations for walking state.
@export var idle_times: Array[float] = [1.0, 1.5, 2.0] # Possible durations for idle state.
@export var max_health: int = 50 # Maximum health of the enemy.
@export var attack_damage: int = 20 # Damage dealt by the enemy's attack.
@export var attack_cooldown: float = 0.5 # Time between attacks.

# --- Node References (Set in _ready) ---
@onready var detection_area: Area2D = $Detection # Area2D to detect the player.
@onready var walk_duration_timer: Timer = $WalkDurationTimer # Timer for how long the enemy walks.
@onready var idle_duration_timer: Timer = $IdleDurationTimer # Timer for how long the enemy stays idle.
@onready var ray_cast_right: RayCast2D = $RayCastRight # RayCast to check for ground/walls on the right.
@onready var ray_cast_left: RayCast2D = $RayCastLeft # RayCast to check for ground/walls on the left.
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D # Reference to the enemy's sprite for flipping.
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer # Timer to control attack frequency.
@onready var attack_detection_area: Area2D = $AnimatedSprite2D/AttackDetection # Area2D for detecting attack range.
@onready var attack_damage_timer: Timer = $AttackDamageTimer # Timer for when to apply attack damage
@onready var health_bar: ProgressBar = $ProgressBar

# --- State Management ---
enum State { IDLE, WALKING, CHASING, ATTACKING, TAKING_DAMAGE, DEAD } # Define the possible states for the enemy.
var current_state: State = State.IDLE # The current state of the enemy.
var player_detected: bool = false # True if the player is currently within the detection area.
var direction: int = 1 # 1 for right, -1 for left. Controls movement direction.
var current_health: int = max_health # Current health of the enemy.
var player_node: Node2D = null # Reference to the detected player's root node.
var last_roaming_state: State = State.IDLE # Store the state before taking damage to return to it.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signals from the Detection Area2D to respond to player entry/exit.
	#detection_area.body_entered.connect(_on_Detection_body_entered)
	#detection_area.body_exited.connect(_on_Detection_body_exited)
	print(anim_sprite)
	print(anim_sprite.animation)
	# Connect signals from the timers to trigger state changes.
	#walk_duration_timer.timeout.connect(_on_WalkDurationTimer_timeout)
	#idle_duration_timer.timeout.connect(_on_IdleDurationTimer_timeout)
	# --- MODIFICATION START ---
	# Connect attack detection area signal
	#attack_detection_area.area_entered.connect(_on_AttackDetection_area_entered)
	# Connect AnimatedSprite2D animation finished signal
	#anim_sprite.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)
	# Add attack cooldown timer to the scene tree and connect its signal
	#add_child(attack_cooldown_timer)
	#attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.wait_time = attack_cooldown
	#attack_cooldown_timer.timeout.connect(Callable(self, "_on_AttackCooldownTimer_timeout"))
	# --- MODIFICATION END ---
	
	#add_child(attack_damage_timer)
	#attack_damage_timer.one_shot = true # It should only fire once per attack
	#attack_damage_timer.timeout.connect(Callable(self, "_on_AttackDamageTimer_timeout"))
	# Ensure raycasts are enabled from the start.
	ray_cast_right.enabled = true
	ray_cast_left.enabled = true

	# Initialize the enemy's state. Start in idle to wait for the first movement.
	_change_state(State.IDLE)
	
	current_health = max_health # Set initial health

# Called every physics frame (fixed timestep). Use for movement and physics calculations.
func _physics_process(delta: float) -> void:
	#Do nothing if the enemy is dead.
	if current_state == State.DEAD:
		velocity = Vector2.ZERO # Stop all movement
		return # Exit early, no further processing needed

	# Stop horizontal movement when taking damage or attacking
	if current_state == State.ATTACKING:
		velocity.x = 0
	# Apply gravity to the enemy.
	_apply_gravity(delta)

	# Handle behavior based on the current state.
	match current_state:
		State.IDLE:
			# No horizontal movement when idle.
			velocity.x = 0
			pass # The idle timer will handle transition to walking.
		State.WALKING:
			_roam() # Handle roaming logic (movement, turning).
		State.CHASING:
			_chase_player() # Placeholder for player chasing logic.
		State.ATTACKING:
			# Enemy holds still during attack animation
			pass
		State.TAKING_DAMAGE:
			# Enemy holds still during damage animation
			pass
		State.DEAD:
			# Already handled by early exit, but good to have here for completeness.
			pass
	# Move the enemy based on its calculated velocity.
	move_and_slide()

# --- Public Functions (e.g., called by player's attack) ---
# --- MODIFICATION START ---
func take_damage(amount: int) -> void:
	if current_state == State.DEAD:
		return # Cannot take damage if already dead

	current_health -= amount
	health_bar.update_health(current_health)
	print("Enemy took ", amount, " damage. Current health: ", current_health)

	if current_health <= 0:
		_die()
	else:
		if current_state != State.ATTACKING:
			_change_state(State.TAKING_DAMAGE)
# --- MODIFICATION END ---


# --- State Change Function ---
# Changes the enemy's current state and manages timer activity accordingly.
func _change_state(new_state: State) -> void:
	if current_state == State.DEAD and new_state != State.DEAD:
		return
	current_state = new_state
	# Stop all timers before starting the relevant one for the new state.
	walk_duration_timer.stop()
	idle_duration_timer.stop()

	match current_state:
		State.IDLE:
			# Set a random idle duration and start the idle timer.
			idle_duration_timer.wait_time = _pick_random_duration(idle_times)
			idle_duration_timer.start()
			_play_animation("idle")
			# Ensure the sprite faces the current direction while idle.
			if direction == 1:
				anim_sprite.scale.x = 1
			elif direction == -1:
				anim_sprite.scale.x = -1
			
			#attack_detection_area.scale.x = abs(attack_detection_area.scale.x) * float(direction)
			# --- MODIFICATION START ---
			last_roaming_state = State.IDLE # Update last roaming state
			# --- MODIFICATION END ---
			print("Enemy State: IDLE for ", idle_duration_timer.wait_time, " seconds")
		State.WALKING:
			# Set a random walk duration and start the walk timer.
			walk_duration_timer.wait_time = _pick_random_duration(walk_times)
			walk_duration_timer.start()
			# Randomly pick initial direction if not already determined or if starting fresh.
			if direction == 0: # Check if direction is uninitialized
				direction = [-1, 1].pick_random() # Randomly pick left or right
			_play_animation("walk") # Play the walk animation.
			# Ensure sprite faces the correct direction when starting to walk.
			if direction == 1:
				anim_sprite.scale.x = 1
			elif direction == -1:
				anim_sprite.scale.x = -1
			last_roaming_state = State.WALKING # Update last roaming state
			print("Enemy State: WALKING for ", walk_duration_timer.wait_time, " seconds in direction ", direction)
		State.CHASING:
			# Player is detected, so stop roaming timers.
			# In a real game, you would implement complex chasing logic here.
			
			# When chasing, you'd likely want to play the "walk" or a "run" animation.
			_play_animation("walk") # Assuming "walk" is suitable for chasing for now.
			if attack_cooldown_timer.is_stopped():
				attack_cooldown_timer.start() # Start cooldown, so enemy can attack after duration
			print("Enemy State: CHASING Player!")
		State.ATTACKING:
			# Stop chasing related movement. Play attack animation.
			velocity.x = 0
			_play_animation("attack")
			#attack_damage_timer.wait_time = 0.5 # Set your 'X' seconds here (e.g., 0.5 seconds into the animation)
			#attack_damage_timer.start()
			# Attack cooldown timer starts when the attack animation finishes
			print("Enemy State: ATTACKING!")
		State.TAKING_DAMAGE:
			# Stop all movement. Play damage animation.
			velocity.x = 0
			_play_animation("taking_damage")
			# After animation finishes, it will transition back via _on_AnimatedSprite2D_animation_finished
			print("Enemy State: TAKING_DAMAGE!")
		State.DEAD:
			# Stop all movement. Play death animation.
			velocity = Vector2.ZERO
			set_collision_layer_value(2, false) 
			set_collision_mask_value(2, false) # Example: Stop colliding with environment/player
			detection_area.set_collision_mask(0) # Disable detection area
			attack_detection_area.set_collision_mask(0) # Disable attack detection area
			_play_animation("death")
			# Will be queue_free()'d after animation finishes (or remains for ragdoll)
			print("Enemy State: DEAD!")

# --- Helper Functions ---

# Applies gravity to the enemy's vertical velocity.
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

# Picks a random duration from a given array of floats.
func _pick_random_duration(duration_list: Array[float]) -> float:
	if duration_list.is_empty():
		# Fallback if the list is empty to prevent errors.
		push_warning("Duration list is empty! Using default 1.0 second.")
		return 1.0
	return duration_list.pick_random()

# Helper function to play an animation on the AnimatedSprite2D.
func _play_animation(anim_name: String) -> void:
	if anim_sprite.animation != anim_name:
		anim_sprite.play(anim_name)


# --- Roaming Logic ---

# Handles the enemy's walking behavior, including movement and turning.
func _roam() -> void:
	# Set horizontal velocity based on direction and speed.
	velocity.x = speed * direction

	# Check for obstacles (walls) or ledges using raycasts.
	var current_ray_cast: RayCast2D
	var opposite_ray_cast: RayCast2D

	if direction == 1: # Moving right
		current_ray_cast = ray_cast_right
		opposite_ray_cast = ray_cast_left
	else: # Moving left
		current_ray_cast = ray_cast_left
		opposite_ray_cast = ray_cast_right

	# Force an update of the raycasts to ensure they are checking the current frame.
	current_ray_cast.force_raycast_update()
	opposite_ray_cast.force_raycast_update()

	# If the current direction's raycast is not colliding (meaning a ledge)
	# OR if it's colliding with something that's NOT walkable terrain (like a wall),
	# then turn around.
	# We also check `is_on_wall()` to immediately react to hitting a wall.
	if current_ray_cast.is_colliding():
		# Note: You might want to add a "walkable_terrain" group to your tilemaps/platforms
		# to make the raycast check more robust.
		_turn_around()
		#pass

# Flips the enemy's direction and sprite.
func _turn_around() -> void:
	direction *= -1 # Reverse direction.
	if direction == 1:
		anim_sprite.scale.x = 1
	elif direction == -1:
		anim_sprite.scale.x = -1
	print("Enemy turned around. New direction: ", direction)

# --- Chasing Logic (Placeholder) ---

# This function will contain the logic for the enemy to chase the player.
# You will implement this in a later step based on your game's needs.
func _chase_player() -> void:
	# For now, just stop movement when chasing (as a basic placeholder).
	# You would typically calculate direction towards player here and move.
	#velocity.x = 0
	if not is_instance_valid(player_node): # Check if player reference is still valid
		player_detected = false
		_change_state(State.IDLE) # Revert to roaming if player disappears
		return

	# Determine direction towards player
	var target_direction = sign(player_node.global_position.x - global_position.x)

	if target_direction != 0:
		direction = int(target_direction) # Update enemy's facing direction
		#animated_sprite.flip_h = (direction == -1)
		#attack_detection_area.scale.x = abs(attack_detection_area.scale.x) * float(direction)
		if direction == 1:
				anim_sprite.scale.x = 1
		elif direction == -1:
			anim_sprite.scale.x = -1
		velocity.x = speed * direction
	else:
		velocity.x = 0 # Stop if directly above/below player
	if attack_detection_area.overlaps_area(player_node.get_node("PlayerHitbox")) and attack_cooldown_timer.is_stopped():
		_change_state(State.ATTACKING)
	#pass

func _die() -> void:
	_change_state(State.DEAD)
	# Any other death effects (particles, sound)
	# The _on_AnimatedSprite2D_animation_finished will handle queue_free()

# --- Signal Callbacks ---

func _on_Detection_area_entered(area: Area2D) -> void:
	#print("ENEMY", str(area))
	if area.is_in_group("player"):
		print("from detection entered")
		player_detected = true
		# --- MODIFICATION START ---
		# Get a reference to the player's root node (assuming hitbox is a child)
		player_node = area.owner as Node2D
		# --- MODIFICATION END ---
		_change_state(State.CHASING)

# Called when an Area2D exits the Detection Area2D.
func _on_Detection_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		player_detected = false
		# --- MODIFICATION START ---
		player_node = null # Clear player reference
		# --- MODIFICATION END ---
		if not player_detected: # Only revert if no other player hitbox is still in area
			_change_state(State.IDLE)

# Called when a body enters the Detection Area2D.
func _on_Detection_body_entered(body: Node2D) -> void:
	# Check if the entered body is the player (you might use a group or specific node name).
	if body.name == "Player": # Assuming your player node is named "Player"
		player_detected = true
		_change_state(State.CHASING)

# Called when a body exits the Detection Area2D.
func _on_Detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_detected = false
		# Only revert to roaming if the player is no longer detected.
		# This prevents immediate state changes if another body enters/exits quickly.
		if not player_detected:
			_change_state(State.IDLE) # Revert to idle after player leaves.

func _on_AttackDamageTimer_timeout() -> void:
	# This function is called when the specified X seconds for damage application pass.
	if current_state == State.ATTACKING: # Only apply damage if still in attacking state
		if is_instance_valid(player_node) and attack_detection_area.overlaps_area(player_node.get_node("PlayerHitbox")):
			if player_node.has_method("take_damage"):
				player_node.take_damage(attack_damage)
				print("Enemy attacked player for ", attack_damage, " damage (timed)!")
			else:
				push_warning("Player node does not have a 'take_damage' method!")
	# The state change logic (e.g., back to CHASING/IDLE) will still be handled
	# by _on_AnimatedSprite2D_animation_finished when the *animation* completes.

# Called when the WalkDurationTimer times out.
func _on_WalkDurationTimer_timeout() -> void:
	# If the player is still not detected, transition to idle.
	# If player was detected and now is gone, and we were walking, we go back to idle.
	if not player_detected:
		_change_state(State.IDLE)
	else:
		# If player is detected, we should stay in CHASING state, this timer shouldn't be running.
		# This case suggests an error in state management or the player entered detection
		# while walking timer was still active.
		pass

# Called when the IdleDurationTimer times out.
func _on_IdleDurationTimer_timeout() -> void:
	# If the player is still not detected, transition to walking.
	if not player_detected:
		_change_state(State.WALKING)
	else:
		# If player is detected, we should be in CHASING state, this timer shouldn't be running.
		# This suggests player entered detection while idle timer was active.
		pass

# Called when an Area2D (e.g., player's hitbox) enters the AttackDetection area.
func _on_AttackDetection_area_entered(area: Area2D) -> void:
	# Only try to attack if currently chasing, player is in hitbox, and cooldown is ready.
	if current_state == State.CHASING and area.is_in_group("player") and attack_cooldown_timer.is_stopped():
		_change_state(State.ATTACKING)
	pass

# Called when the AnimatedSprite2D finishes playing an animation.
func _on_AnimatedSprite2D_animation_finished() -> void:
	match current_state:
		State.ATTACKING:
			print("attacking  animation")
			# Damage application is now handled by _on_AttackDamageTimer_timeout()
			# No need to call player.take_damage() here anymore.

			# After attack animation, if player is still detected, go back to chasing.
			# Otherwise, go back to idle/roaming.
			if player_detected:
				_change_state(State.CHASING)
			else:
				_change_state(last_roaming_state) # Or State.IDLE
			attack_cooldown_timer.start() # Start cooldown after attack

			# After attack animation, if player is still detected, go back to chasing.
			# Otherwise, go back to idle/roaming.
			if player_detected:
				_change_state(State.CHASING)
			else:
				_change_state(last_roaming_state) # Or State.IDLE
			attack_cooldown_timer.start() # Start cooldown after attack
		State.TAKING_DAMAGE:
			# After taking damage animation, revert to previous roaming/chasing state.
			if player_detected:
				_change_state(State.CHASING)
			else:
				_change_state(last_roaming_state)
		State.DEAD:
			# After death animation, remove the enemy from the scene.
			queue_free()
			print("Enemy removed from scene.")

# Called when the attack cooldown timer times out.
func _on_AttackCooldownTimer_timeout() -> void:
	# This signal simply means the enemy is ready to attack again.
	# The actual attack trigger happens in _chase_player or _on_AttackDetection_area_entered.
	pass


func _on_animated_sprite_2d_frame_changed() -> void:
	#pass
	#print(anim_sprite)
	anim_sprite = $AnimatedSprite2D
	if anim_sprite.animation == "attack" and current_state == State.ATTACKING:
		if anim_sprite.frame == 7:
			if is_instance_valid(player_node) and attack_detection_area.overlaps_area(player_node.get_node("PlayerHitbox")):
				if player_node.has_method("take_damage"):
					player_node.take_damage(attack_damage)
					print("Enemy attacked player for ", attack_damage, " damage (timed)!")
				else:
					push_warning("Player node does not have a 'take_damage' method!")
			#print("NOTE: 7th frame")
