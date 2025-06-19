extends CharacterBody2D

class_name SkeltonEnemy

@onready var target: CharacterBody2D = $"../Player"
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const speed = 100


var health = 2
var health_max = 2
var health_min = 0

var is_pursuing: bool = false

var dead: bool = false
var taking_damage: bool = false
var damage_to_deal = 1
var is_dealing_damage: bool = false

var dir: Vector2 = Vector2.LEFT

var is_roaming:bool = true

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.x = 0
	if ray_cast_right.is_colliding():
		dir = Vector2.LEFT
		
	if ray_cast_left.is_colliding():
		dir = Vector2.RIGHT
		#animated_sprite.scale.x = 1
	
	move(delta)
	handle_animation()
	move_and_slide()

func move(delta):
	if not dead:
		#print("not dead")
		if not is_pursuing:
			velocity += dir * speed * delta
		is_roaming = true
	elif dead:
		velocity.x = 0

func handle_animation():
	if not dead and not taking_damage and not is_dealing_damage:
		animated_sprite.play("walk")
		if dir.x == 1:
			animated_sprite.scale.x = 1
		elif dir.x == -1:
			animated_sprite.scale.x = -1

func _on_timer_timeout() -> void:
	pass
	#$DirectionTimer.wait_time=choose([1.5,2.0,2.5])
	#if !is_pursuing:
			#dir = choose([Vector2.RIGHT,Vector2.LEFT])
			#velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()
