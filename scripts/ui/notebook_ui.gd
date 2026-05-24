extends CanvasLayer

@onready var panel: ColorRect = $Panel
@onready var title_label: Label = $Panel/TitleLabel
@onready var entry_label: Label = $Panel/EntryLabel
@onready var hint_label: Label = $Panel/HintLabel

var is_open: bool = false


func _ready() -> void:
	add_to_group("notebook_ui")

	panel.visible = false

	panel.position = Vector2(38, 28)
	panel.size = Vector2(350, 185)
	panel.color = Color(0, 0, 0, 0.86)

	title_label.position = Vector2(14, 10)
	title_label.size = Vector2(320, 24)
	title_label.text = "무명첩"

	entry_label.position = Vector2(14, 42)
	entry_label.size = Vector2(320, 105)
	entry_label.text = "아직 기록이 없습니다."
	entry_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	hint_label.position = Vector2(14, 154)
	hint_label.size = Vector2(320, 24)
	hint_label.text = "[N/ESC] 닫기"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var keycode = event.keycode
		var physical_keycode = event.physical_keycode

		if keycode == KEY_N or physical_keycode == KEY_N:
			toggle()
			get_viewport().set_input_as_handled()

		if is_open and (keycode == KEY_ESCAPE or physical_keycode == KEY_ESCAPE):
			close()
			get_viewport().set_input_as_handled()


func toggle() -> void:
	if is_open:
		close()
	else:
		open()


func open() -> void:
	is_open = true
	panel.visible = true
	_refresh_entries()

	var player = get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("lock"):
		player.lock()


func close() -> void:
	is_open = false
	panel.visible = false

	var player = get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("unlock"):
		player.unlock()


func _refresh_entries() -> void:
	var entries = NotebookSystem.get_all_entries()

	if entries.is_empty():
		entry_label.text = "아직 기록이 없습니다."
		return

	var text := ""

	for e in entries:
		text += "■ " + str(e["name"]) + "\n"
		text += "  " + str(e["date"]) + "\n"
		text += "  운명: " + str(e["fate"]) + "\n"
		text += "  " + str(e["description"]) + "\n\n"

	entry_label.text = text.strip_edges()
