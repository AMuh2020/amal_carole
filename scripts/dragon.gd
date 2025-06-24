# dragon_boss.gd
# This script controls the behavior of a dragon boss CharacterBody2D.

extends CharacterBody2D

# --- Exported Variables ---
@export var speed: float = 100.0 # Movement speed of the boss. (Increased for boss)
@export var gravity: float = 980.0 # Gravity applied to the boss.
@export var max_health: int = 400 # Maximum health of the boss. (Significantly increased)
@export var melee_damage: int = 20 # Damage dealt by the boss's melee attack.
@export var breath_damage: int = 50 # Damage per tick dealt by the boss's breath attack.
@export var fireball_damage: int = 60
@export var melee_attack_cooldown: float = 2.0 # Time between melee attacks.
@export var breath_attack_cooldown: float = 3.0 # Time between breath attacks.
@export var fireball_cooldown: float = 5.0
# --- Node References (Set in _ready) ---
@onready var detection_area: Area2D = $Detection # Area2D to detect the player.
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D # Reference to the boss's sprite for flipping.
@onready var melee_cooldown_timer: Timer = $MeleeCooldownTimer # Timer to control melee attack frequency.
@onready var breath_cooldown_timer: Timer = $BreathCooldownTImer # Timer to control breath attack frequency.
@onready var breath_damage_timer: Timer = $BreathDamageTimer # Timer for applying breath damage ticks.
@onready var melee_detection_area: Area2D = $AnimatedSprite2D/MeleeAttackArea # Area2D for detecting melee range.
@onready var breath_attack_area: Area2D = $AnimatedSprite2D/BreathAttackArea # Area2D for breath attack damage.
@onready var health_bar: ProgressBar = $ProgressBar
@onready var fireball_spawn_point: Marker2D = $AnimatedSprite2D/FireballSpawnPoint # Add a Marker2D child to your boss for where fireballs originate
@onready var fireball_cooldown_timer: Timer = $FireballCooldownTimer # New timer

# --- State Management ---
enum State { CHASING, MELEE_ATTACKING, BREATH_ATTACKING, FIREBALL_ATTACKING, TAKING_DAMAGE, DEAD } # Define the possible states for the boss.
var current_state: State = State.CHASING # The current state of the boss. Boss starts by chasing.
var player_detected: bool = false # True if the player is currently within the detection area.
var direction: int = 1 # 1 for right, -1 for left. Controls movement direction.
var current_health: int = max_health # Current health of the boss.
var player_node: Node2D = null
var shot_count: int = 0
# firebal stuff
var fireball_scene=preload("res://scenes/players_and_enemies/fireball.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signals
	detection_area.body_entered.connect(_on_Detection_body_entered)
	detection_area.body_exited.connect(_on_Detection_body_exited)
	
	anim_sprite.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)
	
	melee_cooldown_timer.wait_time = melee_attack_cooldown
	melee_cooldown_timer.timeout.connect(_on_MeleeCooldownTimer_timeout)
	
	breath_cooldown_timer.wait_time = breath_attack_cooldown
	breath_cooldown_timer.timeout.connect(_on_BreathCooldownTimer_timeout)
	
	breath_damage_timer.wait_time = 0.5 # Tick damage every 0.5 seconds
	#breath_damage_timer.timeout.connect(_on_BreathDamageTimer_timeout)
	breath_damage_timer.one_shot = false # Not one-shot, it ticks
	anim_sprite.frame_changed.connect(_on_frame_changed)
	# Boss starts in CHASING state, so begin cooldowns immediately
	melee_cooldown_timer.start()
	breath_cooldown_timer.start()

	#_change_state(State.CHASING)
	fireball_cooldown_timer.wait_time = fireball_cooldown
	#fireball_cooldown_timer.timeout.connect(_on_FireballCooldownTimer_timeout)
	fireball_cooldown_timer.start() # Start cooldown
	current_health = max_health # Set initial health

# Called every physics frame (fixed timestep). Use for movement and physics calculations.
func _physics_process(delta: float) -> void:
	# Do nothing if the boss is dead.
	if current_state == State.DEAD:
		velocity = Vector2.ZERO # Stop all movement
		return # Exit early, no further processing needed

	# Apply gravity to the boss.
	_apply_gravity(delta)

	# Handle behavior based on the current state.
	match current_state:
		State.CHASING:
			_chase_player()
		State.MELEE_ATTACKING:
			velocity.x = 0 # Boss holds still during melee attack
		State.BREATH_ATTACKING:
			velocity.x = 0 # Boss holds still during breath attack
		State.TAKING_DAMAGE:
			velocity.x = 0 # Boss holds still during damage animation
		State.DEAD:
			pass # Already handled by early exit

	# Move the boss based on its calculated velocity.
	move_and_slide()

