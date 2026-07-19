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

var scale_card_shown := false
@onready var scale_card :Control = %ScaleCard
@onready var scale_card_slider :Control = %ScaleCardSlider
@onready var scale_card_timer : Timer = %ScaleCardTimer

var player_xp := 0.0
var player_level := 1

var enemies_killed := 0
var obsticles_destroyed := 0

func _ready() -> void:
	health_bar.max_value = player.health

	total_obsticles_label.text = str(total_obsticles)


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

	if player_xp >= player_level * 5.0:
		player_level += 1
		player_xp = 0
		level_up.emit()
		show_scale_card()

	xp_bar.value = player_xp
	xp_bar.max_value = player_level * 5.0


func show_scale_card() -> void:
	get_tree().paused = true
	scale_card.show()
	scale_card_timer.start()
	scale_card_shown = true

func hide_scale_card() -> void:
	get_tree().paused = false
	scale_card.hide()
	scale_card_timer.stop()
	scale_card_shown = false


func _on_card_button_pressed() -> void:
	if scale_card_shown:
		player.scale_factor += 0.5
		hide_scale_card()


func _on_scale_card_timer_timeout() -> void:
	if scale_card_shown:
		hide_scale_card()
