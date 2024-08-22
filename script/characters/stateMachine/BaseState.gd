extends Node
class_name BaseState


# all-move flags and variables here
var player: CharacterBody2D


static var states_priority : Dictionary = {
	"idle": 1,
	"walk": 2,
	"run": 10  # be generous to not edit this to much when sprint, dash, crouch etc are added
}


static func states_priority_sort(a : String, b : String) -> bool:
	if states_priority[a] > states_priority[b]:
		return true
	else:
		return false


func check_relevance(input : InputPackage) -> String:
	print_debug("error, implement the check_relevance function on your state")
	return "error, implement the check_relevance function on your state"


func update(input : InputPackage, delta : float):
	pass


func on_enter_state():
	pass

func on_exit_state():
	pass