# --- Public Functions (e.g., called by player's attack) ---
func take_damage(amount: int) -> void:
	if current_state == State.DEAD:
		return # Cannot take damage if already dead

	current_health -= amount
	health_bar.update_health(current_health)
	#print("BOSS: took ", amount, " damage. Current health: ", current_health)

	if current_health <= 0:
		_die()
	else:
		# Don't interrupt attacks for taking damage, but change state if not attacking
		if current_state != State.MELEE_ATTACKING and current_state != State.BREATH_ATTACKING:
			_change_state(State.TAKING_DAMAGE)

# --- State Change Function ---
# Changes the boss's current state and manages timer activity accordingly.
func _change_state(new_state: State) -> void:
	if current_state == State.DEAD and new_state != State.DEAD:
		return # Cannot change state from dead unless it's to dead again (redundant)
		
	# Disable breath attack area when changing state, unless new state is BREATH_ATTACKING
	#if current_state == State.BREATH_ATTACKING and new_state != State.BREATH_ATTACKING:
		#breath_attack_area.set_deferred("monitoring", false) # Use deferred for safety
		#breath_damage_timer.stop()
	#print("Boss State: Changed from", State.keys()[current_state], " to ", State.keys()[new_state])
	current_state = new_state
	#print("Boss State: ", State.keys()[current_state])
	

	match current_state:
		State.CHASING:
			_play_animation("run") # Or "walk", depending on your animation names
			#if melee_cooldown_timer.is_stopped():
				#melee_cooldown_timer.start()
			#if breath_cooldown_timer.is_stopped():
				#breath_cooldown_timer.start()
		State.MELEE_ATTACKING:
			velocity.x = 0
			_play_animation("melee_attack")
			# Damage application will be handled by the animation event or AttackDetection signal
			melee_cooldown_timer.start() # Start cooldown after attack
		State.BREATH_ATTACKING:
			velocity.x = 0
			#fire_fireball()
			_play_animation("breath_attack")
			# Activate breath attack area and start damage timer
			#breath_attack_area.set_deferred("monitoring", true)
			breath_cooldown_timer.start() # Start cooldown after initiating breath
		State.FIREBALL_ATTACKING:
			velocity.x = 0
			_play_animation("fireball_attack") # Make sure you have this animation
			fire_fireball()
			#_spawn_fireball() # Call the function to create and launch the fireball
			fireball_cooldown_timer.start() # Start cooldown after firing
		State.TAKING_DAMAGE:
			velocity.x = 0
			_play_animation("hurt")
		State.DEAD:
			velocity = Vector2.ZERO
			#set_collision_layer_value(2, false) # Example: Stop colliding with environment/player
			#set_collision_mask_value(2, false)
			#detection_area.set_collision_mask(0) # Disable detection area
			#melee_detection_area.set_collision_mask(0) # Disable melee attack detection
			#breath_attack_area.set_collision_mask(0) # Disable breath attack
			_play_animation("death")

# --- Helper Functions ---

# Applies gravity to the boss's vertical velocity.
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

# Helper function to play an animation on the AnimatedSprite2D.
func _play_animation(anim_name: String) -> void:
	if anim_sprite.animation != anim_name:
		anim_sprite.play(anim_name)

# --- Chasing Logic ---
func _chase_player() -> void:
	if not is_instance_valid(player_node): # Check if player reference is still valid
		player_detected = false
		return # Boss should not stop chasing unless player is gone (which shouldn't happen in enclosed space)

	# Determine direction towards player
	var target_direction = sign(player_node.global_position.x - global_position.x)

	if target_direction != 0:
		direction = int(target_direction) # Update boss's facing direction
		if direction == 1:
			anim_sprite.scale.x = -1
		elif direction == -1:
			anim_sprite.scale.x = 1
		velocity.x = speed * direction
	else:
		velocity.x = 0 # Stop if directly above/below player

	# Attack decision logic:
	var can_melee = melee_cooldown_timer.is_stopped()
	var can_breath = breath_cooldown_timer.is_stopped()
	var can_fireball = fireball_cooldown_timer.is_stopped()
	var player_in_melee_range = melee_detection_area.overlaps_area(player_node.get_node("PlayerHitbox"))
	var player_in_breath_range = breath_attack_area.overlaps_area(player_node.get_node("PlayerHitbox"))
	#print("BOSS: player ov ", player_node.get_node("PlayerHitbox"))
	#print("BOSS: player in breath reange ", player_in_breath_range, " can breath", can_breath)
	#print("BOSS: can fireball ", can_fireball)
	#print("Boss: player node ", player_node)
	# prio breath attack if player is in range and ready
	if player_in_breath_range and can_breath:
		shot_count = 0
		fireball_cooldown_timer.start()
		_change_state(State.BREATH_ATTACKING)
	elif player_in_melee_range and can_melee:
		shot_count = 0
		fireball_cooldown_timer.start()
		_change_state(State.MELEE_ATTACKING)
	elif can_fireball: # Fireball doesn't necessarily need player to be in a specific range, just cooldown
		_change_state(State.FIREBALL_ATTACKING)
	# If no attack is possible, continue chasing
	else:
		_play_animation("run") # Ensure chase animation is playing

