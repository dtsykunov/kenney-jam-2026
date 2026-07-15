extends Node

# Code adapted from KidsCanCode

var num_players = 12

var available : Array[AudioStreamPlayer] = []  # The available players.
var queue := []  # The queue of sounds to play.

func _ready():

	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)

		available.append(p)

		p.finished.connect(_on_stream_finished.bind(p))


func _on_stream_finished(stream): available.append(stream)

func play(sound_path: String, bus: StringName = &"SFX"): queue.append([sound_path, bus])

func _process(_delta):

	if not queue.is_empty() and not available.is_empty():

		var sound_info = queue.pop_front()
		available[0].stream = load(sound_info[0])
		available[0].bus = sound_info[1]
		available[0].play()
		available[0].pitch_scale = randf_range(0.9, 1.1)

		available.pop_front()
