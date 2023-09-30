extends RigidBody3D

var maxHealth = 100.0
var health = 100.0
@export var healthbar: ProgressBar

const SPEED = 14.0
const JUMP_VELOCITY = 8
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var animationPlayer := $AnimationPlayer

#var arraysInitialized = false
var lastTwoPositions = [Vector3.ZERO, Vector3.ZERO]
var lastPhysicsProcessTime = Time.get_ticks_usec()

#Pivot point is used for the camera in case of fancy recoil effects, screenshake, etc.
@onready var campivot := $neck/campivot
@onready var neck := $neck

func _ready():
	healthbar = get_node("//root/arena/HUD/healthbar")
	healthbar.max_value = maxHealth
	healthbar.value = health
	lastTwoPositions = [campivot.global_position, campivot.global_position]

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * 0.001)
			campivot.rotate_x(-event.relative.y * 0.001)
			campivot.rotation.x = clamp(campivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _process(delta):
	var timeDiff = (Time.get_ticks_usec() - lastPhysicsProcessTime) / 1000000.0
	var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
	campivot.global_position = lastTwoPositions[0].lerp(lastTwoPositions[1], lerpWeight)

func is_on_floor():
	return $floorcheck.is_colliding()

func _integrate_forces(state):
	if not is_on_floor():
		linear_velocity.y -= gravity * get_physics_process_delta_time()
	
	#Disable all 1-frame colliders
	#TODO: possibly change to use projectiles instead of big hitscan
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
		linear_velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (neck.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		linear_velocity.x = direction.x * SPEED
		linear_velocity.z = direction.z * SPEED
	else:
		linear_velocity.x = move_toward(linear_velocity.x, 0, SPEED)
		linear_velocity.z = move_toward(linear_velocity.z, 0, SPEED)
	
	lastTwoPositions[0] = lastTwoPositions[1]
	lastTwoPositions[1] = campivot.global_position
	lastPhysicsProcessTime = Time.get_ticks_usec()

func take_damage(amount):
	health -= amount
	healthbar.value = health

func set_collider_disabled(node, disabled):
	node.disabled = disabled
