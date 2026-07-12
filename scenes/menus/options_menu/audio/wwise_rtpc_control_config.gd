class_name WwiseRTPCControlConfig
extends Resource
## Describes a single Wwise RTPC exposed as a slider in [WwiseAudioOptionsMenu].
## The [member rtpc_name] must exactly match a Game Parameter authored in the
## Wwise project (case-sensitive) that has been mapped to a bus's Voice Volume.

## Text displayed to the user.
@export var display_name : String
## Exact name of the RTPC (Game Parameter) as authored in Wwise.
@export var rtpc_name : String
@export var default_value : float = 1.0
@export var min_value : float = 0.0
@export var max_value : float = 1.0
@export var step : float = 0.05
