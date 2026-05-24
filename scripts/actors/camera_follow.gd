extends Camera2D

@export var target_path: NodePath

func _process(_delta: float) -> void:
	if target_path.is_empty():
		return
	var target := get_node(target_path)
	global_position = target.global_position.round()
	
