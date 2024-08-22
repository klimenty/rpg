extends Node


@onready var input_gatherer: InputGatherer = $Input/InputGatherer
@onready var state_machine: PlayerStateMachine = $PlayerStateMachine


func _physics_process(delta: float) -> void:
	var input: InputPackage = input_gatherer.gather_input()
	state_machine.update(input, delta)
