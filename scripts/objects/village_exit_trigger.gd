extends Area2D

@onready var interaction_hint: Label = get_node_or_null("InteractionHint") as Label

var player_in_range: bool = false
var e_was_down: bool = false
var is_playing_event: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if interaction_hint != null:
		interaction_hint.visible = false

	print("[VillageExitTrigger READY]")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		_update_hint()
		print("[VillageExitTrigger] Player 진입")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

		if interaction_hint != null:
			interaction_hint.visible = false

		print("[VillageExitTrigger] Player 이탈")


func _process(_delta: float) -> void:
	if not player_in_range:
		return

	if is_playing_event:
		return

	if not QuestSystem.is_outside_noise_checked():
		return

	var interact_pressed := false

	if InputMap.has_action("interact") and Input.is_action_just_pressed("interact"):
		interact_pressed = true

	var e_down := Input.is_key_pressed(KEY_E) or Input.is_physical_key_pressed(KEY_E)

	if e_down and not e_was_down:
		interact_pressed = true

	e_was_down = e_down

	if interact_pressed:
		await _leave_village()


func _update_hint() -> void:
	if interaction_hint == null:
		return

	if QuestSystem.is_outside_noise_checked():
		interaction_hint.text = "[E] 마을 어귀로 나가기"
		interaction_hint.visible = true
	else:
		interaction_hint.visible = false


func _leave_village() -> void:
	if not QuestSystem.is_outside_noise_checked():
		return

	is_playing_event = true

	if interaction_hint != null:
		interaction_hint.visible = false

	var player = get_tree().get_first_node_in_group("player")

	if player != null and player.has_method("lock"):
		player.lock()

	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue_box != null:
		var lines: Array[String] = []
		lines.append("마을 어귀로 향하는 발걸음이 무거웠다.")
		lines.append("아직 보이지 않는 곳에서, 조선의 아침이 무너지고 있었다.")
		lines.append("나는 숨을 고르고 북쪽 길로 나아갔다.")

		await dialogue_box.show_dialogue("무명록", lines)

	var scene_transition = get_tree().get_first_node_in_group("scene_transition")

	if scene_transition != null and scene_transition.has_method("play_exit_transition"):
		await scene_transition.play_exit_transition()

	get_tree().change_scene_to_file("res://scenes/maps/village_outskirts.tscn")
