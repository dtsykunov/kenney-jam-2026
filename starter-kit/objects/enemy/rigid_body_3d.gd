extends RigidBody3D

signal died

enum State {
	IDLE,
	FOLLOWING,
	ATTACKING,
	KNOCKED,
}

@export var movement_speed: float = 4.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var hurtbox: Area3D = %HurtBox

@onready var knocked_timer : Timer = %KnockedTimer

@onready var down_ray : RayCast3D = %DownRay
@onready var anim_player : AnimationPlayer = $AnimationPlayer

var state := State.FOLLOWING
@export var health := 10.0
var attack_damage := 3.0

var is_player_inside_hurtbox := false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if state == State.IDLE:
		state = State.FOLLOWING
	elif state == State.FOLLOWING:
		pass

func _integrate_forces(physics_state: PhysicsDirectBodyState3D) -> void:
	if state == State.FOLLOWING:
		_integrate_forces_following(physics_state)


func _integrate_forces_following(physics_state: PhysicsDirectBodyState3D) -> void:
	if not down_ray.is_colliding():
		return

	if NavigationServer3D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return

	set_movement_target(player.global_position)
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var direction := global_position.direction_to(next_path_position)

	if not nav_agent.is_target_reached():
		linear_velocity = direction * movement_speed

	look_in_player_direction()


func set_movement_target(movement_target: Vector3):
	nav_agent.set_target_position(movement_target)

func look_in_player_direction() -> void:
	var player_direction := global_position.direction_to(player.global_position)
	player_direction.y = 0
	look_at(global_position + player_direction)

func hit(damage: float) -> void:
	state = State.KNOCKED
	anim_player.play("RESET")
	anim_player.play("knocked")

	health -= damage
	if health <= 0.0:
		died.emit()
		queue_free()

	# up and away vector
	var away_vector := Vector3.UP + (global_position - player.global_position).normalized()
	away_vector *= damage
	away_vector -= linear_velocity # correct for movement
	apply_central_impulse(away_vector)
	knocked_timer.start()

	# rotate
	look_in_player_direction()


func _on_knocked_back_timer_timeout() -> void:
	state = State.IDLE

func _on_hurt_box_body_entered(body: Node3D) -> void:
	if state in [State.IDLE, State.FOLLOWING] and body.is_in_group("player"):
		state = State.ATTACKING
		is_player_inside_hurtbox = true
		anim_player.play("attack")

func _on_hurt_box_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		is_player_inside_hurtbox = false

func attack() -> void:
	if is_player_inside_hurtbox:
		player.hit(attack_damage)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "attack":
		return

	if is_player_inside_hurtbox:
		anim_player.play("attack")
	else:
		state = State.IDLE


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if state == State.FOLLOWING:
		linear_velocity = safe_velocity
