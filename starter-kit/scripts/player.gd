extends CharacterBody3D

signal coin_collected
signal died
signal damaged(health_left: float)
signal scaled(scale_factor: float)

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 350.0
@export var jump_strength = 7

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true

var coins := 0
var dead := false
var hit_damage := 3.0
var health := 10.0
var scale_factor : float = 1.0:
	set(value):
		scale_factor = value
		scale = Vector3.ONE * scale_factor

@onready var particles_trail = $ParticlesTrail
@onready var sound_footsteps = $SoundFootsteps
@onready var model = $BarbarianLegs
@onready var animation = $BarbarianLegs/AnimationPlayer
@onready var modelBody = $Barbarian
@onready var animationBody = $Barbarian/AnimationPlayer

@onready var hurtbox := %HurtBox

@export var is_attacking := false

# Functions

func _physics_process(delta):
	if dead:
		return

	# Handle functions

	handle_controls(delta)
	handle_gravity(delta)

	handle_effects(delta)

	# Movement

	var applied_velocity: Vector3

	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity

	velocity = applied_velocity
	move_and_slide()

	# Rotation

	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()

	model.rotation.y = lerp_angle(model.rotation.y, rotation_direction, delta * 10)


	# Falling/respawning

	if position.y < -10:
		die()
		return

	# Animation for scale (jumping and landing)

	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)

	# Animation when landing

	if is_on_floor() and gravity > 2 and !previously_floored:
		model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://starter-kit/sounds/land.ogg")

	previously_floored = is_on_floor()

# Handle animation(s)

func handle_effects(delta):

	particles_trail.emitting = false
	sound_footsteps.stream_paused = true

	if is_on_floor():
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		var speed_factor = horizontal_velocity.length() / movement_speed / delta
		if speed_factor > 0.05:
			if animation.current_animation != "walk":
				animation.play("walk", 0.1)

			if speed_factor > 0.3:
				sound_footsteps.stream_paused = false
				sound_footsteps.pitch_scale = speed_factor

			if speed_factor > 0.75:
				particles_trail.emitting = true

		elif animation.current_animation != "idle":
			animation.play("idle", 0.1)

		if animation.current_animation == "walk":
			animation.speed_scale = speed_factor
		else:
			animation.speed_scale = 1.0

	elif animation.current_animation != "jump":
		animation.play("jump", 0.1)

# Handle movement input

func handle_controls(delta):

	# Movement

	var input := Vector3.ZERO

	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")

	input = input.rotated(Vector3.UP, view.rotation.y)

	if input.length() > 1:
		input = input.normalized()

	movement_velocity = input * movement_speed * delta

	# Jumping

	if Input.is_action_just_pressed("jump"):

		if jump_single or jump_double:
			jump()


	# Attack

	if Input.is_action_just_pressed("attack"):
		animationBody.play("static")
		animationBody.play("attack")

# Handle gravity

func handle_gravity(delta):

	gravity += 25 * delta

	if gravity > 0 and is_on_floor():

		jump_single = true
		gravity = 0

# Jumping

func jump():

	Audio.play("res://starter-kit/sounds/jump.ogg")

	gravity = -jump_strength

	model.scale = Vector3(0.5, 1.5, 0.5)

	if jump_single:
		jump_single = false;
		jump_double = true;
	else:
		jump_double = false;

# Collecting coins

func collect_coin():

	coins += 1

	coin_collected.emit(coins)

func _on_mouse_area_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if dead:
		return
	if event is InputEventMouseMotion:
		var dir := event_position - global_position
		dir.y = 0
		modelBody.look_at(global_position - dir)

func hit(damage: float) -> void:
	health -= damage
	damaged.emit(health)

	if health <= 0.0:
		die()

func _on_enemy_died() -> void:
	scale_factor += 0.1
	scaled.emit(scale_factor)


func _on_legs_animation_player_started(anim_name: StringName) -> void:
	if animationBody.current_animation == "attack":
		return
	animationBody.play(animation.current_animation)
	animationBody.seek(animation.current_animation_position, true)

func _on_body_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "attack":
		return
	animationBody.play(animation.current_animation)
	animationBody.seek(animation.current_animation_position, true)


func _on_hurt_box_body_entered(body: Node3D) -> void:
	if is_attacking and body.is_in_group("enemy"):
		body.hit(hit_damage)

func die() -> void:
	if dead:
		return
	dead = true
	animation.play("die")
	died.emit()
