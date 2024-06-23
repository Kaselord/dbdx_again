@tool
extends EditorPlugin

var cheese_plugin_panel : Control


func _enter_tree():
	cheese_plugin_panel = preload("res://addons/cheesegodot/scenes/cheese_panel.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, cheese_plugin_panel)


func _exit_tree():
	remove_control_from_docks(cheese_plugin_panel)
