extends Node

# Audio queues
var spatial_audio_queues: Dictionary = {}
var audio_queues: Dictionary = {}

# Audio pools
var spatial_audio_pools: Dictionary = {}
var audio_pools: Dictionary = {}

func register_audio_queue(name: String, queue, is_spatial: bool) -> void:
	if is_spatial:
		spatial_audio_queues[name] = queue
	else:
		audio_queues[name] = queue
		
func register_audio_pool(name: String, pool, is_spatial: bool) -> void:
	if is_spatial:
		spatial_audio_pools[name] = pool
	else:
		audio_pools[name] = pool

func play_sound(name: String, position: Vector2 = Vector2.ZERO, bus: String = "", is_spatial: bool = true) -> void:
	if is_spatial:
		if name in spatial_audio_queues:
			spatial_audio_queues[name].play_sound(position, bus)
		
		if name in spatial_audio_pools:
			spatial_audio_pools[name].play_random_sound(position, bus)
	else:
		if name in audio_queues:
			audio_queues[name].play_sound(bus)
		
		if name in audio_pools:
			audio_pools[name].play_random_sound(bus)
