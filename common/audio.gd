# Audio module v1.2
# Last updated 2020.12.01

extends Node

onready var musicPlayer : AudioStreamPlayer = $MusicPlayer

func playMusic(music : AudioStream, vol : float = 0.0) -> void:
	if music == musicPlayer.stream: return
	musicPlayer.stream = music
	musicPlayer.set_volume_db(vol)
	musicPlayer.play()

func stopMusic() -> void:
	musicPlayer.stop()
	musicPlayer.stream = null
