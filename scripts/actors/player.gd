class_name Player
extends CharacterBody2D

@export var move_speed: float = 120.0
const ATTACK_DURATION := 0.35

@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

enum State { IDLE, WALK, ATTACK, HURT, LOCKED }

var state: State = State.IDLE
var facing: Vector2 = Vector2.DOWN
var last_direction: String = "south"

var footstep_timer: float = 0.0
const FOOTSTEP_INTERVAL: float = 0.45

var key_left: bool = false
var key_right: bool = false
var key_up: bool = false
var key_down: bool = false


func _ready() -> void:
	add_to_group("player")

	_setup_animation_speeds()
	_play_animation_safe("idle_south")

	hitbox.monitoring = false
	hitbox_shape.disabled = true

	print("PLAYER READY")


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var pressed = event.pressed
		var keycode = event.keycode
		var physical_keycode = event.physical_keycode

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

	if Input.is_action_just_pressed("attack"):
		_attack()


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

	for anim_name: String in idle_anims:
		_set_animation_speed_safe(anim_name, 4.0)

	for anim_name: String in walk_anims:
		_set_animation_speed_safe(anim_name, 8.0)


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


func _play_animation_safe(anim_name: String) -> void:
	if anim_name == "":
		return
	if animated_sprite == null:
		return
	if animated_sprite.sprite_frames == null:
		return

	var anim_key := StringName(anim_name)

	if not animated_sprite.sprite_frames.has_animation(anim_key):
		print("[Player] missing animation: ", anim_name)
		return

	if animated_sprite.animation != anim_key:
		animated_sprite.play(anim_key)


func _update_hitbox_position() -> void:
	hitbox.position = facing * 16


func _attack() -> void:
	state = State.ATTACK
	hitbox.monitoring = true
	hitbox_shape.disabled = false

	await get_tree().create_timer(ATTACK_DURATION).timeout

	hitbox.monitoring = false
	hitbox_shape.disabled = true
	state = State.IDLE
	_update_animation(Vector2.ZERO)


func lock() -> void:
	state = State.LOCKED
	velocity = Vector2.ZERO
	_update_animation(Vector2.ZERO)


func unlock() -> void:
	state = State.IDLE
	_update_animation(Vector2.ZERO)
