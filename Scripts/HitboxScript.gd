extends Area3D

@export var playerId = 0
@export var teamId = 0

@export var damage = 1

func _on_area_entered(area):
	if area.name == "hurtbox":
		if area.teamId != teamId:
			area.take_damage(damage)
