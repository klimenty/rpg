## This base Velocity module handles movement and contains variables for speed + gravity. 
## These can be built out or extended into npc/enemy velocity, etc. 
class_name VELOCITY extends Node2D 

@export var WALK_SPEED: int = 100			## Character's base speed.
@export var RUN_SPEED: int = 200	## Character's base run speed. 
@export var STEALTH_SPEED: int = 50		## Character's base stealth speed.

@export_group("Nodes")
@export var individual: CharacterBody2D	## Parent node that does any movement. 
@export var inputNode: INPUT				## Grab the parent's input node.

var currentSpeed: int = WALK_SPEED
var speed: int = WALK_SPEED
var is_moving: bool = false


## Handle any velocity calculations. 
func handleVelocity(delta):
	## NOTE: If Sprinting is STANDARD for all users of this module, it could be moved here.
	
	
	## Get the input direction and handle the movement/deceleration.
	var direction = inputNode.getMoveInput()
	print(direction)
	if direction:
		individual.velocity = direction * speed * delta
	#else:
		#individual.velocity.x = move_toward(individual.velocity.x, 0, speed)


func move_in_direction():
	if individual.direction:
#		target_position = global_position + direction_vector * step_distance
		is_moving = true
#/
## Call any movement-related functions to initiate movement. 
func activateMove():
	
	individual.move_and_collide(individual.global_position + individual.velocity)

#/
## Modify the speed for any given set of modifiers. 
func calculateSpeed():
	currentSpeed = WALK_SPEED
