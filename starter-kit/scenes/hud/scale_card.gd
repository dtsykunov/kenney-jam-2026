extends PanelContainer


@onready var scale_card_slider :Control = $VBoxContainer/ScaleCardSlider
@onready var scale_card_timer : Timer = $ScaleCardTimer

func _process(_delta: float) -> void:
	scale_card_slider.value = scale_card_timer.time_left

