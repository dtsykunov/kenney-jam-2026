extends Node3D

signal level_lost
signal level_won(level_path : String)

@onready var total_coins := len(get_tree().get_nodes_in_group("coin"))
@onready var player := %Player

@onready var enemy_spawn : PathFollow3D = %EnemySpawnPathFollow3D

@export_file_path("*.tscn") var enemy_scene : String  = "res://starter-kit/objects/enemy/enemy.tscn"

var enemies_killed := 0

func _ready() -> void:
	pass

func _on_flag_player_entered() -> void:
	if player.coins == total_coins:
		level_won.emit("")


func _on_player_died() -> void:
	level_lost.emit()


func _on_enemy_spawn_timer_timeout() -> void:
	enemy_spawn.progress_ratio = randf()

	var spawn_loc := enemy_spawn.global_position

	var loaded_enemy_scene := load(enemy_scene)
	var enemy : CharacterBody3D = loaded_enemy_scene.instantiate()

	add_child(enemy)
	enemy.global_position = spawn_loc

	enemy.died.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	enemies_killed += 1
	%KillsLabel.text = str(enemies_killed)
