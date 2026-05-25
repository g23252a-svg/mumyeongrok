extends Node

var sfx_player: AudioStreamPlayer
var bgm_player: AudioStreamPlayer
var event_sfx_player: AudioStreamPlayer
var outside_scream_stream: AudioStream
var battle_layer_player: AudioStreamPlayer
var outside_battle_layer_stream: AudioStream

var footstep_streams: Array[AudioStream] = []

var dialogue_open_stream: AudioStream
var dialogue_close_stream: AudioStream
var notebook_write_stream: AudioStream
var objective_update_stream: AudioStream
var home_door_stream: AudioStream
var night_transition_stream: AudioStream
var village_evening_bgm: AudioStream


const FOOTSTEP_PATHS := [
	"res://assets/audio/sfx/footstep_01.wav",
	"res://assets/audio/sfx/footstep_02.wav",
	"res://assets/audio/sfx/footstep_03.wav"
]

const DIALOGUE_OPEN_PATH := "res://assets/audio/sfx/dialogue_open.wav"
const DIALOGUE_CLOSE_PATH := "res://assets/audio/sfx/dialogue_close.wav"
const NOTEBOOK_WRITE_PATH := "res://assets/audio/sfx/notebook_write.wav"
const OBJECTIVE_UPDATE_PATH := "res://assets/audio/sfx/objective_update.wav"
const HOME_DOOR_PATH := "res://assets/audio/sfx/home_door.wav"
const NIGHT_TRANSITION_PATH := "res://assets/audio/sfx/night_transition.wav"
const OUTSIDE_SCREAM_PATH := "res://assets/audio/sfx/outside_scream.wav"
const OUTSIDE_BATTLE_LAYER_PATH := "res://assets/audio/sfx/outside_battle_layer.wav"
const VILLAGE_EVENING_BGM_PATH := "res://assets/audio/bgm/village_evening.ogg"


func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	add_child(sfx_player)

	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Master"
	add_child(bgm_player)
	event_sfx_player = AudioStreamPlayer.new()
	event_sfx_player.bus = "Master"
	battle_layer_player = AudioStreamPlayer.new()
	battle_layer_player.bus = "Master"
	add_child(battle_layer_player)
	add_child(event_sfx_player)

	_load_audio_files()
	
	outside_scream_stream = _load_optional_audio(OUTSIDE_SCREAM_PATH)
	outside_battle_layer_stream = _load_optional_audio(OUTSIDE_BATTLE_LAYER_PATH)


func _load_audio_files() -> void:
	footstep_streams.clear()

	for path in FOOTSTEP_PATHS:
		var stream := _load_optional_audio(path)
		if stream != null:
			footstep_streams.append(stream)

	dialogue_open_stream = _load_optional_audio(DIALOGUE_OPEN_PATH)
	dialogue_close_stream = _load_optional_audio(DIALOGUE_CLOSE_PATH)
	notebook_write_stream = _load_optional_audio(NOTEBOOK_WRITE_PATH)
	objective_update_stream = _load_optional_audio(OBJECTIVE_UPDATE_PATH)
	home_door_stream = _load_optional_audio(HOME_DOOR_PATH)
	night_transition_stream = _load_optional_audio(NIGHT_TRANSITION_PATH)
	village_evening_bgm = _load_optional_audio(VILLAGE_EVENING_BGM_PATH)

	if village_evening_bgm is AudioStreamOggVorbis:
		village_evening_bgm.loop = true


func _load_optional_audio(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path)

	print("[AudioManager] 파일 없음: ", path)
	return null


func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return

	sfx_player.stop()
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.play()


func play_random_footstep() -> void:
	if footstep_streams.is_empty():
		return

	var index := randi() % footstep_streams.size()
	play_sfx(footstep_streams[index], -8.0)


func play_dialogue_open() -> void:
	play_sfx(dialogue_open_stream, -5.0)


func play_dialogue_close() -> void:
	play_sfx(dialogue_close_stream, -6.0)


func play_notebook_write() -> void:
	play_sfx(notebook_write_stream, -4.0)


func play_objective_update() -> void:
	play_sfx(objective_update_stream, -4.0)


func play_home_door() -> void:
	play_sfx(home_door_stream, -4.0)


func play_night_transition() -> void:
	play_sfx(night_transition_stream, -6.0)


func play_village_evening_bgm() -> void:
	if village_evening_bgm == null:
		return

	if bgm_player.stream == village_evening_bgm and bgm_player.playing:
		return

	bgm_player.stream = village_evening_bgm
	bgm_player.volume_db = -16.0
	bgm_player.play()


func stop_bgm() -> void:
	if bgm_player.playing:
		bgm_player.stop()


func set_bgm_volume(volume_db: float) -> void:
	bgm_player.volume_db = volume_db
	
func play_event_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return

	event_sfx_player.stop()
	event_sfx_player.stream = stream
	event_sfx_player.volume_db = volume_db
	event_sfx_player.play()


func play_outside_scream() -> void:
	play_event_sfx(outside_scream_stream, -3.0)
	
func play_battle_layer_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return

	battle_layer_player.stop()
	battle_layer_player.stream = stream
	battle_layer_player.volume_db = volume_db
	battle_layer_player.play()


func play_outside_battle_layer() -> void:
	play_battle_layer_sfx(outside_battle_layer_stream, -2.0)
