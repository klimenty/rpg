extends Area2D


class_name HurtboxController

func _init() -> void:
	collision_layer = 0
	collision_mask = 4
	

func _ready():
	connect("area_entered", self._on_area_entered)
	

func _on_area_entered(hitbox: HitboxController) -> void:
	if hitbox == null:
		return
	
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
