extends Node

@export var arena: PackedScene

func _ready():
	$"options_menu/exit button".connect("pressed", close_options)

func close_options():
	$options_bg.visible = false
	$options_menu.visible = false

func _on_start_pressed():
	get_tree().change_scene_to_packed(arena)

func _on_options_pressed():
	$options_bg.visible = true
	$options_menu.visible = true

func _on_quit_pressed():
	get_tree().quit()
