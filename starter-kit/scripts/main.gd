extends Node3D

signal level_lost
signal level_up
signal level_won(level_path : String)

@export_file_path("*.tscn") var enemy_scene : String  = "res://starter-kit/objects/enemy/enemy.tscn"

@onready var total_obsticles := len(get_tree().get_nodes_in_group("obsticle"))
@onready var player := %Player
@onready var enemy_spawn : PathFollow3D = %EnemySpawnPathFollow3D

@onready var kills_label: Label = %KillsLabel
@onready var obsticles_label: Label = %ObsticlesLabel
@onready var total_obsticles_label: Label = %TotalObsticlesLabel
@onready var health_bar: HSlider = %HealthBarSlider
@onready var xp_bar: HSlider = %XPBar

@onready var level_up_card :Control = %LevelUpCard

var player_xp := 0.0
var player_level := 1

var enemies_killed := 0
var obsticles_destroyed := 0

func _ready() -> void:
	health_bar.max_value = player.health

	total_obsticles_label.text = str(total_obsticles)

	for node in get_tree().get_nodes_in_group("obsticle"):
		node.destroyed.connect(_on_obsticle_destroyed)

func _process(delta: float) -> void:
	var playback : AudioStreamPlayback = BackgroundMusicController.audio_stream.get_stream_playback()
	var playing_clip_name = BackgroundMusicController.audio_stream.stream.get_clip_name(playback.get_current_clip_index())

	if playing_clip_name != "MAIN":
		playback.switch_to_clip_by_name("MAIN")


func _on_player_died() -> void:
	level_lost.emit()


func _on_enemy_spawn_timer_timeout() -> void:
	enemy_spawn.progress_ratio = randf()

	var spawn_loc := enemy_spawn.global_position
	var loaded_enemy_scene := load(enemy_scene)
	var enemy : Node3D = loaded_enemy_scene.instantiate()

	add_child(enemy)
	enemy.global_position = spawn_loc

	enemy.died.connect(_on_enemy_died)
	enemy.died.connect(player._on_enemy_died)

func _on_enemy_died() -> void:
	enemies_killed += 1
	kills_label.text = str(enemies_killed)

	add_xp(1.0)


func _on_player_damaged(health_left: float) -> void:
	health_bar.value = health_left


func _on_obsticle_destroyed() -> void:
	obsticles_destroyed += 1
	obsticles_label.text = str(obsticles_destroyed)

	if obsticles_destroyed == total_obsticles:
		level_won.emit("")


func add_xp(amount: float) -> void:
	player_xp += amount

	if player_xp >= player_level * 3.0:
		player_level += 1
		player_xp = 0
		level_up.emit()
		level_up_card.open()

	xp_bar.value = player_xp
	xp_bar.max_value = player_level * 3.0


func _on_card_button_pressed() -> void:
	player.scale_factor += 0.5

func _play_game_music() -> void:
	var playback : AudioStreamPlayback = BackgroundMusicController.audio_stream.get_stream_playback()
	playback.switch_to_clip_by_name("MAIN")
