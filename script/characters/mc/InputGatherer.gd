extends Node
class_name InputGatherer

var movement_buffer: Array[Vector2i]
var action_buffer: Array[String]
var attack_action_buffer: Array[String]

func _input(event: InputEvent) -> void:
	#TEMPORARY!
	#Exit game key
	if event.is_action_pressed("escape"):
		get_tree().quit()
	
	#Enable and disable sprint
	if event.is_action_pressed("shift"):
		action_buffer.append("run")
	if event.is_action_released("shift"):
		action_buffer.erase("run")

	#Enable and disable sneaking
	if event.is_action_pressed("ctrl"):
		if action_buffer.has("sneak"):
			action_buffer.erase("sneak")
		else:
			action_buffer.append("sneak")

	if event.is_action_pressed("a"):
		attack_action_buffer.append("attack")
	if event.is_action_pressed("s"):
		attack_action_buffer.append("attack")
	if event.is_action_pressed("d"):
		attack_action_buffer.append("attack")
	if event.is_action_pressed("f"):
		attack_action_buffer.append("attack")

	if event.is_action_pressed("up"):
		movement_buffer.append(Vector2i.UP)
	elif event.is_action_pressed("down"):
		movement_buffer.append(Vector2i.DOWN)
	elif event.is_action_pressed("left"):
		movement_buffer.append(Vector2i.LEFT)
	elif event.is_action_pressed("right"):
		movement_buffer.append(Vector2i.RIGHT)
		
	if event.is_action_released("up"):
		movement_buffer.erase(Vector2i.UP)
	elif event.is_action_released("down"):
		movement_buffer.erase(Vector2i.DOWN)
	elif event.is_action_released("left"):
		movement_buffer.erase(Vector2i.LEFT)
	elif event.is_action_released("right"):
		movement_buffer.erase(Vector2i.RIGHT)


func gather_input() -> InputPackage:
	var new_input: InputPackage = InputPackage.new()

	if action_buffer.has("sneak"):
		if action_buffer.has("run"):
			action_buffer.erase("sneak")
		else:
			new_input.actions.append("sneak")

	if attack_action_buffer.is_empty() == false:
		new_input.combat_actions.append(attack_action_buffer.back())
		attack_action_buffer = []

	if movement_buffer.is_empty():
		new_input.input_direction = Vector2i.ZERO
	else:
		new_input.input_direction = movement_buffer.back()
		new_input.actions.append("walk")
		if action_buffer.has("run"):
			new_input.actions.append("run")

	if new_input.actions.is_empty():
		new_input.actions.append("idle")
	print(new_input.actions)
	return new_input
