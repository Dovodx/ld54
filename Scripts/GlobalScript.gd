extends Node

var score = 0
#TODO: mouse sensitivity setting

func set_score(value):
	score = value
	var spawner = get_node("/root/arena/spawner")
	if spawner != null:
		spawner.increase_difficulty()
	else:
		print("Error: couldn't find spawner")
