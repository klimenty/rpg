extends Node
class_name PlayerStateMachine

@onready var player: Node2D = $"."

var current_move: BaseState

@onready var moves = {
	"idle" = $Idle,
	"walk" = $Walk,
	"run" = $Run
}


#
#func _ready():
	#current_move = moves["idle"]
	#for move in moves.values():
		#move.player = player
		#
#func update(input: InputPackage, delta: float):
	#var relevance = current_move.check_relevance()
	#if relevance != "ok":
		#switch_to(relevance)
	#current_move.update(input, delta)
#
#
#func switch_to(state: String):
	#current_move.on_exit_state()
	#current_move = moves[state]
	#current_move.on_enter_state()
	#
