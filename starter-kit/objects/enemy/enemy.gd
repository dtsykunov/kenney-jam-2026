extends CharacterBody3D

signal died

enum State {
	IDLE,
	FOLLOW,
	ATTACK,
	KNOCKED_BACK,
}

@export var speed := 5.0
@export var health := 10.0

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var state := State.FOLLOW

var knockback : Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:

	if state == State.IDLE:
		pass
	elif state == State.FOLLOW:
		_physics_process_follow(delta)
	elif state == State.ATTACK:
		pass
	elif state == State.KNOCKED_BACK:
		_physics_process_knocked_back(delta)

	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func _physics_process_follow(_delta: float) -> void:
	if not is_on_floor():
		return

	nav_agent.target_position = player.global_position
	var next_position := nav_agent.get_next_path_position()
	var direction := global_position.direction_to(next_position)

	if not nav_agent.is_navigation_finished():
		velocity = direction * speed

	direction.y = 0 # kill pitch
	look_at(global_position + direction)

func _physics_process_knocked_back(delta: float) -> void:
	pass

func hit(damage: float) -> void:
	state = State.KNOCKED_BACK

	health -= damage
	if health <= 0:
		explode()
		return

	$KnockbackTimer.start()

	var fly_direction := (global_position - player.global_position).normalized()
	var hit_force := 5.0

	velocity = fly_direction * hit_force


func explode() -> void:
	died.emit()
	queue_free()

func _on_knockback_timer_timeout() -> void:
	state = State.FOLLOW
