extends MainMenu

func _ready() -> void:
	var playback : AudioStreamPlayback = BackgroundMusicController.audio_stream.get_stream_playback()
	playback.switch_to_clip_by_name("INT2")

