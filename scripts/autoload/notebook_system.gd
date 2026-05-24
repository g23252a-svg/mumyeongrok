extends Node

signal entry_added(entry: Dictionary)

var entries: Array[Dictionary] = []


func add_entry(id: String, display_name: String, description: String) -> void:
	# 같은 인물/사건 중복 기록 방지
	for e in entries:
		if e["id"] == id:
			print("[무명첩] 이미 기록됨: ", display_name)
			return

	var entry: Dictionary = {
		"id": id,
		"name": display_name,
		"description": description,
		"date": "1592년 4월 13일",
		"fate": "기록 중"
	}

	entries.append(entry)
	print("[무명첩] 새 기록: ", display_name)
	entry_added.emit(entry)


func update_fate(id: String, fate: String) -> void:
	for e in entries:
		if e["id"] == id:
			e["fate"] = fate
			print("[무명첩] ", e["name"], "의 운명: ", fate)
			return


func get_all_entries() -> Array[Dictionary]:
	return entries


func debug_print_entries() -> void:
	print("===== 무명첩 전체 기록 =====")
	for e in entries:
		print(e["date"], " / ", e["name"], " / ", e["fate"], " / ", e["description"])
	print("===========================")
