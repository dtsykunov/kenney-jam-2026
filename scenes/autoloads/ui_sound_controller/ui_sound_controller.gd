class_name UISoundController
extends Node
## Controller for managing all UI sounds in a scene from one place.
##
## This node manages all of the UI sounds under the provided node path.
## When attached just below the root node of a scene tree, it will manage
## all of the UI sounds in that scene.

const MAX_DEPTH = 16

@export var root_path : NodePath = ^".."
## Continually check any new nodes added to the scene tree.
@export var persistent : bool = true :
	set(value):
		persistent = value
		_update_persistent_signals()

@export_group("Button Sounds")
@export var button_hovered : WwiseEvent
@export var button_focused : WwiseEvent
@export var button_pressed : WwiseEvent

@export_group("TabBar Sounds")
@export var tab_hovered : WwiseEvent
@export var tab_changed : WwiseEvent
@export var tab_selected : WwiseEvent

@export_group("Slider Sounds")
@export var slider_hovered : WwiseEvent
@export var slider_focused : WwiseEvent
@export var slider_drag_started : WwiseEvent
@export var slider_drag_ended : WwiseEvent

@export_group("LineEdit Sounds")
@export var line_hovered : WwiseEvent
@export var line_focused : WwiseEvent
@export var line_text_changed : WwiseEvent
@export var line_text_submitted : WwiseEvent
@export var line_text_change_rejected : WwiseEvent

@export_group("ItemList Sounds")
@export var item_list_selected : WwiseEvent
@export var item_list_activated : WwiseEvent

@export_group("Tree Sounds")
@export var tree_item_selected : WwiseEvent
@export var tree_item_activated : WwiseEvent
@export var tree_button_clicked : WwiseEvent

@onready var root_node : Node = get_node(root_path)

func _update_persistent_signals() -> void:
	if not is_inside_tree():
		return
	var tree_node = get_tree()
	if persistent:
		if not tree_node.node_added.is_connected(connect_ui_sounds):
			tree_node.node_added.connect(connect_ui_sounds)
	else:
		if tree_node.node_added.is_connected(connect_ui_sounds):
			tree_node.node_added.disconnect(connect_ui_sounds)

func _play_stream(stream_player : WwiseEvent) -> void:
	stream_player.post(self)

func _tab_event_play_stream(_tab_idx : int, stream_player : WwiseEvent) -> void:
	_play_stream(stream_player)

func _slider_drag_ended_play_stream(_value_changed : bool, stream_player : WwiseEvent) -> void:
	_play_stream(stream_player)

func _line_event_play_stream(_new_text : String, stream_player : WwiseEvent) -> void:
	_play_stream(stream_player)

func _item_list_play_stream(_index : int, stream_player : WwiseEvent) -> void:
	_play_stream(stream_player)

func _tree_button_clicked_play_stream(_tree_item : TreeItem, _column : int, _id : int, _mouse_button_index : int, stream_player : WwiseEvent) -> void:
	_play_stream(stream_player)

func _connect_stream_player(node : Node, stream_player : WwiseEvent, signal_name : StringName, callable : Callable) -> void:
	if stream_player != null and not node.is_connected(signal_name, callable.bind(stream_player)):
		node.connect(signal_name, callable.bind(stream_player))

func connect_ui_sounds(node: Node) -> void:
	if node is Button:
		_connect_stream_player(node, button_hovered, &"mouse_entered", _play_stream)
		_connect_stream_player(node, button_focused, &"focus_entered", _play_stream)
		_connect_stream_player(node, button_pressed, &"pressed", _play_stream)
	elif node is TabBar:
		_connect_stream_player(node, tab_hovered, &"tab_hovered", _tab_event_play_stream)
		_connect_stream_player(node, tab_changed, &"tab_changed", _tab_event_play_stream)
		_connect_stream_player(node, tab_selected, &"tab_selected", _tab_event_play_stream)
	elif node is Slider:
		_connect_stream_player(node, slider_hovered, &"mouse_entered", _play_stream)
		_connect_stream_player(node, slider_focused, &"focus_entered", _play_stream)
		_connect_stream_player(node, slider_drag_started, &"drag_started", _play_stream)
		_connect_stream_player(node, slider_drag_ended, &"drag_ended", _slider_drag_ended_play_stream)
	elif node is LineEdit:
		_connect_stream_player(node, line_hovered, &"mouse_entered", _play_stream)
		_connect_stream_player(node, line_focused, &"focus_entered", _play_stream)
		_connect_stream_player(node, line_text_changed, &"text_changed", _line_event_play_stream)
		_connect_stream_player(node, line_text_submitted, &"text_submitted", _line_event_play_stream)
		_connect_stream_player(node, line_text_change_rejected, &"text_change_rejected", _line_event_play_stream)
	elif node is ItemList:
		_connect_stream_player(node, item_list_activated, &"item_activated", _item_list_play_stream)
		_connect_stream_player(node, item_list_selected, &"item_selected", _item_list_play_stream)
	elif node is Tree:
		_connect_stream_player(node, tree_item_activated, &"item_activated", _play_stream)
		_connect_stream_player(node, tree_item_selected, &"item_selected", _play_stream)
		_connect_stream_player(node, tree_button_clicked, &"button_clicked", _tree_button_clicked_play_stream)

func _recursive_connect_ui_sounds(current_node: Node, current_depth : int = 0) -> void:
	if current_depth >= MAX_DEPTH:
		return
	for node in current_node.get_children():
		connect_ui_sounds(node)
		_recursive_connect_ui_sounds(node, current_depth + 1)

func _ready() -> void:
	_recursive_connect_ui_sounds(root_node)
	persistent = persistent

func _exit_tree() -> void:
	var tree_node = get_tree()
	if tree_node.node_added.is_connected(connect_ui_sounds):
		tree_node.node_added.disconnect(connect_ui_sounds)
