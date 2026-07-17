extends RigidBody3D

@export var speed: float = 30.0

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

@onready var player : CharacterBody3D = %Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
