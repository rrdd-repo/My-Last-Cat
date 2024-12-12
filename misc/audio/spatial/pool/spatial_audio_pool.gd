@tool
class_name SpatialAudioPool
extends Node2D

var sounds: Array[SpatialAudioQueue] = []
var random := RandomNumberGenerator.new()
var last_index: int = -1

func _ready() -> void:
	# Register with AudioManager
	AudioManager.register_audio_pool(name, self, true)
	for child in get_children():
		if child is SpatialAudioQueue:
			sounds.append(child)

func play_random_sound(position: Vector2 = Vector2.ZERO, bus: String = "") -> void:
	if sounds.size() == 0:
		print("SpatialAudioPool '%s': No sounds to play." % name)
		return

	var index = random.randi_range(0, sounds.size() - 1)
	if sounds.size() > 1:
		while index == last_index:
			index = random.randi_range(0, sounds.size() - 1)
	last_index = index
	sounds[index].play_sound(position, bus)
