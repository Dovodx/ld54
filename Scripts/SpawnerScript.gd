extends Node

var enemy1 = preload("res://Prefabs/enemy.tscn")
var spawnRadiusDistance = 70.0
var timesRateIncreased = 0

var barrierScale = 9.5
var barrierSizeChangeRate = 1.0
var barrierModel: Node3D
var barrierCollider: Node3D
var barrierShrinkSound: AudioStreamPlayer3D
var barrierRestoreSound: AudioStreamPlayer3D

func _ready():
	barrierModel = get_node("/root/arena/barrier/barrier model")
	barrierCollider = get_node("/root/arena/barrier/collider")
	barrierShrinkSound = get_node("/root/arena/barrier/barrier shrink sound")
	barrierRestoreSound = get_node("/root/arena/barrier/barrier restore sound")
	
	call_deferred("spawn_enemy")

func _physics_process(delta):
	barrierModel.scale = barrierModel.scale.lerp(Vector3.ONE * barrierScale, delta * barrierSizeChangeRate)
	barrierCollider.scale = barrierCollider.scale.lerp(Vector3.ONE * barrierScale, delta * barrierSizeChangeRate)

func increase_difficulty():
	print("increasing difficulty")
	if Global.score >= 500 and timesRateIncreased < 1:
		$Timer.wait_time = 2.0
		barrierScale = 8.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 1200 and timesRateIncreased < 2:
		$Timer.wait_time = 1.8
		barrierScale = 7.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 2500 and timesRateIncreased < 3:
		$Timer.wait_time = 1.5
		barrierScale = 6.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 4000 and timesRateIncreased < 4:
		$Timer.wait_time = 1.2
		barrierScale = 6.0
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 6000 and timesRateIncreased < 5:
		$Timer.wait_time = 1
		barrierScale = 5.0
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 8000 and timesRateIncreased < 6:
		$Timer.wait_time = 0.9
		barrierScale = 4.0
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 10000 and timesRateIncreased < 7:
		$Timer.wait_time = 0.8
		barrierScale = 3.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 12000 and timesRateIncreased < 8:
		#level up!
		barrierScale = 9.5
		barrierRestoreSound.play()
		timesRateIncreased += 1
	elif Global.score >= 15000 and timesRateIncreased < 9:
		$Timer.wait_time = 0.75
		barrierScale = 8.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
		#boss????

func _on_timer_timeout():
	call_deferred("spawn_enemy")

func spawn_enemy():
	var enemyToSpawn = enemy1.instantiate()
	var spawnPosAngle = randi_range(0, 360)
	get_tree().get_root().get_node("arena").add_child(enemyToSpawn)
	enemyToSpawn.global_position.x = sin(spawnPosAngle) * spawnRadiusDistance
	enemyToSpawn.global_position.z = cos(spawnPosAngle) * spawnRadiusDistance
	enemyToSpawn.initialize_arrays()
