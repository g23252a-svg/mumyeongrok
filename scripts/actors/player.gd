class_name Player
extends CharacterBody2D

const SPEED := 60.0
const ATTACK_DURATION := 0.35

@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D

enum State { IDLE, WALK, ATTACK, HURT, LOCKED }
var state: State = State.IDLE
var facing: Vector2 = Vector2.DOWN

func _ready() -> void:
	add_to_group("player")
	hitbox.monitoring = false
	hitbox_shape.disabled = true

func _physics_process(_delta: float) -> void:
	if state == State.LOCKED or state == State.ATTACK:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		


	var input_vec := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()

	if input_vec != Vector2.ZERO:
		velocity = input_vec * SPEED
		facing = input_vec.normalized()
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

func unlock() -> void:
	state = State.IDLE
