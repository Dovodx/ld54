extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var deathSound: AudioStream

var health = 5
var speed = 9.0
var rotateSpeed = 2.0
var player: Node3D

var arraysInitialized = false
var lastTwoPositions = [Vector3.ZERO, Vector3.ZERO]
var lastTwoRotations = [0, 0]
var lastPhysicsProcessTime = Time.get_ticks_usec()

#TODO: attack animation

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]

func initialize_arrays():
	lastTwoPositions = [global_position, global_position]
	lastTwoRotations = [global_rotation.y, global_rotation.y]
	arraysInitialized = true

func _process(delta):
	if arraysInitialized:
		var timeDiff = (Time.get_ticks_usec() - lastPhysicsProcessTime) / 1000000.0
		var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
		global_position = lastTwoPositions[0].lerp(lastTwoPositions[1], lerpWeight)
		global_rotation.y = lerp(lastTwoRotations[0], lastTwoRotations[1], lerpWeight)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if player != null:
		var lookAt = transform.looking_at(player.global_position)
		var angleToRotate = lookAt.basis.get_euler().y - global_rotation.y
		if angleToRotate < -PI:
			angleToRotate = angleToRotate + 2.0 * PI
		elif angleToRotate > PI:
			angleToRotate = angleToRotate - 2.0 * PI
		global_rotation.y += angleToRotate * rotateSpeed * delta
		
		var movementVector = ((-transform.basis.z).normalized() * speed)
		velocity.x = movementVector.x
		velocity.z = movementVector.z

	move_and_slide()
	
	lastTwoPositions[0] = lastTwoPositions[1]
	lastTwoPositions[1] = global_position
	
	lastTwoRotations[0] = lastTwoRotations[1]
	lastTwoRotations[1] = global_rotation.y
	if abs(lastTwoRotations[0] - lastTwoRotations[1]) > PI:
		lastTwoRotations[0] = lastTwoRotations[0] - sign(lastTwoRotations[0] - lastTwoRotations[1]) * 2.0 * PI
	lastPhysicsProcessTime = Time.get_ticks_usec()

func take_damage(amount):
	health -= amount
	if health <= 0:
		call_deferred("die", amount)

#The damage of the killing blow affects the knockback force of the gibs
func die(damage):
	Global.score += 100
	
	var sound = AudioStreamPlayer3D.new()
	sound.stream = deathSound
	get_tree().get_root().get_node("arena").add_child(sound)
	sound.global_position = global_position
	sound.max_distance = 10000000.0
	sound.attenuation_filter_cutoff_hz = 20500
	sound.connect("finished", queue_free)
	sound.play()
	
	var modelScale = $"enemy1 model".scale
	for item in $"enemy1 model".get_children():
		var gibPos = item.global_position
		var modelRot = item.global_rotation
		
		var gib = RigidBody3D.new()
		gib.set_collision_layer_value(1, false)
		gib.set_collision_layer_value(5, true)
		gib.set_collision_mask_value(4, true)
		gib.set_collision_mask_value(5, true)
		
		var gibCollider = get_node("hurtbox/" + item.name + " collider")
		
		get_tree().get_root().get_node("arena").add_child(gib)
		gib.global_position = gibPos
		
		item.get_parent().remove_child(item)
		gib.add_child(item)
		item.position = Vector3.ZERO
		item.global_rotation = modelRot
		item.scale = modelScale
		
		gibCollider.get_parent().remove_child(gibCollider)
		gib.add_child(gibCollider)
		gibCollider.position = Vector3.ZERO
		gibCollider.global_rotation = modelRot
		
		gib.inertia = Vector3.ONE
		gib.apply_impulse((gib.global_position - player.global_position).normalized() * 5.0 * damage)
		var gibTorque = 1.2 * damage
		gib.apply_torque_impulse(Vector3(randf_range(-gibTorque, gibTorque),
			randf_range(-gibTorque, gibTorque),
			randf_range(-gibTorque, gibTorque)))
		
	queue_free()
