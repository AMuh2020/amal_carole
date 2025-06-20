extends Node
var door_opening: bool = false
func _ready() -> void:
	print("initialized")

func _process(delta: float) -> void:
	#print("door")
	var children = $"enemies".get_children()
	#print(children)
	#print("children", str(no_children))
	if children.is_empty() and not door_opening:
		door_opening = true
		#print("GROUP EMPTY")
		$Door.open_door()
