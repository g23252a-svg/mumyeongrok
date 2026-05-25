class_name Player
extends CharacterBody2D

@export var move_speed: float = 120.0

const ATTACK_HITBOX_DURATION: float = 0.18
const ATTACK_RECOVERY_FALLBACK: float = 0.75
const FOOTSTEP_INTERVAL: float = 0.30

@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

enum State { IDLE, WALK, ATTACK, HURT, LOCKED }

var state: State = State.IDLE
var facing: Vector2 = Vector2.DOWN
var last_direction: String = "south"

var has_old_weapon: bool = false
var attack_input_was_down: bool = false
var attack_serial: int = 0

var footstep_timer: float = 0.0

var key_left: bool = false
var key_right: bool = false
var key_up: bool = false
var key_down: bool = false


func _ready() -> void:
	add_to_group("player")

	if QuestSystem.has_method("is_old_weapon_acquired") and QuestSystem.is_old_weapon_acquired():
		has_old_weapon = true

	if animated_sprite != null:
		if not animated_sprite.animation_finished.is_connected(_on_attack_animation_finished):
			animated_sprite.animation_finished.connect(_on_attack_animation_finished)

	_setup_animation_speeds()
	_play_animation_safe("idle_south")

	_disable_hitbox()

	print("PLAYER READY")


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var pressed: bool = event.pressed
		var keycode: int = event.keycode
		var physical_keycode: int = event.physical_keycode

		if keycode == KEY_A or physical_keycode == KEY_A or keycode == KEY_LEFT or physical_keycode == KEY_LEFT:
			key_left = pressed

		if keycode == KEY_D or physical_keycode == KEY_D or keycode == KEY_RIGHT or physical_keycode == KEY_RIGHT:
			key_right = pressed

		if keycode == KEY_W or physical_keycode == KEY_W or keycode == KEY_UP or physical_keycode == KEY_UP:
			key_up = pressed

		if keycode == KEY_S or physical_keycode == KEY_S or keycode == KEY_DOWN or physical_keycode == KEY_DOWN:
			key_down = pressed


func _physics_process(delta: float) -> void:
	if state == State.LOCKED:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_animation(Vector2.ZERO)
		return

	_handle_attack_input()

	if state == State.ATTACK:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir := Vector2.ZERO

	if key_left:
		dir.x -= 1
	if key_right:
		dir.x += 1
	if key_up:
		dir.y -= 1
	if key_down:
		dir.y += 1

	if dir != Vector2.ZERO:
		dir = dir.normalized()
		velocity = dir * move_speed
		facing = dir
		_update_hitbox_position()
		state = State.WALK
	else:
		velocity = Vector2.ZERO
		state = State.IDLE

	move_and_slide()
	_update_animation(dir)
	_update_footstep_audio(delta)


func equip_old_weapon() -> void:
	has_old_weapon = true
	print("[Player] 낡은 낫 장착")


func _handle_attack_input() -> void:
	if not has_old_weapon:
		return

	if state == State.ATTACK:
		return

	var attack_pressed := false

	# InputMap에 attack을 등록해둔 경우도 지원
	if InputMap.has_action("attack") and Input.is_action_just_pressed("attack"):
		attack_pressed = true

	# 마우스 왼쪽 클릭 직접 감지
	var left_click_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	# J키는 개발 테스트용으로 일단 유지
	var j_down := Input.is_key_pressed(KEY_J) or Input.is_physical_key_pressed(KEY_J)

	if (left_click_down or j_down) and not attack_input_was_down:
		attack_pressed = true

	attack_input_was_down = left_click_down or j_down

	if attack_pressed:
		_attack()


func _attack() -> void:
	if not has_old_weapon:
		return

	if state == State.ATTACK:
		return

	attack_serial += 1
	var current_attack_serial := attack_serial

	state = State.ATTACK
	velocity = Vector2.ZERO

	_update_hitbox_position()
	_enable_hitbox()

	var attack_anim := "attack_" + last_direction
	var played := _play_animation_safe(attack_anim)

	print("[Player] 공격 모션: ", attack_anim)

	if not played:
		_disable_hitbox()
		_finish_attack()
		return
		
	if QuestSystem.has_method("mark_first_attack_done"):
		QuestSystem.mark_first_attack_done()

	await get_tree().create_timer(ATTACK_HITBOX_DURATION).timeout

	if current_attack_serial == attack_serial:
		_disable_hitbox()

	await get_tree().create_timer(ATTACK_RECOVERY_FALLBACK).timeout

	if current_attack_serial == attack_serial and state == State.ATTACK:
		print("[Player] 공격 애니메이션 종료 신호 없음 — fallback 종료")
		_finish_attack()


func _on_attack_animation_finished() -> void:
	if state != State.ATTACK:
		return

	var anim_name := String(animated_sprite.animation)

	if not anim_name.begins_with("attack_"):
		return

	_finish_attack()


func _finish_attack() -> void:
	if state != State.ATTACK:
		return

	_disable_hitbox()
	state = State.IDLE
	_update_animation(Vector2.ZERO)


