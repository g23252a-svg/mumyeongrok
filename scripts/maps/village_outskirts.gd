extends Node2D


func _ready() -> void:
	
	if AudioManager.has_method("stop_bgm"):
		AudioManager.stop_bgm()	
		
	print("[VillageOutskirts] 마을 어귀 진입")

	await get_tree().process_frame

	if QuestSystem.has_method("mark_arrived_outskirts"):
		QuestSystem.mark_arrived_outskirts()

	var dialogue_box = get_tree().get_first_node_in_group("dialogue_box")

	if dialogue_box != null:
		var lines: Array[String] = []
		lines.append("마을 어귀에는 아무도 없었다.")
		lines.append("다만 길 위에 흩어진 짚신과 부러진 창대가 남아 있었다.")
		lines.append("나는 그제야, 이 소리가 단순한 소문이 아니었음을 알았다.")

		await dialogue_box.show_dialogue("무명록", lines)
