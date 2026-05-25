extends Node2D

@export var debug_skip_to_dawn_on_start: bool = false


func _ready() -> void:
	print("[TestRoom] BGM 시작")
	AudioManager.play_village_evening_bgm()

	if debug_skip_to_dawn_on_start:
		await get_tree().process_frame
		_debug_skip_to_dawn_noise()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return

	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_F9:
				_debug_skip_to_dawn_noise()
				
			if event.keycode == KEY_F10:
				_debug_skip_to_outskirts()
				
			


func _debug_skip_to_dawn_noise() -> void:
	QuestSystem.debug_skip_to_dawn_noise()
	AudioManager.stop_bgm()

	var player := get_tree().get_first_node_in_group("player") as Node2D
	var trigger := get_node_or_null("OutsideNoiseTrigger") as Node2D

	if player != null and trigger != null:
		player.global_position = trigger.global_position + Vector2(0, 35)

	print("[DEBUG] F9 스킵 완료: 밖의 소리 확인 지점으로 이동")
	
func _debug_skip_to_outskirts() -> void:
	QuestSystem.debug_skip_to_outskirts()
	AudioManager.stop_bgm()

	print("[DEBUG] F10 스킵 완료: 마을 어귀 씬으로 이동")

	get_tree().change_scene_to_file("res://scenes/maps/village_outskirts.tscn")