func _setup_animation_speeds() -> void:
	if animated_sprite == null:
		return
	if animated_sprite.sprite_frames == null:
		return

	var idle_anims: Array[String] = [
		"idle_south",
		"idle_south_east",
		"idle_east",
		"idle_north_east",
		"idle_north",
		"idle_north_west",
		"idle_west",
		"idle_south_west"
	]

	var walk_anims: Array[String] = [
		"walk_south",
		"walk_south_east",
		"walk_east",
		"walk_north_east",
		"walk_north",
		"walk_north_west",
		"walk_west",
		"walk_south_west"
	]

	var attack_anims: Array[String] = [
		"attack_south",
		"attack_south_east",
		"attack_east",
		"attack_north_east",
		"attack_north",
		"attack_north_west",
		"attack_west",
		"attack_south_west"
	]

	for anim_name: String in idle_anims:
		_set_animation_speed_safe(anim_name, 4.0)
		_set_animation_loop_safe(anim_name, true)

	for anim_name: String in walk_anims:
		_set_animation_speed_safe(anim_name, 8.0)
		_set_animation_loop_safe(anim_name, true)

	for anim_name: String in attack_anims:
		_set_animation_speed_safe(anim_name, 28.0)
		_set_animation_loop_safe(anim_name, false)


func _set_animation_speed_safe(anim_name: String, fps: float) -> void:
	if anim_name == "":
		return
	if animated_sprite == null:
		return
	if animated_sprite.sprite_frames == null:
		return

	var anim_key := StringName(anim_name)

	if animated_sprite.sprite_frames.has_animation(anim_key):
		animated_sprite.sprite_frames.set_animation_speed(anim_key, fps)
	else:
		print("[Player] missing animation: ", anim_name)


func _set_animation_loop_safe(anim_name: String, should_loop: bool) -> void:
	if anim_name == "":
		return
	if animated_sprite == null:
		return
	if animated_sprite.sprite_frames == null:
		return

	var anim_key := StringName(anim_name)

	if animated_sprite.sprite_frames.has_animation(anim_key):
		animated_sprite.sprite_frames.set_animation_loop(anim_key, should_loop)


func _get_direction_name(input_vector: Vector2) -> String:
	if input_vector == Vector2.ZERO:
		return last_direction

	if abs(input_vector.x) < 0.3:
		if input_vector.y > 0:
			return "south"
		else:
			return "north"

	if abs(input_vector.y) < 0.3:
		if input_vector.x > 0:
			return "east"
		else:
			return "west"

	if input_vector.x > 0 and input_vector.y > 0:
		return "south_east"
	if input_vector.x < 0 and input_vector.y > 0:
		return "south_west"
	if input_vector.x > 0 and input_vector.y < 0:
		return "north_east"
	if input_vector.x < 0 and input_vector.y < 0:
		return "north_west"

	return last_direction


func _update_animation(input_vector: Vector2) -> void:
	if state == State.ATTACK:
		return

	if input_vector != Vector2.ZERO:
		var direction_name: String = _get_direction_name(input_vector)

		if direction_name == "":
			direction_name = "south"

		last_direction = direction_name
		_play_animation_safe("walk_" + direction_name)
	else:
		if last_direction == "":
			last_direction = "south"

		_play_animation_safe("idle_" + last_direction)


func _update_footstep_audio(delta: float) -> void:
	if velocity.length() <= 0.0:
		footstep_timer = 0.0
		return

	footstep_timer -= delta

	if footstep_timer <= 0.0:
		AudioManager.play_random_footstep()
		footstep_timer = FOOTSTEP_INTERVAL


func _play_animation_safe(anim_name: String) -> bool:
	if anim_name == "":
		return false
	if animated_sprite == null:
		return false
	if animated_sprite.sprite_frames == null:
		return false

	var anim_key := StringName(anim_name)

	if not animated_sprite.sprite_frames.has_animation(anim_key):
		print("[Player] missing animation: ", anim_name)
		return false

	if animated_sprite.animation != anim_key:
		animated_sprite.play(anim_key)
	else:
		animated_sprite.play(anim_key)

	return true


func _update_hitbox_position() -> void:
	if hitbox == null:
		return

	hitbox.position = facing * 16.0


func _enable_hitbox() -> void:
	if hitbox != null:
		hitbox.set_deferred("monitoring", true)

	if hitbox_shape != null:
		hitbox_shape.set_deferred("disabled", false)


func _disable_hitbox() -> void:
	if hitbox != null:
		hitbox.set_deferred("monitoring", false)

	if hitbox_shape != null:
		hitbox_shape.set_deferred("disabled", true)


func lock() -> void:
	state = State.LOCKED
	velocity = Vector2.ZERO
	_disable_hitbox()
	_update_animation(Vector2.ZERO)


func unlock() -> void:
	if state == State.ATTACK:
		return

	state = State.IDLE
	_update_animation(Vector2.ZERO)
