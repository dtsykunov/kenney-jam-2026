extends Control
## Scene for adjusting Wwise bus volumes through RTPCs.
## Unlike the native [AudioServer] Audio tab, Wwise has no API to enumerate
## buses at runtime, so controls are configured manually via [member rtpc_controls]
## rather than discovered. Each RTPC must be authored in Wwise and mapped to a
## bus's Voice Volume; until matching SoundBanks are generated and loaded,
## [method Wwise.set_rtpc_value] calls below succeed but have no audible effect.

const WWISE_SECTION := AppSettings.CUSTOM_SECTION

@export var audio_control_scene : PackedScene
@export var rtpc_controls : Array[WwiseRTPCControlConfig]

@onready var audio_control_container = %AudioControlContainer

func _apply_rtpc(rtpc_name : String, value : float) -> void:
	if not Wwise.is_initialized():
		return
	Wwise.set_rtpc_value(rtpc_name, value, null)

func _on_control_changed(value : float, rtpc_name : String) -> void:
	_apply_rtpc(rtpc_name, value)

func _configure_range(control : OptionControl, config : WwiseRTPCControlConfig) -> void:
	for child in control.get_children():
		if child is Range:
			child.min_value = config.min_value
			child.max_value = config.max_value
			child.step = config.step

func _add_rtpc_control(config : WwiseRTPCControlConfig) -> void:
	if audio_control_scene == null or config.rtpc_name.is_empty():
		return
	var control = audio_control_scene.instantiate()
	audio_control_container.call_deferred("add_child", control)
	if control is OptionControl:
		control.lock_config_names = true
		control.section = WWISE_SECTION
		control.key = config.rtpc_name
		control.option_name = config.display_name
		control.default_value = config.default_value
		_configure_range(control, config)
		var stored_value : float = PlayerConfig.get_config(WWISE_SECTION, config.rtpc_name, config.default_value)
		control.value = stored_value
		control.connect("setting_changed", _on_control_changed.bind(config.rtpc_name))
		_apply_rtpc(config.rtpc_name, stored_value)

func _ready() -> void:
	for config in rtpc_controls:
		_add_rtpc_control(config)
