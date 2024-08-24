extends BaseState
class_name Idle


func _ready() -> void:
	animation = "idle"

#transition logic
func check_relevance(input: InputPackage) -> String:
	input.actions.sort_custom(states_priority_sort)
	return input.actions[0]
	

func check_name() -> String:
	return "idle"


#updating state
func update(_input: InputPackage, _delta: float) -> void:
	pass


func on_enter_state() -> void:
	player.velocity = Vector2i.ZERO


func on_exit_state() -> void:
	pass
