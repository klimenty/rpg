extends Node
class_name BaseState

#transition logic
func check_relevance(input: InputPackage) -> String:
	print_debug("error, implement the check function on your state")
	return "error, implement the check function on your state"


#updating state
func update(input: InputPackage, delta: float):
	pass


func on_enter_state():
	pass


func on_exit_state():
	pass
