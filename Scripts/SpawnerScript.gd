extends Node

var enemy1 = preload("res://Prefabs/enemy.tscn")
var spawnRadiusDistance = 60.0

func _on_timer_timeout():
	call_deferred("spawn_enemy")

func spawn_enemy():
	var enemyToSpawn = enemy1.instantiate()
	var spawnPosAngle = randi_range(0, 360)
	get_tree().get_root().add_child(enemyToSpawn)
	enemyToSpawn.global_position.x = sin(spawnPosAngle) * spawnRadiusDistance
	enemyToSpawn.global_position.z = cos(spawnPosAngle) * spawnRadiusDistance
