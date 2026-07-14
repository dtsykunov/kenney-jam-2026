extends Node3D

signal level_lost
signal level_won(level_path : String)

@onready var total_coins := len(get_tree().get_nodes_in_group("coin"))
@onready var player := %Player

func _ready() -> void:
	%TotalCoins.text = str(total_coins)


func _on_flag_player_entered() -> void:
	if player.coins == total_coins:
		level_won.emit("")


func _on_player_died() -> void:
	level_lost.emit()
