extends CanvasLayer

@onready var panel: ColorRect = $Panel
@onready var name_label: Label = $Panel/NameLabel
@onready var text_label: Label = $Panel/TextLabel

var is_open: bool = false
var can_close: bool = false


func _ready() -> void:
	add_to_group("dialogue_box")

	panel.visible = false

	panel.position = Vector2(18, 126)
	panel.size = Vector2(390, 130)
	panel.color = Color(0, 0, 0, 0.8)

	name_label.position = Vector2(12, 6)
	name_label.size = Vector2(360, 23)
	name_label.text = ""

	text_label.position = Vector2(12, 32)
	text_label.size = Vector2(360, 90)
	text_label.text = ""
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func show_dialogue(speaker: String, lines: Array[String]) -> void:
	is_open = true
	can_close = false
	panel.visible = true

	name_label.text = speaker

	var body_text := ""
	for line in lines:
		body_text += line + "\n"

	text_label.text = body_text.strip_edges()

	await get_tree().create_timer(0.15).timeout
	can_close = true

	while is_open:
		await get_tree().process_frame

	panel.visible = false
	can_close = false


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return

	if not can_close:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var keycode = event.keycode
		var physical_keycode = event.physical_keycode

		if keycode == KEY_E or physical_keycode == KEY_E:
			is_open = false
			get_viewport().set_input_as_handled()

		if keycode == KEY_SPACE or physical_keycode == KEY_SPACE:
			is_open = false
			get_viewport().set_input_as_handled()

		if keycode == KEY_ENTER or physical_keycode == KEY_ENTER:
			is_open = false
			get_viewport().set_input_as_handled()
