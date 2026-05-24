extends CanvasLayer

@onready var objective_label: Label = $Panel/ObjectiveLabel


func _ready() -> void:
	add_to_group("objective_ui")

	if not QuestSystem.quest_updated.is_connected(_refresh):
		QuestSystem.quest_updated.connect(_refresh)

	_refresh()


func _refresh() -> void:
	objective_label.text = QuestSystem.get_objective_text()
