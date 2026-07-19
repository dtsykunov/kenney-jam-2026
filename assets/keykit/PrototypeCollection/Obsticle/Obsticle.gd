extends Node3D

signal destroyed

@export var health := 20.0

@onready var model : Node3D = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	model.scale = model.scale.lerp(Vector3.ONE, delta * 10)


func hit(damage: float) -> void:
	health -= damage

	model.scale = Vector3(1.25, 0.75, 1.25)

	if health <= 0:
		destroyed.emit()
		model.queue_free()
