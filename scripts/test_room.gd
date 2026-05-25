extends Node2D


func _ready() -> void:
	print("[TestRoom] BGM 시작")
	AudioManager.play_village_evening_bgm()
