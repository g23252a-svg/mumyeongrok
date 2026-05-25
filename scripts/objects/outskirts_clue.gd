extends Area2D

@export var clue_id: String = ""
@export var display_name: String = "흔적"
@export var clue_lines: Array[String] = []

@onready var interaction_hint: Label = get_node_or_null("InteractionHint") as Label

var player_in_range: bool = false
var e_was_down: bool = false
var is_checking: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if interaction_hint != null:
		interaction_hint.text = "[E] 조사"
		interaction_hint.visible = false

	print("[OutskirtsClue READY] ", display_name)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		_update_hint()


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

		if interaction_hint != null:
			interaction_hint.visible = false


func _process(_delta: float) -> void:
	if not player_in_range:
		return

	if is_checking:
		return

	if not QuestSystem.is_arrived_outskirts():
		return

	if QuestSystem.is_outskirts_clue_inspected(clue_id):
		return

	var interact_pressed := false

	if InputMap.has_action("interact") and Input.is_action_just_pressed("interact"):
		interact_pressed = true

	var e_down := Input.is_key_pressed(KEY_E) or Input.is_physical_key_pressed(KEY_E)

	if e_down and not e_was_down:
		interact_pressed = true

	e_was_down = e_down

	if interact_pressed:
		await _inspect_clue()


func _update_hint() -> void:
	if interaction_hint == null:
		return

	if QuestSystem.is_arrived_outskirts() and not QuestSystem.is_outskirts_clue_inspected(clue_id):
		interaction_hint.text = "[E] 조사"
		interaction_hint.visible = true
	else:
		interaction_hint.visible = false


func _inspect_clue() -> void:
	if QuestSystem.is_outskirts_clue_inspected(clue_id):
		return

	is_checking = true

	if interaction_hint != null:
		interaction_hint.visible = false

	var player = get_tree().get_first_node_in_group("player")

	if player != null and player.has_method("lock"):
		player.lock()

	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue_box != null:
		var lines_to_show: Array[String] = clue_lines

		if lines_to_show.is_empty():
			lines_to_show = [
				"무언가 이상한 흔적이 남아 있다.",
				"방금 전까지 이곳에 사람이 있었던 것 같다.",
				"나는 말없이 그 흔적을 바라보았다."
			]

		await dialogue_box.show_dialogue(display_name, lines_to_show)

	QuestSystem.mark_outskirts_clue_inspected(clue_id)

	if player != null and player.has_method("unlock"):
		player.unlock()

	is_checking = false

	_update_hint()