func _die() -> void:
	_change_state(State.DEAD)
	# Any other death effects (particles, sound)

func fire_fireball():
	if not is_instance_valid(player_node) or fireball_scene == null:
		push_warning("Cannot spawn fireball: Player not found or Fireball Scene not set.")
		return
	shot_count += 1
	var fireball_instance = fireball_scene.instantiate() as CharacterBody2D
	
	# Calculate direction from boss spawn point to player
	var direction_to_player = (player_node.global_position - fireball_spawn_point.global_position).normalized()

	# Set initial properties for the fireball
	fireball_instance.global_position = fireball_spawn_point.global_position
	fireball_instance.initial_direction = direction_to_player
	fireball_instance.speed = 200 + 50 * (shot_count-1)
	fireball_instance.damage = fireball_damage # Pass damage to the fireball if it handles it
	fireball_instance.player_node = player_node
	get_parent().add_child(fireball_instance)
	_change_state(State.CHASING)
# --- Signal Callbacks ---

func _on_Detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#print("BOSS: Player entered boss detection area.")
		player_detected = true
		player_node = body
		# Boss starts chasing immediately once player is detected
		_change_state(State.CHASING)

func _on_Detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		#print("BOSS: Player exited boss detection area.")
		player_detected = false
		player_node = null
		# In an enclosed space, the player shouldn't easily exit the main detection.
		# If they do, the boss might just wait for them to re-enter.
		# For a boss fight, you might want a "reset" if the player completely leaves.
		# For now, if player leaves, boss just stops chasing actively.
		velocity.x = 0
		_play_animation("idle") # Or some "waiting" animation

func _on_MeleeCooldownTimer_timeout() -> void:
	# Melee attack is now off cooldown. The _chase_player function will decide when to use it.
	pass

func _on_BreathCooldownTimer_timeout() -> void:
	# Breath attack is now off cooldown. The _chase_player function will decide when to use it.
	pass

func _on_BreathAttackDuration_timeout(timer: Timer) -> void:
	# This is called after the breath attack duration is over
	#print("Breath attack duration finished.")
	#breath_attack_area.set_deferred("monitoring", false)
	breath_damage_timer.stop()
	timer.queue_free() # Clean up the temporary timer
	
	# Transition back to chasing after breath attack finishes
	if player_detected:
		_change_state(State.CHASING)
	else:
		_on_Detection_body_exited(player_node) # Simulate player exiting if not detected

func _on_BreathAttack_Impact():
	#print("BOSS BREATH ATTACKING")
	# This function is called periodically during the breath attack duration
	if current_state == State.BREATH_ATTACKING and is_instance_valid(player_node):
		for area in breath_attack_area.get_overlapping_areas():
			if area.is_in_group("player"): # Assuming player has a "player_hitbox" group
				var player_body = area.owner # Get the root player node
				if player_body.has_method("take_damage"):
					player_body.take_damage(breath_damage)
					#print("Boss hit player with breath for ", breath_damage, " damage!")
				else:
					push_warning("Player node does not have a 'take_damage' method!")

func _on_AnimatedSprite2D_animation_finished() -> void:
	match anim_sprite.animation:
		"melee_attack":
			# After melee attack animation, go back to chasing
			if player_detected:
				_change_state(State.CHASING)
			else:
				_on_Detection_body_exited(player_node) # Simulate player exiting if not detected
		"breath_attack":
			if player_detected:
				_change_state(State.CHASING)
			else:
				_on_Detection_body_exited(player_node)
			pass # Do nothing here, as the temporary timer handles the transition
		"hurt":
			# After taking damage animation, revert to chasing
			if player_detected:
				_change_state(State.CHASING)
			else:
				_on_Detection_body_exited(player_node)
		"death":
			queue_free()
			#print("Boss removed from scene.")

func _on_frame_changed():
	if anim_sprite.animation == "melee_attack" && anim_sprite.frame == 8:
		_on_MeleeAttack_Impact()
	if anim_sprite.animation == "breath_attack" && anim_sprite.frame == 7:
		#print("BOSS: frame 7 reached breath attack")
		_on_BreathAttack_Impact()
	

# Function for melee attack damage application
# This should be called via an AnimationPlayer signal at the point of impact in your "melee_attack" animation
func _on_MeleeAttack_Impact() -> void:
	#print("BOSS MELEE IMPACT")
	if current_state == State.MELEE_ATTACKING and is_instance_valid(player_node):
		if melee_detection_area.overlaps_area(player_node.get_node("PlayerHitbox")):
			if player_node.has_method("take_damage"):
				player_node.take_damage(melee_damage)
				#print("Boss hit player with melee for ", melee_damage, " damage!")
			else:
				push_warning("Player node does not have a 'take_damage' method!")


func _on_fireball_cooldown_timer_timeout() -> void:
	pass # Replace with function body.
