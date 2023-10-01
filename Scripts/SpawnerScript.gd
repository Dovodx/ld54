extends Node

var enemy1 = preload("res://Prefabs/enemy.tscn")
var spawnRadiusDistance = 60.0
var timesRateIncreased = 0

var barrierScale = 9.5
var barrierModel: Node3D
var barrierCollider: Node3D

func _ready():
	barrierModel = get_tree().get_root().get_node("arena/barrier/barrier model")
	barrierCollider = get_tree().get_root().get_node("arena/barrier/collider")
	call_deferred("spawn_enemy")

func _physics_process(delta):
	barrierModel.scale = barrierModel.scale.lerp(Vector3.ONE * barrierScale, delta * 0.5)
	barrierCollider.scale = barrierCollider.scale.lerp(Vector3.ONE * barrierScale, delta * 0.5)

func _on_timer_timeout():
	call_deferred("spawn_enemy")
	if Global.score > 500 and timesRateIncreased < 1:
		$Timer.wait_time *= 0.8
		barrierScale = 8.5
		timesRateIncreased += 1
	elif Global.score > 1200 and timesRateIncreased < 2:
		$Timer.wait_time *= 0.8
		barrierScale = 7.5
		timesRateIncreased += 1
	elif Global.score > 2500 and timesRateIncreased < 3:
		$Timer.wait_time *= 0.8
		barrierScale = 6.5
		timesRateIncreased += 1
	elif Global.score > 4000 and timesRateIncreased < 4:
		$Timer.wait_time *= 0.8
		barrierScale = 6.0
		timesRateIncreased += 1
	elif Global.score > 6000 and timesRateIncreased < 5:
		$Timer.wait_time *= 0.8
		barrierScale = 5.0
		timesRateIncreased += 1
	elif Global.score > 8000 and timesRateIncreased < 6:
		$Timer.wait_time *= 0.7
		barrierScale = 4.0
		timesRateIncreased += 1
	elif Global.score > 10000 and timesRateIncreased < 7:
		$Timer.wait_time *= 0.9
		barrierScale = 3.5
		timesRateIncreased += 1

func spawn_enemy():
	var enemyToSpawn = enemy1.instantiate()
	var spawnPosAngle = randi_range(0, 360)
	get_tree().get_root().get_node("arena").add_child(enemyToSpawn)
	enemyToSpawn.global_position.x = sin(spawnPosAngle) * spawnRadiusDistance
	enemyToSpawn.global_position.z = cos(spawnPosAngle) * spawnRadiusDistance
	enemyToSpawn.initialize_arrays()
