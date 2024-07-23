extends Area2D

class_name HitboxController

@export var damage: int = 1


func _init() -> void:
	collision_layer = 4
	collision_mask = 0
