extends Area2D

@onready var cat_sfx = $AudioStreamPlayer2D as AudioStreamPlayer2D

func _ready() -> void:
	cat_sfx.finished.connect(_on_sfx_finished)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("pickup_collectible"):
		body.pickup_collectible()
		cat_sfx.play()
		$CollisionShape2D.disabled = true  # Optional: prevent retrigger
		visible = false  # Hide while sound plays

func _on_sfx_finished() -> void:
	queue_free()
