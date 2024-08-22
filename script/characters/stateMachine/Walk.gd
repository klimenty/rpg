extends BaseState
class_name Walk

const SPEED: int = 5


func check_relevance(input : InputPackage):
	input.actions.sort_custom(states_priority_sort)
	
	if input.actions[0] == "walk":
		return "ok"

	return input.actions[0]
	
	#if input.actions.has("jump") and player.is_on_floor():
		#return "jump"
	#if input.input_direction == Vector2.ZERO:
		#return "idle"
	#return "okay"


func update(input : InputPackage, delta : float):
	player.velocity = velocity_by_input(input, delta)
	player.move_and_slide()


func velocity_by_input(input : InputPackage, delta : float) -> Vector2:
	var new_velocity = player.velocity
	var direction = (player.transform * Vector2(input.input_direction.x, input.input_direction.y)).normalized()
	print(direction)
	new_velocity.x = direction.x * SPEED
	new_velocity.y = direction.y * SPEED
	return new_velocity
