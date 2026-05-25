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

	print("[OutsideNoiseTrigger READY]")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		_update_hint()
		print("[OutsideNoiseTrigger] Player 진입")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

		if interaction_hint != null:
			interaction_hint.visible = false

		print("[OutsideNoiseTrigger] Player 이탈")


func _process(_delta: float) -> void:
	if not player_in_range:
		return

	if is_playing_event:
		return

	if not QuestSystem.is_dawn_started():
		return

	if QuestSystem.is_outside_noise_checked():
		return

	var interact_pressed := false

	if InputMap.has_action("interact") and Input.is_action_just_pressed("interact"):
		interact_pressed = true

	var e_down := Input.is_key_pressed(KEY_E) or Input.is_physical_key_pressed(KEY_E)

	if e_down and not e_was_down:
		interact_pressed = true

	e_was_down = e_down

	if interact_pressed:
		await _check_outside_noise()


func _update_hint() -> void:
	if interaction_hint == null:
		return

	if QuestSystem.is_dawn_started() and not QuestSystem.is_outside_noise_checked():
		interaction_hint.text = "[E] 밖의 소리 확인"
		interaction_hint.visible = true
	else:
		interaction_hint.visible = false


func _check_outside_noise() -> void:
	if not QuestSystem.is_dawn_started():
		return

	if QuestSystem.is_outside_noise_checked():
		return

	is_playing_event = true

	if interaction_hint != null:
		interaction_hint.visible = false

	var player = get_tree().get_first_node_in_group("player")

	if player != null and player.has_method("lock"):
		player.lock()
		
	AudioManager.play_outside_battle_layer()
	await get_tree().create_timer(0.35).timeout

	AudioManager.play_outside_scream()
	await get_tree().create_timer(1.25).timeout

	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue_box != null:
		var lines: Array[String] = []
		lines.append("처음에는 바람 소리인 줄 알았다.")
		lines.append("그러나 다시 들렸다. 쇠가 부딪히는 소리.")
		lines.append("그리고 누군가의 비명.")

		await dialogue_box.show_dialogue("무명록", lines)

	QuestSystem.mark_outside_noise_checked()
	
	for npc in get_tree().get_nodes_in_group("npc"):
		if npc.has_method("start_dawn_panic"):
			npc.start_dawn_panic()
	
	

	if player != null and player.has_method("unlock"):
		player.unlock()

	is_playing_event = false

	print("[PROLOGUE] 밖의 소리 확인 완료")
