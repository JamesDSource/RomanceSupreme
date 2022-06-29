extends AudioStreamPlayer3D

func play_sound(stream_: AudioStream, pos: Vector3):
	global_transform.origin = pos
	stream = stream_
	play()

func _on_SingleSoundPlayer_finished():
	queue_free()
