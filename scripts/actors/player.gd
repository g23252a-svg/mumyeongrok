class_name Player
extends CharacterBody2D

@export var move_speed: float = 120.0
const ATTACK_DURATION := 0.35

@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D

enum State { IDLE, WALK, ATTACK, HURT, LOCKED }

var state: State = State.IDLE
var facing: Vector2 = Vector2.DOWN

var key_left: bool = false
var key_right: bool = false
var key_up: bool = false
var key_down: bool = false


func _ready() -> void:
	add_to_group("player")
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


func _physics_process(_delta: float) -> void:
	if state == State.LOCKED or state == State.ATTACK:
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

	if Input.is_action_just_pressed("attack"):
		_attack()


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


func lock() -> void:
	state = State.LOCKED
	velocity = Vector2.ZERO


func unlock() -> void:
	state = State.IDLE
