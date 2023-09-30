extends Area3D

@export var healthManager: Node3D
@export var playerId = 0
@export var teamId = 0

#TODO: call func on health script
func take_damage(amount):
	healthManager.take_damage(amount)
