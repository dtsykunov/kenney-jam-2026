@tool
extends OverlaidWindow

signal accepted

@onready var slider: HSlider = %ScaleCardSlider
@onready var timer: Timer = %ScaleCardTimer

func _ready() -> void:
	timer.start()
	slider.max_value = timer.wait_time

func _process(_delta: float) -> void:
	if timer.time_left >= 0.0:
		slider.value = timer.time_left

func open():
	timer.start()
	super.show()


func _on_accept_button_pressed() -> void:
	accepted.emit()
	close()


func _on_timer_timeout() -> void:
	close()
