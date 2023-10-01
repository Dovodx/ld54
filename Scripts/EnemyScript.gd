extends RigidBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var deathSound: AudioStream

var health = 5
var speed = 9.0
var rotateSpeed = 2.0
var anim: AnimationPlayer
var attackDistance = 12.0
var player: Node3D
var model: Node3D

var arraysInitialized = false
var lastTwoPositions = [Vector3.ZERO, Vector3.ZERO]
var lastTwoRotations = [0, 0]
var lastPhysicsProcessTime = Time.get_ticks_usec()

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	anim = $AnimationPlayer
	model = $"bug eater"

func initialize_arrays():
	lastTwoPositions = [global_position, global_position]
	lastTwoRotations = [global_rotation.y, global_rotation.y]
	arraysInitialized = true

func _process(delta):
	if arraysInitialized:
		var timeDiff = (Time.get_ticks_usec() - lastPhysicsProcessTime) / 1000000.0
		var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
		model.global_position = lastTwoPositions[0].lerp(lastTwoPositions[1], lerpWeight)
		model.global_rotation.y = lerp(lastTwoRotations[0], lastTwoRotations[1], lerpWeight)

func is_on_floor():
	return $floorcheck.is_colliding()

func _integrate_forces(state):
#	print("scale: " + str(scale))
#	print("bug eater scale: " + str(model.scale))
#	print("bug eater pos: " + str(model.position))
#	print("bug eater rot: " + str(model.rotation_degrees))
#	print("model scale: " + str($"bug eater/enemy1 model".scale))
#	print("model pos: " + str($"bug eater/enemy1 model".position))
#	print("model rot: " + str($"bug eater/enemy1 model".rotation_degrees))
	if not is_on_floor():
		linear_velocity.y -= gravity * get_physics_process_delta_time()
	
	if player != null and !player.dead:
		var lookAt = transform.looking_at(player.global_position)
		var angleToRotate = lookAt.basis.get_euler().y - global_rotation.y
		if angleToRotate < -PI:
			angleToRotate = angleToRotate + 2.0 * PI
		elif angleToRotate > PI:
			angleToRotate = angleToRotate - 2.0 * PI
		angular_velocity.y = clamp(angleToRotate * rotateSpeed, -rotateSpeed, rotateSpeed)
		
		var speedMult = 1.0
		#Slow down to turn better when the player is behind
		if rad_to_deg(abs(angleToRotate)) > 110:
			speedMult = -0.5
		elif rad_to_deg(abs(angleToRotate)) > 90:
			speedMult = 0.2
		var movementVector = ((-transform.basis.z).normalized() * speed * speedMult)
		linear_velocity.x = movementVector.x
		linear_velocity.z = movementVector.z
		
		#Play attack anim if close enough to player
		if global_position.distance_squared_to(player.global_position) <= pow(attackDistance, 2):
			call_deferred("set_anim_state", true)
		else:
			call_deferred("set_anim_state", false)
	else:
		call_deferred("set_anim_state", false)
	
	lastTwoPositions[0] = lastTwoPositions[1]
	lastTwoPositions[1] = global_position
	
	lastTwoRotations[0] = lastTwoRotations[1]
	lastTwoRotations[1] = global_rotation.y
	if abs(lastTwoRotations[0] - lastTwoRotations[1]) > PI:
		lastTwoRotations[0] = lastTwoRotations[0] - sign(lastTwoRotations[0] - lastTwoRotations[1]) * 2.0 * PI
	lastPhysicsProcessTime = Time.get_ticks_usec()

func set_anim_state(playing):
	if playing:
		anim.play("claw_attack")
	else:
		anim.stop()

func take_damage(amount):
	health -= amount
	if health <= 0:
		call_deferred("die", amount)

#The damage of the killing blow affects the knockback force of the gibs
func die(damage):
	Global.set_score(Global.score + 100)
	
	var sound = AudioStreamPlayer3D.new()
	sound.stream = deathSound
	get_tree().get_root().get_node("arena").add_child(sound)
	sound.global_position = global_position
	sound.max_distance = 10000000.0
	sound.attenuation_filter_cutoff_hz = 20500
	sound.unit_size = 20
	sound.bus = "SFX"
	sound.connect("finished", queue_free)
	sound.play()
	
	var modelScale = $"bug eater/enemy1 model".scale
	for pieceToGib in $"bug eater/enemy1 model".get_children():
		if not pieceToGib is MeshInstance3D:
			if pieceToGib.name.begins_with("right claw"):
				pass
			elif pieceToGib.name.begins_with("left claw"):
				pass
			else:
				continue
		
		var gibPos = pieceToGib.global_position
		var modelRot = pieceToGib.global_rotation
		
		var gib = RigidBody3D.new()
		gib.set_collision_layer_value(1, false)
		gib.set_collision_layer_value(5, true)
		gib.set_collision_mask_value(4, true)
		gib.set_collision_mask_value(5, true)
		
		var colliderPath = ""
		if pieceToGib.name.begins_with("right claw"):
			colliderPath = "hurtbox/right claw collider"
		elif pieceToGib.name.begins_with("left claw"):
			colliderPath = "hurtbox/left claw collider"
		else:
			colliderPath = "hurtbox/" + pieceToGib.name + " collider"
		var gibCollider = get_node(colliderPath)
		
		get_tree().get_root().get_node("arena").add_child(gib)
		gib.global_position = gibPos
		
		pieceToGib.get_parent().remove_child(pieceToGib)
		gib.add_child(pieceToGib)
		pieceToGib.position = Vector3.ZERO
		pieceToGib.global_rotation = modelRot
		pieceToGib.scale = modelScale
		
		gibCollider.get_parent().remove_child(gibCollider)
		gib.add_child(gibCollider)
		gibCollider.position = Vector3.ZERO
		gibCollider.global_rotation = modelRot
		
		var cleanupTimer = Timer.new()
		cleanupTimer.wait_time = Global.gib_lifetime
		cleanupTimer.connect("timeout", gib.queue_free)
		gib.add_child(cleanupTimer)
		cleanupTimer.start()
		
		gib.inertia = Vector3.ONE
		gib.apply_impulse((gib.global_position - player.global_position).normalized() * 5.0 * damage)
		var gibTorque = 1.2 * damage
		gib.apply_torque_impulse(Vector3(randf_range(-gibTorque, gibTorque),
			randf_range(-gibTorque, gibTorque),
			randf_range(-gibTorque, gibTorque)))
		
	queue_free()
