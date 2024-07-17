extends Node2D

var state = "no tree"
var player_in_area = false
var tree_log = preload("res://scene/collectable_items/tree_log_collectable.tscn")


func _ready():
	if state == "no tree":
		$growth_timer.start()
		
func _process(delta):
	if state == "no tree":
		$AnimatedSprite2D.play("no_tree")
	if state == "tree":
		$AnimatedSprite2D.play("tree")
		if player_in_area:
			if Input.is_action_just_pressed("confirm"):
				state = "cutting tree"
				$AnimatedSprite2D.play("cutting_tree")
				await get_tree().create_timer(1).timeout
				state = "no tree"
				drop_tree_log()

func _on_pickable_area_body_entered(body):
	if body.has_method("player"):
		player_in_area = true


func _on_pickable_area_body_exited(body):
	if body.has_method("player"):
		player_in_area = false


func _on_growth_timer_timeout():
	if state == "no tree":
		state = "tree"

func drop_tree_log():
	var tree_log_instance = tree_log.instantiate()
	tree_log_instance.global_position = $Marker2D.global_position
	get_parent().add_child(tree_log_instance)
	
	await get_tree().create_timer(3).timeout
	$growth_timer.start()
