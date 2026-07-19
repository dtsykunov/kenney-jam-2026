extends Node3D

signal level_lost
signal level_won(level_path : String)

@export_file_path("*.tscn") var enemy_scene : String  = "res://starter-kit/objects/enemy/enemy.tscn"

@onready var total_obsticles := len(get_tree().get_nodes_in_group("obsticle"))
@onready var player := %Player
@onready var enemy_spawn : PathFollow3D = %EnemySpawnPathFollow3D

@onready var kills_label: Label = %KillsLabel
@onready var obsticles_label: Label = %ObsticlesLabel
@onready var total_obsticles_label: Label = %TotalObsticlesLabel
@onready var health_bar: HSlider = %HealthBarSlider

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


func _on_player_damaged(health_left: float) -> void:
	health_bar.value = health_left



func _on_obsticle_destroyed() -> void:
	obsticles_destroyed += 1
	obsticles_label.text = str(obsticles_destroyed)

	if obsticles_destroyed == total_obsticles:
		level_won.emit("")
