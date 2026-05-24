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

@onready var interact_area: Area2D = $InteractArea

var player_in_range: bool = false
var has_talked: bool = false
var e_was_down: bool = false


func _ready() -> void:
	add_to_group("npc")
	interact_area.body_entered.connect(_on_body_entered)
	interact_area.body_exited.connect(_on_body_exited)
	print("[NPC READY] ", display_name)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		print("[NPC] ", display_name, " 근처에 Player 진입")


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		print("[NPC] ", display_name, " 근처에서 Player 이탈")


func _process(_delta: float) -> void:
	var interact_pressed := false

	if InputMap.has_action("interact") and Input.is_action_just_pressed("interact"):
		interact_pressed = true

	var e_down := Input.is_key_pressed(KEY_E) or Input.is_physical_key_pressed(KEY_E)
	if e_down and not e_was_down:
		interact_pressed = true
	e_was_down = e_down

	if player_in_range and interact_pressed:
		talk()


func talk() -> void:
	print("===== 대화 시작 =====")
	print(display_name, ":")
	for line in dialogue_lines:
		print("  ", line)
	print("===================")

	if not has_talked:
		NotebookSystem.add_entry(npc_id, display_name, description)
		has_talked = true
