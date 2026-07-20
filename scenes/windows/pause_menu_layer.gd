extends CanvasLayer

@onready var pause_menu = %PauseMenu

func _on_pause_menu_hidden():
	hide()

func _on_visibility_changed():
	if visible:
		_play_game_music("INT1")
		pause_menu.show()

func _ready():
	visibility_changed.connect(_on_visibility_changed)

func _play_game_music(clip: String) -> void:
	var playback : AudioStreamPlayback = BackgroundMusicController.audio_stream.get_stream_playback()
	playback.switch_to_clip_by_name(clip)
