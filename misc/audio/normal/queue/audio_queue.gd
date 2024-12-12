class_name AudioQueue
extends Node

@export var audio_count: int = 1
@export var audio_stream: AudioStream
@export var bus_name: String = "SFX"

var next: int = 0
var audio_stream_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	# Register with AudioManager
	AudioManager.register_audio_queue(name, self, false)

	# Initialize the pool of AudioStreamPlayer instances
	for i in range(audio_count):
		var player = AudioStreamPlayer.new()
		player.stream = audio_stream
		player.bus = bus_name
		add_child(player)
		audio_stream_players.append(player)

func play_sound(bus: String = "") -> void:
	var player = audio_stream_players[next]
	if not player.playing:
		player.bus = bus if bus != "" else bus_name
		player.play()
		next = (next + 1) % audio_stream_players.size()
	else:
		print("AudioQueue '%s': All players are busy." % name)
