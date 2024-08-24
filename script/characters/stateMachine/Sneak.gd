extends BaseState
class_name Sneak

#transition logic
func check_relevance(input: InputPackage) -> String:
	if input.input_direction == Vector2i.ZERO:
		return "sneak"
	return "ok"


func check_name() -> String:
	return "sneak"


#updating state
func update(_input: InputPackage, _delta: float) -> void:
	pass


func on_enter_state() -> void:
	pass


func on_exit_state() -> void:
	pass
