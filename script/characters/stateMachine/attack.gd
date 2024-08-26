extends BaseState
class_name Attack


func _ready():
	animation = "attack"


func check_relevance(input : InputPackage):
	input.actions.sort_custom(states_priority_sort)
	if input.actions[0] == "attack":
		return "ok"
	return input.actions[0]


func check_name() -> String:
	return "attack"


func on_enter_state():
	player.velocity = Vector2.ZERO
