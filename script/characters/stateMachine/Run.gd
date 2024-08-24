extends BaseState
class_name Run

const SPEED: int = 200


func _ready() -> void:
	animation = "run"


#transition logic
func check_relevance(input: InputPackage) -> String:
	input.actions.sort_custom(states_priority_sort)
	if input.actions[0] == "run":
		return "ok"
	return input.actions[0]


func check_name() -> String:
	return "run"


#updating state
func update(input: InputPackage, delta: float) -> void:
	player.velocity = velocity_by_input(input, delta)
	#player.look_at(player.global_position - player.velocity)
	player.move_and_slide()


func velocity_by_input(input : InputPackage, _delta : float) -> Vector2:
	var new_velocity: Vector2 = player.velocity
	
	var direction: Vector2i = (Vector2i(input.input_direction.x, input.input_direction.y))
	new_velocity.x = direction.x * SPEED
	new_velocity.y = direction.y * SPEED
	
	return new_velocity
