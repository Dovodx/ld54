extends RigidBody3D

@export var health = 5
@export var speed = 20.0
var player: Node3D

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]

func _integrate_forces(state):
	if player != null:
		linear_velocity += (player.global_position - global_position).normalized() * speed * (1.0 / Engine.physics_ticks_per_second)

func take_damage(amount):
	health -= amount
	if health <= 0:
		call_deferred("die")

func die():
	#TODO: death effects visual and sound
	queue_free()
