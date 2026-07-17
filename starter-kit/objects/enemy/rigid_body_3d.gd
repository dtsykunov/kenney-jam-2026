extends RigidBody3D

enum State {
	IDLE,
	FOLLOW,
	ATTACK,
	KNOCKED_BACK,
}

@export var speed: float = 5.0

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

@onready var player : CharacterBody3D = %Player

var state := State.FOLLOW

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	pass
	# nav_agent.target_position = player.global_position

	# var next_position := nav_agent.get_next_path_position()
	# var direction := global_position.direction_to(next_position)
	# direction.y = 0

	# state.linear_velocity = direction * speed

func hit() -> void:
	state = State.KNOCKED_BACK

	var fly_direction := (global_position - player.global_position).normalized() # away from player
	var hit_force := 4.0
	apply_central_impulse(fly_direction * hit_force + Vector3.UP * hit_force)
