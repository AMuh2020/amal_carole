extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.has_method("pickup_collectible"):
		body.pickup_collectible()
		queue_free()
