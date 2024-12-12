class_name AudioPool
extends Node

var sounds: Array[AudioQueue] = []
var random := RandomNumberGenerator.new()
var last_index: int = -1

func _ready() -> void:
	# Register with AudioManager
	AudioManager.register_audio_pool(name, self, false)
	for child in get_children():
		if child is AudioQueue:
			sounds.append(child)

func play_random_sound(bus: String = "") -> void:
	if sounds.size() == 0:
		print("AudioPool '%s': No sounds to play." % name)
		return

	var index = random.randi_range(0, sounds.size() - 1)
	if sounds.size() > 1:
		while index == last_index:
			index = random.randi_range(0, sounds.size() - 1)
	last_index = index
	sounds[index].play_sound(bus)
