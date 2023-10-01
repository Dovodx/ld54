extends Node

var player: Node3D
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
	player = get_node("/root/arena/player")
	
	barrierModel = get_node("/root/arena/barrier/barrier model")
	barrierCollider = get_node("/root/arena/barrier/collider")
	barrierShrinkSound = get_node("/root/arena/barrier/barrier shrink sound")
	barrierRestoreSound = get_node("/root/arena/barrier/barrier restore sound")
	
	$Timer.wait_time = 2.0
	call_deferred("spawn_enemy")

func _physics_process(delta):
	barrierModel.scale = barrierModel.scale.lerp(Vector3.ONE * barrierScale, delta * barrierSizeChangeRate)
	barrierCollider.scale = barrierCollider.scale.lerp(Vector3.ONE * barrierScale, delta * barrierSizeChangeRate)

func stop_spawning():
	$Timer.stop()

func increase_difficulty():
	if Global.score >= 500 and timesRateIncreased < 1:
		$Timer.wait_time = 1.7
		barrierScale = 8.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 1200 and timesRateIncreased < 2:
		$Timer.wait_time = 1.4
		barrierScale = 7.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 2500 and timesRateIncreased < 3:
		$Timer.wait_time = 1.2
		barrierScale = 6.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 4000 and timesRateIncreased < 4:
		$Timer.wait_time = 1.0
		barrierScale = 6.0
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 6000 and timesRateIncreased < 5:
		$Timer.wait_time = 0.85
		barrierScale = 5.0
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 8000 and timesRateIncreased < 6:
		$Timer.wait_time = 0.8
		barrierScale = 4.0
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 10000 and timesRateIncreased < 7:
		$Timer.wait_time = 0.75
		barrierScale = 3.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
		
	elif Global.score >= 12000 and timesRateIncreased < 8:
		player.level_up() #Level 1
		
		$Timer.wait_time = 0.85
		barrierScale = 9.5
		barrierRestoreSound.play()
		timesRateIncreased += 1
	elif Global.score >= 15000 and timesRateIncreased < 9:
		$Timer.wait_time = 0.65
		barrierScale = 8.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 17000 and timesRateIncreased < 10:
		$Timer.wait_time = 0.5
		barrierScale = 7.0
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 20000 and timesRateIncreased < 11:
		$Timer.wait_time = 0.45
		barrierScale = 5.0
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 23000 and timesRateIncreased < 12:
		$Timer.wait_time = 0.4
		barrierScale = 3.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 24000 and timesRateIncreased < 13:
		barrierScale = 3.0
		barrierShrinkSound.play()
		timesRateIncreased += 1
	
	elif Global.score >= 26000 and timesRateIncreased < 14:
		player.level_up() #Level 2
		
		$Timer.wait_time = 0.6
		barrierScale = 9.5
		barrierRestoreSound.play()
		timesRateIncreased += 1
	elif Global.score >= 28000 and timesRateIncreased < 15:
		$Timer.wait_time = 0.55
		barrierScale = 8.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 35000 and timesRateIncreased < 16:
		$Timer.wait_time = 0.5
		barrierScale = 7.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 40000 and timesRateIncreased < 17:
		$Timer.wait_time = 0.45
		barrierScale = 5.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	elif Global.score >= 48000 and timesRateIncreased < 18:
		$Timer.wait_time = 0.4
		barrierScale = 2.5
		barrierShrinkSound.play()
		timesRateIncreased += 1
	
	elif Global.score >= 50000 and timesRateIncreased < 19:
		player.level_up() #Level 3
		
		$Timer.wait_time = 0.35
		barrierScale = 9.5
		barrierRestoreSound.play()
		timesRateIncreased += 1
	elif Global.score > 50000 + (timesRateIncreased - 20) * 5000 and timesRateIncreased >= 19:
		timesRateIncreased += 1
		if timesRateIncreased == 22:
			player.level_up() #Level 4 (MAX)
		$Timer.wait_time = 3.0 / (timesRateIncreased - 10)

func _on_timer_timeout():
	call_deferred("spawn_enemy")

func spawn_enemy():
	var enemyToSpawn = enemy1.instantiate()
	var spawnPosAngle = randi_range(0, 360)
	get_tree().get_root().get_node("arena").add_child(enemyToSpawn)
	enemyToSpawn.global_position.x = sin(spawnPosAngle) * spawnRadiusDistance
	enemyToSpawn.global_position.z = cos(spawnPosAngle) * spawnRadiusDistance
	enemyToSpawn.initialize_arrays()
