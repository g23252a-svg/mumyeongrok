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


func is_returned_to_yeonhwa() -> bool:
	return returned_to_yeonhwa


func is_night_prepared() -> bool:
	return night_prepared


func _update_objective() -> void:
	if night_prepared:
		current_objective = "오늘 밤을 넘길 준비를 마쳤다"
	elif returned_to_yeonhwa:
		current_objective = "집으로 돌아가 밤을 준비하기"
	elif is_all_villagers_talked():
		current_objective = "연화에게 돌아가기"
	else:
		current_objective = "마을 사람들과 대화하기"


func _play_objective_update_delayed() -> void:
	get_tree().create_timer(0.65).timeout.connect(func() -> void:
		AudioManager.play_objective_update()
	)


func get_objective_text() -> String:
	if night_prepared:
		return "목표 완료: " + current_objective

	if returned_to_yeonhwa:
		return "목표: " + current_objective

	if is_all_villagers_talked():
		return "목표: " + current_objective

	return "목표: " + current_objective + " " + str(get_talked_count()) + "/" + str(get_required_count())
