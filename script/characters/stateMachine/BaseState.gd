extends Node
class_name BaseState


# all-move flags and variables here
var player: CharacterBody2D

var animation : String
var move_name : String

static var states_priority : Dictionary = {
	"idle": 1,
	"walk": 2,
	"sneak": 3,
	"run": 10  # be generous to not edit this to much when sprint, dash, crouch etc are added
}


static func states_priority_sort(a : String, b : String) -> bool:
	if states_priority[a] > states_priority[b]:
		return true
	else:
		return false


func check_relevance(_input : InputPackage) -> String:
	print_debug("error, implement the check_relevance function on your state")
	return "error, implement the check_relevance function on your state"


func update(_input : InputPackage, _delta : float) -> void:
	pass


func on_enter_state() -> void:
	pass

func on_exit_state() -> void:
	pass
