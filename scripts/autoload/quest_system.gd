extends Node

signal quest_updated

var talked_npcs: Dictionary = {}

var required_npcs: Array[String] = [
	"kim_makdong",
	"booni",
	"gwak_seobang",
	"wife"
]

var current_objective: String = "마을 사람들과 대화하기"

var returned_to_yeonhwa: bool = false
var night_prepared: bool = false
var dawn_started: bool = false
var outside_noise_checked: bool = false
var arrived_outskirts: bool = false

var old_weapon_acquired: bool = false
var first_attack_done: bool = false

var inspected_outskirts_clues: Dictionary = {}

var required_outskirts_clues: Array[String] = [
	"broken_spear",
	"straw_shoes",
	"broken_cart"
]


func mark_npc_talked(npc_id: String) -> void:
	if npc_id == "":
		return

	if talked_npcs.has(npc_id):
		return

	var was_all_talked := is_all_villagers_talked()

	talked_npcs[npc_id] = true
	_update_objective()
	quest_updated.emit()

	if not was_all_talked and is_all_villagers_talked():
		_play_objective_update_delayed()


func mark_returned_to_yeonhwa() -> void:
	if returned_to_yeonhwa:
		return

	returned_to_yeonhwa = true
	_update_objective()
	quest_updated.emit()
	_play_objective_update_delayed()


func mark_night_prepared() -> void:
	if night_prepared:
		return

	night_prepared = true
	_update_objective()
	quest_updated.emit()
	_play_objective_update_delayed()


func mark_dawn_started() -> void:
	if dawn_started:
		return

	dawn_started = true
	_update_objective()
	quest_updated.emit()
	_play_objective_update_delayed()


func mark_outside_noise_checked() -> void:
	if outside_noise_checked:
		return

	outside_noise_checked = true
	_update_objective()
	quest_updated.emit()
	_play_objective_update_delayed()


func mark_arrived_outskirts() -> void:
	if arrived_outskirts:
		return

	arrived_outskirts = true
	_update_objective()
	quest_updated.emit()
	_play_objective_update_delayed()


func mark_outskirts_clue_inspected(clue_id: String) -> void:
	if clue_id == "":
		return

	if inspected_outskirts_clues.has(clue_id):
		return

	inspected_outskirts_clues[clue_id] = true
	_update_objective()
	quest_updated.emit()
	_play_objective_update_delayed()

	print("[QuestSystem] 마을 어귀 단서 조사: ", clue_id)


func mark_old_weapon_acquired() -> void:
	if old_weapon_acquired:
		return

	old_weapon_acquired = true
	first_attack_done = false

	_update_objective()
	quest_updated.emit()
	_play_objective_update_delayed()

	print("[QuestSystem] 낡은 무기 획득")


func mark_first_attack_done() -> void:
	if first_attack_done:
		return

	first_attack_done = true

	_update_objective()
	quest_updated.emit()
	_play_objective_update_delayed()

	print("[QuestSystem] 첫 공격 튜토리얼 완료")


func is_arrived_outskirts() -> bool:
	return arrived_outskirts


func is_outside_noise_checked() -> bool:
	return outside_noise_checked


func is_dawn_started() -> bool:
	return dawn_started


func is_night_prepared() -> bool:
	return night_prepared


func is_returned_to_yeonhwa() -> bool:
	return returned_to_yeonhwa


func is_old_weapon_acquired() -> bool:
	return old_weapon_acquired


func is_first_attack_done() -> bool:
	return first_attack_done


func is_outskirts_clue_inspected(clue_id: String) -> bool:
	return inspected_outskirts_clues.has(clue_id)


func get_talked_count() -> int:
	var count := 0

	for id in required_npcs:
		if talked_npcs.has(id):
			count += 1

	return count


func get_required_count() -> int:
	return required_npcs.size()


func is_all_villagers_talked() -> bool:
	return get_talked_count() >= get_required_count()


func get_outskirts_clue_count() -> int:
	var count := 0

	for id in required_outskirts_clues:
		if inspected_outskirts_clues.has(id):
			count += 1

	return count


func get_required_outskirts_clue_count() -> int:
	return required_outskirts_clues.size()


func is_all_outskirts_clues_inspected() -> bool:
	return get_outskirts_clue_count() >= get_required_outskirts_clue_count()


func _update_objective() -> void:
	if arrived_outskirts:
		if old_weapon_acquired and not first_attack_done:
			current_objective = "마우스 왼쪽 클릭으로 낫 휘두르기"
		elif old_weapon_acquired and first_attack_done:
			current_objective = "다가오는 적을 대비하기"
		elif is_all_outskirts_clues_inspected():
			current_objective = "낡은 무기를 찾아보기"
		else:
			current_objective = "마을 어귀의 흔적을 살펴보기"

	elif outside_noise_checked:
		current_objective = "마을 어귀로 나가기"

	elif dawn_started:
		current_objective = "밖의 소리를 확인하기"

	elif night_prepared:
		current_objective = "오늘 밤을 넘길 준비를 마쳤다"

	elif returned_to_yeonhwa:
		current_objective = "집으로 돌아가 밤을 준비하기"

	elif is_all_villagers_talked():
		current_objective = "연화에게 돌아가기"

	else:
		current_objective = "마을 사람들과 대화하기"


func get_objective_text() -> String:
	if arrived_outskirts:
		if old_weapon_acquired and not first_attack_done:
			return "목표: " + current_objective

		if old_weapon_acquired and first_attack_done:
			return "목표: " + current_objective

		if is_all_outskirts_clues_inspected():
			return "목표: " + current_objective

		return "목표: " + current_objective + " " + str(get_outskirts_clue_count()) + "/" + str(get_required_outskirts_clue_count())

	if outside_noise_checked:
		return "목표: " + current_objective

	if dawn_started:
		return "목표: " + current_objective

	if night_prepared:
		return "목표 완료: " + current_objective

	if returned_to_yeonhwa:
		return "목표: " + current_objective

	if is_all_villagers_talked():
		return "목표: " + current_objective

	return "목표: " + current_objective + " " + str(get_talked_count()) + "/" + str(get_required_count())


func _play_objective_update_delayed() -> void:
	get_tree().create_timer(0.65).timeout.connect(func() -> void:
		AudioManager.play_objective_update()
	)


func debug_skip_to_dawn_noise() -> void:
	talked_npcs.clear()

	for id in required_npcs:
		talked_npcs[id] = true

	returned_to_yeonhwa = true
	night_prepared = true
	dawn_started = true
	outside_noise_checked = false
	arrived_outskirts = false
	old_weapon_acquired = false
	first_attack_done = false
	inspected_outskirts_clues.clear()

	_update_objective()
	quest_updated.emit()

	print("[DEBUG] 새벽 - 밖의 소리 확인 단계로 스킵")


func debug_skip_to_outskirts() -> void:
	talked_npcs.clear()

	for id in required_npcs:
		talked_npcs[id] = true

	returned_to_yeonhwa = true
	night_prepared = true
	dawn_started = true
	outside_noise_checked = true
	arrived_outskirts = true

	old_weapon_acquired = false
	first_attack_done = false
	inspected_outskirts_clues.clear()

	_update_objective()
	quest_updated.emit()

	print("[DEBUG] 마을 어귀 씬으로 스킵")


func debug_skip_to_old_weapon() -> void:
	debug_skip_to_outskirts()

	for id in required_outskirts_clues:
		inspected_outskirts_clues[id] = true

	old_weapon_acquired = false
	first_attack_done = false

	_update_objective()
	quest_updated.emit()

	print("[DEBUG] 낡은 무기 찾기 단계로 스킵")
