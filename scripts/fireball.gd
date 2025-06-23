extends CharacterBody2D
var pos: Vector2
var rota: float
var dir: float
var speed: int
var initial_direction: Vector2
var damage: int
var player_node: Node2D = null
@onready var despawn_timer: Timer = $DespawnTimer
@onready var contact_zone: Area2D = $ContactZone
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
var exploded: bool = false

func _ready() -> void:
	global_rotation = initial_direction.angle()
	despawn_timer.start()
	print("FIREBALL: SPAWN")
	
func _physics_process(delta: float) -> void:
	if exploded == false:
		velocity = initial_direction * speed
	else:
		velocity = Vector2.ZERO
	#print("FIREBALL: ",player_node)
	if is_on_floor():
		print("FIREBALL: fireball hit floor")
		explode()
	if player_node:
		if contact_zone.overlaps_area(player_node.get_node("PlayerHitbox")) and not exploded:
			player_node.take_damage(damage)
			print("FIREBALL: playerHit")
			explode()
	move_and_slide()
	#velocity = Vector2(speed, 0).rotated(dir)
	#move_and_slide()

func explode():
	set_collision_layer_value(2, false)
	exploded = true	
	anim_sprite.play("explosion")
	

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

func _on_despawn_timer_timeout() -> void:
	queue_free()
