extends Node

var score = 0
var mouse_sensitivity = 1.0
var gib_lifetime = 5.0

func set_score(value):
	score = value
	var spawner = get_node("/root/arena/spawner")
	if spawner != null:
		spawner.increase_difficulty()
	else:
		print("Error: couldn't find spawner")

func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
