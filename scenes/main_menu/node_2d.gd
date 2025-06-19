extends Node2D

@onready var path2d: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D

const SPEED = 100.0

func _process(delta: float) -> void:
	path_follow.progress += SPEED * delta

	if path_follow.progress > path2d.curve.get_baked_length():
		path_follow.progress = 0
