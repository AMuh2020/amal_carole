extends Node2D

@export var speed: float = 200
@onready var storm_damage_area: Area2D = $StormDamageArea
@onready var damage_tick_timer: Timer = $DamageTickTimer
var player_node: Node2D = null

func _process(delta: float) -> void:
	position.x += speed * delta

func _on_body_entered(body: Node2D) -> void:
	#print("you died")
	if body.is_in_group("player"):
		print("STORM: BODY ENTERED", body)
		player_node = body
		damage_tick_timer.start()


func _on_storm_damage_area_body_exited(body: Node2D) -> void:
	damage_tick_timer.stop()

func _on_damage_tick_timer_timeout() -> void:
	print("STORM: DAMAGE TICK")
	player_node.take_damage(5)
