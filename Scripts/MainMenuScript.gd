extends Node

@export var arena: PackedScene

func _on_start_pressed():
	get_tree().change_scene_to_packed(arena)

func _on_options_pressed():
	#TODO: options menu
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()
