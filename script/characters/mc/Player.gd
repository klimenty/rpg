extends Node2D

#Store all movement Inputs. Last one is used to update direction
var key_buffer: Array[Vector2i] = []
#Store direction value for movement
var direction_vector: Vector2i = Vector2i.ZERO
var last_direction_vector: Vector2i
#Store tilemap. TileMap is needed for movement so game will crash if you don't link it in scene
@export var tile_map: TileMap
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var ray_cast_2d: RayCast2D
@onready var input_gatherer: InputGatherer = $Input/InputGatherer
#If is True, lock player movement and actions. But you still can sprint or sneaking
var is_moving: bool = false
var speed: float = 3.0
var cell_size: int = 64
@export var walk_speed: float = 3.0
@export var run_speed: float = 6.0
@export var sneak_speed: float = 1.5
enum MovementStates {
	IDLE,
	WALK,
	RUN,
	SNEAK
}
var MovementState: int = MovementStates.WALK


func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var input_package: InputPackage = input_gatherer.gather_input()
	#Change speed based on MovementState

	#Checks if player is currently in moving animation.	If True, play movement animation and stop it when sprite reaches player position.
	if is_moving:
		#Move animated_sprite_2d to player position. Speed is determined by speed variable. 
		#If should be above destination check to prevent movement stuttering
		sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, speed)
		if global_position == sprite_2d.global_position:
			is_moving = false
			return

	#Checks if player is _not_ in moving animation.	
	if not is_moving:
		direction_vector = input_package.input_direction
		move_state_machine(input_package.actions)
		move(direction_vector)


#Change speed based on MovementState
func move_state_machine(actions) -> void:
	if actions.has("run"):
		speed = run_speed
	elif actions.has("sneak"):
		speed = sneak_speed
	elif actions.has("walk"):
		speed = walk_speed


#Check if next tile is walkable and move player to it
func move(direction: Vector2i) -> void:
	#Get current tile Vector2i
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	#Get target tile Vector2i
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y
	)
	#Get custom data layer from target tile
	var tile_data: TileData = tile_map.get_cell_tile_data(0, target_tile)
	#If target tile is not walkable, stop function
	if tile_data == null or tile_data.get_custom_data("walkable") == false:
		return
	ray_cast_2d.target_position = direction_vector * cell_size
	#Update RayCast2D direction. Without this direction will change in the next cycle
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		return
	#lock player movement
	is_moving = true
	#Change player position to target tile
	global_position = tile_map.map_to_local(target_tile)
	#Leave Sprite2D on current tile. Without it Sptite2D will teleport with player
	sprite_2d.global_position = tile_map.map_to_local(current_tile)


func player() -> void:
	pass
