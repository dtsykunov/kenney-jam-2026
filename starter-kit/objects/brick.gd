extends StaticBody3D

@export var health := 2

@onready var bottom_detector = $BottomDetector
@onready var mesh = $Mesh
@onready var particles = $Particles

var exploded = false


func _ready():
	bottom_detector.body_entered.connect(_on_bottom_hit)

func _on_bottom_hit(body: Node3D) -> void:
	if body.is_in_group("player"):
		hit()

func hit() -> void:
	if exploded:
		return

	health -= 1

	Audio.play("res://starter-kit/sounds/break.ogg") # Play sound
	particles.restart()

	if health <= 0:
		explode()

func explode():
	exploded = true

	Audio.play("res://starter-kit/sounds/break.ogg") # Play sound

	particles.restart()

	mesh.hide()
	$CollisionShape3D.set_deferred("disabled", true)
	bottom_detector.set_deferred("monitoring", false)

	await get_tree().create_timer(1).timeout
	queue_free()
