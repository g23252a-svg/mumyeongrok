class_name NPC
extends StaticBody2D

@export var npc_id: String = "kim_makdong"
@export var display_name: String = "김막동"
@export var description: String = "짚신을 만들던 이웃집 노인."
@export var dialogue_lines: Array[String] = [
	"오늘은 일찍 들어왔구먼.",
	"산 너머 바다가 좀 이상하다는 말이 있네.",
	"검은 점들이 떠 있다던데… 배인지, 새떼인지 모르겠구먼."
]

@export var npc_color: Color = Color(0.55, 0.43, 0.28)

@onready var sprite: ColorRect = get_node_or_null("Sprite") as ColorRect
@onready var name_label: Label = get_node_or_null("NameLabel") as Label
@onready var interaction_hint: Label = get_node_or_null("InteractionHint") as Label
@onready var interact_area: Area2D = $InteractArea

var player_in_range: bool = false
var has_talked: bool = false
var e_was_down: bool = false
var is_talking: bool = false


func _ready() -> void:
	add_to_group("npc")

	if sprite != null:
		sprite.color = npc_color

	if name_label != null:
		name_label.text = display_name
		name_label.visible = true

	if interaction_hint != null:
		interaction_hint.text = "[E] 대화"
		interaction_hint.visible = false

	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)

	print("[NPC READY] ", display_name)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true

		if interaction_hint != null and not is_talking:
			interaction_hint.visible = true

		print("[NPC] ", display_name, " 근처에 Player 진입")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

		if interaction_hint != null:
			interaction_hint.visible = false

		print("[NPC] ", display_name, " 근처에서 Player 이탈")


func _process(_delta: float) -> void:
	if is_talking:
		return

	var interact_pressed := false

	if InputMap.has_action("interact") and Input.is_action_just_pressed("interact"):
		interact_pressed = true

	var e_down := Input.is_key_pressed(KEY_E) or Input.is_physical_key_pressed(KEY_E)

	if e_down and not e_was_down:
		interact_pressed = true

	e_was_down = e_down

	if player_in_range and interact_pressed:
		await talk()


func talk() -> void:
	is_talking = true

	if interaction_hint != null:
		interaction_hint.visible = false

	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue_box == null:
		print("[ERROR] DialogueBox를 찾을 수 없음")
		is_talking = false

		if player_in_range and interaction_hint != null:
			interaction_hint.visible = true

		return

	var player = get_tree().get_first_node_in_group("player")

	if player != null and player.has_method("lock"):
		player.lock()

	await dialogue_box.show_dialogue(display_name, dialogue_lines)

	if player != null and player.has_method("unlock"):
		player.unlock()

	if not has_talked:
		NotebookSystem.add_entry(npc_id, display_name, description)
		has_talked = true

	is_talking = false

	if player_in_range and interaction_hint != null:
		interaction_hint.visible = true
