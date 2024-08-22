extends Node
class_name PlayerStateMachine

@onready var player: Node = $".."

var current_state: BaseState

@onready var states = {
	"idle" : $Idle,
	"walk" : $Walk,
}


func _ready() -> void:
	current_state = states["idle"]
	for state: Node in states.values():
		state.player = player


func update(input : InputPackage, delta : float) -> void:
	var relevance: String = current_state.check_relevance(input)
	if relevance != "ok":
		switch_to(relevance)
	current_state.update(input, delta)


func switch_to(state : String) -> void:
	current_state.on_exit_state()
	current_state = states[state]
	current_state.on_enter_state()
