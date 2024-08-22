extends BaseState
class_name Idle

#transition logic
func check_relevance(input: InputPackage) -> String:
	if input.actions.has("run"):
		return "run"
	if input.actions.has("walk"):
		return "walk"
	return "ok"


#updating state
func update(_input: InputPackage, _delta: float) -> void:
	pass


func on_enter_state() -> void:
	pass


func on_exit_state() -> void:
	pass
