extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 7
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera := $neck/Camera3D
@onready var neck := $neck

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * 0.001)
			camera.rotate_x(-event.relative.y * 0.001)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#Disable all 1-frame colliders
	$"neck/Camera3D/shotgun/shotgun area/collider".disabled = true
	
	#TODO: timer to limit firerate
	if Input.is_action_just_pressed("fire") && $"neck/Camera3D/shotgun/cooldown timer".is_stopped():
		#TODO: logic for which gun you have selected (if there's time for more than one)
		$"neck/Camera3D/shotgun/shotgun area/collider".disabled = false
		$"neck/Camera3D/shotgun/fire sound".play()
		$"neck/Camera3D/shotgun/particles".restart()
		$"neck/Camera3D/shotgun/cooldown timer".start()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (neck.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
