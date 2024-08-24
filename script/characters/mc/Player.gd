extends CharacterBody2D


@onready var input_gatherer: InputGatherer = $Input
@onready var model: PlayerStateMachine = $Model


func _physics_process(delta: float) -> void:
	var input: InputPackage = input_gatherer.gather_input()
	model.update(input, delta)

	input.queue_free()
