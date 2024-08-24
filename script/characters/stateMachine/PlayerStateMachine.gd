extends Node
class_name PlayerStateMachine

@onready var player: Node = $".."

var current_state: BaseState
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@onready var states: Dictionary = {
	"idle" : $States/Idle,
	"walk" : $States/Walk,
	"run": $States/Run,
	"sneak": $States/Sneak
}

var animation_direction: String = "DOWN"

func _ready() -> void:
	current_state = states["idle"]
	for state: Node in states.values():
		state.player = player


func update(input : InputPackage, delta : float) -> void:
	var relevance: String = current_state.check_relevance(input)
	if relevance != "ok":
		switch_to(relevance)
	current_state.update(input, delta)
	if input.input_direction != Vector2i.ZERO:
			animation_direction = direction_to_string(input.input_direction)
	play_animation(animation_direction)


func switch_to(state : String) -> void:
	current_state.on_exit_state()
	current_state = states[state]
	current_state.on_enter_state()


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


func play_animation(direction: String) -> void:
	var current_animation: String = animation_player.current_animation
	var next_animation: String = "%s_%s" % [current_state.check_name(), direction]
	
	if current_animation != next_animation:
		animation_player.play(next_animation)
	
	
