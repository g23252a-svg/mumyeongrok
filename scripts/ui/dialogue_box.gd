extends CanvasLayer

@onready var panel: ColorRect = $Panel
@onready var name_label: Label = $Panel/NameLabel
@onready var text_label: Label = $Panel/TextLabel

var is_open: bool = false
var can_close: bool = false

var dialogue_lines: Array[String] = []
var current_line_index: int = 0


func _ready() -> void:
	add_to_group("dialogue_box")

	panel.visible = false

	panel.position = Vector2(110, 236)
	panel.size = Vector2(420, 96)
	panel.color = Color(0, 0, 0, 0.74)

	name_label.position = Vector2(14, 7)
	name_label.size = Vector2(392, 20)
	name_label.text = ""
	name_label.add_theme_font_size_override("font_size", 13)

	text_label.position = Vector2(14, 31)
	text_label.size = Vector2(392, 58)
	text_label.text = ""
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.add_theme_font_size_override("font_size", 13)


func show_dialogue(speaker: String, lines: Array) -> void:
	is_open = true
	can_close = false
	panel.visible = true

	AudioManager.play_dialogue_open()

	name_label.text = speaker

	dialogue_lines.clear()
	current_line_index = 0

	for line in lines:
		dialogue_lines.append(str(line))

	if dialogue_lines.is_empty():
		dialogue_lines.append("...")

	_refresh_current_line()

	await get_tree().create_timer(0.15).timeout
	can_close = true

	while is_open:
		await get_tree().process_frame

	panel.visible = false
	can_close = false
	dialogue_lines.clear()
	current_line_index = 0


func _refresh_current_line() -> void:
	if dialogue_lines.is_empty():
		text_label.text = ""
		return

	var line_text := dialogue_lines[current_line_index]

	if current_line_index < dialogue_lines.size() - 1:
		text_label.text = line_text + "\n\n▼"
	else:
		text_label.text = line_text


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return

	if not can_close:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var keycode = event.keycode
		var physical_keycode = event.physical_keycode

		var should_advance: bool = (
			keycode == KEY_E
			or physical_keycode == KEY_E
			or keycode == KEY_SPACE
			or physical_keycode == KEY_SPACE
			or keycode == KEY_ENTER
			or physical_keycode == KEY_ENTER
		)

		if should_advance:
			_advance_or_close()
			get_viewport().set_input_as_handled()


func _advance_or_close() -> void:
	if current_line_index < dialogue_lines.size() - 1:
		current_line_index += 1
		_refresh_current_line()
		return

	_close_dialogue()


func _close_dialogue() -> void:
	if not is_open:
		return

	AudioManager.play_dialogue_close()
	is_open = false
