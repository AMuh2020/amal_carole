extends Area2D

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("pickup_collectible"):
		body.pickup_collectible()
		$CollisionShape2D.set_deferred("disabled", true)  # Optional: prevent retrigger
		visible = false  # Hide while sound plays
		queue_free()
