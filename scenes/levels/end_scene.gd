extends Panel

@onready var path2d = $Path2D as Path2D
@onready var path_follow = $Path2D/PathFollow2D as PathFollow2D

@onready var path2d2 = $Path2D2 as Path2D
@onready var path_follow2 = $Path2D2/PathFollow2D2 as PathFollow2D

const SPEED1 = 90.0
const SPEED2 = 90.0

func _ready():
	print("My node path: ", get_path())
	print("Trying to find PathFollow2D2: ", get_node_or_null("Player1Path"))
	print("Trying to find PathFollow2D2: ", get_node_or_null("Player1Path/PathFollow2D"))
	print("Trying to find PathFollow2D2: ", get_node_or_null("Player2Path"))
	print("Trying to find PathFollow2D2: ", get_node_or_null("Player2Path/PathFollow2D2"))

func _process(delta: float) -> void:
	path_follow.progress += SPEED1 * delta
	if path_follow.progress > path2d.curve.get_baked_length():
		path_follow.progress = 0

	# Move player 2
	path_follow2.progress += SPEED2 * delta
	if path_follow2.progress > path2d2.curve.get_baked_length():
		path_follow2.progress = 0
