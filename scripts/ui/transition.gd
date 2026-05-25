extends CanvasLayer

var fade_rect: ColorRect
var title_label: Label
var subtitle_label: Label


func _ready() -> void:
	add_to_group("scene_transition")
	layer = 100
	visible = false

	_create_fade_rect()
	_create_title_label()
	_create_subtitle_label()


func _create_fade_rect() -> void:
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	fade_rect.anchor_left = 0.0
	fade_rect.anchor_top = 0.0
	fade_rect.anchor_right = 1.0
	fade_rect.anchor_bottom = 1.0
	fade_rect.offset_left = 0.0
	fade_rect.offset_top = 0.0
	fade_rect.offset_right = 0.0
	fade_rect.offset_bottom = 0.0

	add_child(fade_rect)


func _create_title_label() -> void:
	title_label = Label.new()
	title_label.text = ""
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.modulate = Color(1, 1, 1, 0)
	title_label.add_theme_font_size_override("font_size", 22)

	title_label.anchor_left = 0.0
	title_label.anchor_top = 0.0
	title_label.anchor_right = 1.0
	title_label.anchor_bottom = 1.0
	title_label.offset_left = 0.0
	title_label.offset_top = -24.0
	title_label.offset_right = 0.0
	title_label.offset_bottom = 0.0

	add_child(title_label)


func _create_subtitle_label() -> void:
	subtitle_label = Label.new()
	subtitle_label.text = ""
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle_label.modulate = Color(1, 1, 1, 0)
	subtitle_label.add_theme_font_size_override("font_size", 13)
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	subtitle_label.anchor_left = 0.0
	subtitle_label.anchor_top = 0.0
	subtitle_label.anchor_right = 1.0
	subtitle_label.anchor_bottom = 1.0
	subtitle_label.offset_left = 40.0
	subtitle_label.offset_top = 28.0
	subtitle_label.offset_right = -40.0
	subtitle_label.offset_bottom = 0.0

	add_child(subtitle_label)


func play_dawn_transition() -> void:
	visible = true

	title_label.text = "1592년 4월 14일 새벽"
	subtitle_label.text = "먼 곳에서 북소리와 사람들의 비명이 섞여 들려왔다."

	fade_rect.color = Color(0, 0, 0, 0)
	title_label.modulate = Color(1, 1, 1, 0)
	subtitle_label.modulate = Color(1, 1, 1, 0)

	var fade_in := create_tween()
	fade_in.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 1.0)
	await fade_in.finished

	var text_in := create_tween()
	text_in.tween_property(title_label, "modulate:a", 1.0, 0.8)
	text_in.parallel().tween_property(subtitle_label, "modulate:a", 1.0, 0.8)
	await text_in.finished

	await get_tree().create_timer(2.2).timeout

	var text_out := create_tween()
	text_out.tween_property(title_label, "modulate:a", 0.0, 0.6)
	text_out.parallel().tween_property(subtitle_label, "modulate:a", 0.0, 0.6)
	await text_out.finished

	var fade_out := create_tween()
	fade_out.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 1.0)
	await fade_out.finished

	visible = false
	
func play_exit_transition() -> void:
	visible = true

	title_label.text = "마을 어귀"
	subtitle_label.text = "그곳에서 나는 처음으로 전쟁의 얼굴을 보았다."

	fade_rect.color = Color(0, 0, 0, 0)
	title_label.modulate = Color(1, 1, 1, 0)
	subtitle_label.modulate = Color(1, 1, 1, 0)

	var fade_in := create_tween()
	fade_in.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 1.0)
	await fade_in.finished

	var text_in := create_tween()
	text_in.tween_property(title_label, "modulate:a", 1.0, 0.8)
	text_in.parallel().tween_property(subtitle_label, "modulate:a", 1.0, 0.8)
	await text_in.finished

	await get_tree().create_timer(1.6).timeout

	var text_out := create_tween()
	text_out.tween_property(title_label, "modulate:a", 0.0, 0.5)
	text_out.parallel().tween_property(subtitle_label, "modulate:a", 0.0, 0.5)
	await text_out.finished

	var fade_out := create_tween()
	fade_out.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.8)
	await fade_out.finished

	visible = false
