@tool
class_name SpatialAudioQueue
extends Node2D

@export var audio_count: int = 1
@export var audio_stream: AudioStream
@export var bus_name: String = "SFX"

var next: int = 0
var audio_stream_players: Array[AudioStreamPlayer2D] = []

func _ready() -> void:
	# Register with AudioManager
	AudioManager.register_audio_queue(name, self, true)

	# Initialize the pool of AudioStreamPlayer2D instances
	for i in range(audio_count):
		var player = AudioStreamPlayer2D.new()
		player.stream = audio_stream
		player.bus = bus_name
		add_child(player)
		audio_stream_players.append(player)

func play_sound(position: Vector2 = Vector2.ZERO, bus: String = "") -> void:
	var player = audio_stream_players[next]
	if not player.playing:
		player.bus = bus if bus != "" else bus_name
		player.play()
		next = (next + 1) % audio_stream_players.size()
	else:
		print("SpatialAudioQueue '%s': All players are busy." % name)
