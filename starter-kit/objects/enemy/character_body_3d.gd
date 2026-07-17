extends CharacterBody3D


@export var speed := 5.0

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

@onready var player : CharacterBody3D = %Player

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	nav_agent.target_position = player.global_position

	var next_position := nav_agent.get_next_path_position()
	var direction := global_position.direction_to(next_position)
	velocity = direction * speed

	direction.y = 0 # kill pitch
	look_at(global_position + direction)

	move_and_slide()


# hit_point - global space point where this body was hit
func hit() -> void:

	var fly_direction := (Vector3.UP + Vector3.BACK).normalized()
	var hit_force := 3.0

	velocity = basis * fly_direction * hit_force



