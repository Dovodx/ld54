extends Control

var hudColor = Color.from_string("c71818", Color.RED)
var barrierColor = Color.AQUA
var playerNeck: Node3D
var barrier: Node3D
var maxRange = 60.0

func _ready():
	playerNeck = get_node("/root/arena/player/neck")
	barrier = get_node("/root/arena/barrier/barrier model")

func _draw():
	#TODO: draw barrier
	draw_arc(Vector2(60, 60), 59, 0, 360, 64, hudColor, 1.0)
	draw_rect(Rect2(60, 60, 2, 2), hudColor)
	
	var barrierPos = Vector2(playerNeck.global_position.x - barrier.global_position.x,
			playerNeck.global_position.z - barrier.global_position.z)
	barrierPos = barrierPos.rotated(playerNeck.global_rotation.y)
	barrierPos.x = 60 - barrierPos.x
	barrierPos.y = 60 - barrierPos.y
	draw_arc(barrierPos, barrier.scale.x * 4.8, 0, 360, 64, barrierColor, 1.0)
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if playerNeck.global_position.distance_squared_to(enemy.global_position) > pow(maxRange, 2):
			continue
		var blipPos = Vector2(playerNeck.global_position.x - enemy.global_position.x,
			playerNeck.global_position.z - enemy.global_position.z)
		blipPos = blipPos.rotated(playerNeck.global_rotation.y)
		draw_rect(Rect2(60 - blipPos.x, 60 - blipPos.y,
			4.0, 4.0), hudColor)
