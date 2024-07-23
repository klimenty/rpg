extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	falling_from_tree()
	
func falling_from_tree():
	$AnimatedSprite2D.play("tree_log_spawn")
	$AnimationPlayer.play("falling_from_tree")
	await get_tree().create_timer(1).timeout
	$AnimatedSprite2D.play("tree_log_idle")
	await get_tree().create_timer(3).timeout
	$AnimationPlayer.play("fade")
	print("+1 tree log")
	await get_tree().create_timer(3).timeout
	queue_free()
