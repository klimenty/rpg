extends Node
class_name PlayerStateMachine

@onready var player: Node = $".."

var current_state: BaseState
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@onready var states: Dictionary = {
	"idle" : $Idle,
	"walk" : $Walk,
}

var animation_direction: String = "DOWN"

func _ready() -> void:
	current_state = states["idle"]
	for state: Node in states.values():
		state.player = player


func update(input : InputPackage, delta : float) -> void:
	var relevance: String = current_state.check_relevance(input)
	if relevance != "ok":
		if input.input_direction != Vector2i.ZERO:
			animation_direction = direction_to_string(input.input_direction)
		switch_to(relevance, animation_direction)
	current_state.update(input, delta)


func switch_to(state : String, direction: String) -> void:
	current_state.on_exit_state()
	current_state = states[state]
	current_state.on_enter_state()
	animation_player.play("%s_%s" % [state, direction])
	print(state, direction)


func direction_to_string(direction: Vector2i) -> String:
	var string: String
	
	match direction:
		Vector2i.RIGHT:
			string = "RIGHT"
		Vector2i.LEFT:
			string = "LEFT"
		Vector2i.UP:
			string = "UP"
		Vector2i.DOWN:
			string = "DOWN"
		
	return string
