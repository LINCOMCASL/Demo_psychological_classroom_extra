extends Node

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

# 一个全局函数，用于切换音乐
func change_music(new_music_stream: AudioStream) -> void:
	# 检查是否是同一首音乐，避免重复播放
	if bgm_player.stream == new_music_stream:
		return

	bgm_player.stream = new_music_stream
	bgm_player.play()

# 一个全局函数，用于停止音乐
func stop_music() -> void:
	bgm_player.stop()
