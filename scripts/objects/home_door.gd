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

	print("[HomeDoor READY]")


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		_update_hint()
		print("[HomeDoor] Player 진입")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

		if interaction_hint != null:
			interaction_hint.visible = false

		print("[HomeDoor] Player 이탈")


func _process(_delta: float) -> void:
	if not player_in_range:
		return

	if is_playing_event:
		return

	var interact_pressed := false

	if InputMap.has_action("interact") and Input.is_action_just_pressed("interact"):
		interact_pressed = true

	var e_down := Input.is_key_pressed(KEY_E) or Input.is_physical_key_pressed(KEY_E)

	if e_down and not e_was_down:
		interact_pressed = true

	e_was_down = e_down

	if interact_pressed:
		await _try_start_night()


func _update_hint() -> void:
	if interaction_hint == null:
		return

	if QuestSystem.is_returned_to_yeonhwa():
		interaction_hint.text = "[E] 밤 준비"
	else:
		interaction_hint.text = "아직 돌아갈 수 없다"

	interaction_hint.visible = true


func _try_start_night() -> void:
	if not QuestSystem.is_returned_to_yeonhwa():
		print("[HomeDoor] 아직 연화에게 돌아가지 않음")
		return

	is_playing_event = true

	if interaction_hint != null:
		interaction_hint.visible = false

	var player = get_tree().get_first_node_in_group("player")

	if player != null and player.has_method("lock"):
		player.lock()

	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue_box != null:
		var night_lines: Array[String] = []
		night_lines.append("밤바람이 문틈으로 스며들었다.")
		night_lines.append("멀리서 북인지 천둥인지 모를 소리가 울렸다.")
		night_lines.append("이 밤이 지나면, 같은 아침은 오지 않을 것이다.")

		await dialogue_box.show_dialogue("무명록", night_lines)
		QuestSystem.mark_night_prepared()
	else:
		print("[HomeDoor] DialogueBox 없음")

	if player != null and player.has_method("unlock"):
		player.unlock()

	print("[PROLOGUE] 밤 준비 이벤트 완료")
