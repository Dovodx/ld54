extends RigidBody3D

var maxHealth = 100.0
var health = 100.0
var dead = false
var level = 0

var combatMusicStart: AudioStreamPlayer
var combatMusicLoop: AudioStreamPlayer

var healthbar: ProgressBar
var scoreText: RichTextLabel
var radar: Control
var levelUpText: RichTextLabel
var deathScoreText: RichTextLabel

var pauseMenu: Control
var pauseBg: Control
var optionsMenu: Control

var speed = 14.0
var jumpForce = 8
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var animationPlayer := $AnimationPlayer

var lastTwoPositions = [Vector3.ZERO, Vector3.ZERO]
var lastPhysicsProcessTime = Time.get_ticks_usec()

#Pivot point is used for the camera in case of fancy recoil effects, screenshake, etc.
@onready var campivot := $neck/campivot
@onready var neck := $neck

func _ready():
	dead = false
	level = 0
	freeze = false
	axis_lock_linear_x = false
	axis_lock_linear_y = false
	axis_lock_linear_z = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	healthbar = get_node("/root/arena/HUD/in-game/healthbar")
	healthbar.max_value = maxHealth
	healthbar.value = health
	
	scoreText = get_node("/root/arena/HUD/in-game/score")
	radar = get_node("/root/arena/HUD/in-game/radar")
	levelUpText = get_node("/root/arena/HUD/in-game/level up text")
	deathScoreText = get_node("/root/arena/HUD/dead/score")
	
	pauseMenu = get_node("/root/arena/HUD/pause_menu")
	pauseBg = get_node("/root/arena/HUD/pause_bg")
	optionsMenu = get_node("/root/arena/HUD/options_menu")
	
	pauseMenu.visible = false
	pauseBg.visible = false
	optionsMenu.visible = false
	
	pauseMenu.get_node("resume").connect("pressed", unpauseGame)
	pauseMenu.get_node("options").connect("pressed", openOptionsMenu)
	pauseMenu.get_node("quit").connect("pressed", _on_quit_pressed)
	optionsMenu.get_node("exit button").connect("pressed", closeOptionsMenu)
	
	get_node("/root/arena/HUD/in-game").visible = true
	levelUpText.visible = false
	get_node("/root/arena/HUD/dead").visible = false
	updateScoreText()
	
	get_node("/root/arena/HUD/dead/retry").connect("pressed", _on_retry_pressed)
	get_node("/root/arena/HUD/dead/quit").connect("pressed", _on_quit_pressed)
	
	combatMusicStart = get_node("/root/arena/combat music start")
	combatMusicLoop = get_node("/root/arena/combat music loop")
	combatMusicStart.connect("finished", combatMusicLoop.play)
	combatMusicStart.play()
	
	lastTwoPositions = [campivot.global_position, campivot.global_position]

func updateScoreText():
	scoreText.text = "Score: " + str(Global.score)

func pauseGame():
	pauseBg.visible = true
	pauseMenu.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func unpauseGame():
	pauseBg.visible = false
	optionsMenu.visible = false
	pauseMenu.visible = false
	get_tree().paused = false
	lastTwoPositions = [global_position, global_position]
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func openOptionsMenu():
	optionsMenu.visible = true
	pauseMenu.visible = false

func closeOptionsMenu():
	optionsMenu.visible = false
	pauseMenu.visible = true

func _unhandled_input(event):
	if dead:
		return
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pauseGame()
	elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * 0.001 * Global.mouse_sensitivity)
			campivot.rotate_x(-event.relative.y * 0.001 * Global.mouse_sensitivity)
			campivot.rotation.x = clamp(campivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _process(delta):
	if dead:
		return
	var timeDiff = (Time.get_ticks_usec() - lastPhysicsProcessTime) / 1000000.0
	var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
	campivot.global_position = lastTwoPositions[0].lerp(global_position, lerpWeight)
	radar.queue_redraw()

func is_on_floor():
	return $floorcheck.is_colliding()

func _integrate_forces(state):
	if dead:
		return
	updateScoreText()
	
	if not is_on_floor():
		linear_velocity.y -= gravity * get_physics_process_delta_time()
	
	#Disable all 1-frame colliders
	#TODO: possibly change to use projectiles instead of big hitscan
	#TODO: make damage dependent on range?
	call_deferred("set_collider_disabled", $"neck/campivot/Camera3D/shotgun/shotgun area/collider", true)
	
	if Input.is_action_just_pressed("fire") && $"neck/campivot/Camera3D/shotgun/cooldown timer".is_stopped():
		#TODO: logic for which gun you have selected (if there's time for more than one)
		call_deferred("set_collider_disabled", $"neck/campivot/Camera3D/shotgun/shotgun area/collider", false)
		$"neck/campivot/Camera3D/shotgun/fire sound".play()
		$"neck/campivot/Camera3D/shotgun/particles".restart()
		animationPlayer.stop()
		animationPlayer.play("shotgun_fire")
		$"neck/campivot/Camera3D/shotgun/cooldown timer".start()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		linear_velocity.y = jumpForce

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (neck.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		linear_velocity.x = direction.x * speed
		linear_velocity.z = direction.z * speed
	else:
		linear_velocity.x = move_toward(linear_velocity.x, 0, speed)
		linear_velocity.z = move_toward(linear_velocity.z, 0, speed)
	
	lastTwoPositions[0] = lastTwoPositions[1]
	lastTwoPositions[1] = campivot.global_position
	lastPhysicsProcessTime = Time.get_ticks_usec()

func set_collider_disabled(node, disabled):
	node.disabled = disabled

func take_damage(amount):
	if dead:
		return
	health -= amount
	healthbar.value = health
	$"hurt sound".play()
	if health <= 0:
		dead = true
		call_deferred("die")

func die():
	combatMusicStart.stop()
	combatMusicLoop.stop()
	$"death sound".play()
	freeze = true
	linear_velocity = Vector3.ZERO
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("/root/arena/HUD/in-game").visible = false
	get_node("/root/arena/HUD/dead").visible = true
	deathScoreText.text = "[center]Score: " + str(Global.score)
	Global.set_score(0)

func level_up():
	level += 1
	health += 10
	healthbar.value = health
	$"level up".play()
	
	match level:
		1:
			levelUpText.text = "[center]Level Up!\nFire rate increased"
			$"neck/campivot/Camera3D/shotgun/cooldown timer".wait_time = 0.6
		2:
			levelUpText.text = "[center]Level Up!\nJump height increased"
			jumpForce = 12.0
		3:
			levelUpText.text = "[center]Level Up!\nSpeed increased"
			speed = 19.0
		4:
			levelUpText.text = "[center]Max Level!\nFire rate increased"
			$"neck/campivot/Camera3D/shotgun/cooldown timer".wait_time = 0.4
	
	levelUpText.visible = true
	$"level up text timer".start()

func _on_retry_pressed():
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_level_up_text_timer_timeout():
	levelUpText.visible = false
