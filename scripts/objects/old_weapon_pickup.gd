extends Area2D

@export var weapon_name: String = "낡은 낫"
@export var pickup_lines: Array[String] = [
	"낡은 낫 하나가 길가에 떨어져 있었다.",
	"농기구라기엔 날이 너무 차갑게 빛났다.",
	"나는 그것을 두 손으로 움켜쥐었다.",
	"[튜토리얼] 마우스 왼쪽 클릭: 낫 휘두르기"
]

@onready var interaction_hint: Label = get_node_or_null("InteractionHint") as Label

var player_in_range: bool = false
var e_was_down: bool = false
var is_picking_up: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if interaction_hint != null:
		interaction_hint.text = "[E] " + weapon_name + " 줍기"
		interaction_hint.visible = false

	print("[OldWeaponPickup READY] ", weapon_name)


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

	if is_picking_up:
		return

	if not QuestSystem.is_arrived_outskirts():
		return

	if not QuestSystem.is_all_outskirts_clues_inspected():
		return

	if QuestSystem.is_old_weapon_acquired():
		return

	var interact_pressed := false

	if InputMap.has_action("interact") and Input.is_action_just_pressed("interact"):
		interact_pressed = true

	var e_down := Input.is_key_pressed(KEY_E) or Input.is_physical_key_pressed(KEY_E)

	if e_down and not e_was_down:
		interact_pressed = true

	e_was_down = e_down

	if interact_pressed:
		await _pickup_weapon()


func _update_hint() -> void:
	if interaction_hint == null:
		return

	if (
		QuestSystem.is_arrived_outskirts()
		and QuestSystem.is_all_outskirts_clues_inspected()
		and not QuestSystem.is_old_weapon_acquired()
	):
		interaction_hint.text = "[E] " + weapon_name + " 줍기"
		interaction_hint.visible = true
	else:
		interaction_hint.visible = false


func _pickup_weapon() -> void:
	if QuestSystem.is_old_weapon_acquired():
		return

	is_picking_up = true

	if interaction_hint != null:
		interaction_hint.visible = false

	var player = get_tree().get_first_node_in_group("player")

	if player != null and player.has_method("lock"):
		player.lock()

	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue_box != null:
		await dialogue_box.show_dialogue(weapon_name, pickup_lines)
	else:
		print("[OldWeaponPickup ERROR] DialogueBox를 찾을 수 없음")

	QuestSystem.mark_old_weapon_acquired()

	if player != null and player.has_method("equip_old_weapon"):
		player.equip_old_weapon()
	else:
		print("[OldWeaponPickup WARNING] Player에 equip_old_weapon() 함수가 없음")

	if player != null and player.has_method("unlock"):
		player.unlock()

	is_picking_up = false

	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	print("[OldWeaponPickup] 무기 획득 완료")
