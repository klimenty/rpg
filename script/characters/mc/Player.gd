extends Node2D

#Store all movement Inputs. Last one is used to update direction
var key_buffer: Array[String] = []
#Store direction value for movement
var direction_vector: Vector2 = Vector2.ZERO
#Store tilemap. TileMap is needed for movement so game will crash if you don't link it in scene
@export var tile_map: TileMap
@export var sprite_2d: Sprite2D
@export var ray_cast_2d: RayCast2D
#If is True, lock player movement and actions. But you still can sprint or sneaking
var is_moving: bool = false
var speed: float = 3.0
var cell_size: int = 64
@export var walking_speed: float = 3.0
@export var running_speed: float = 6.0
@export var sneaking_speed: float = 1.5
var action_buffer: Array[String] = []
enum MovementStates {
	WALKING,
	RUNNING,
	SNEAKING
}
var MovementState: int = MovementStates.WALKING


func _ready() -> void:
	pass


#Handles all player inputs
func _input(event: InputEvent) -> void:
	#TEMPORARY!
	#Exit game key
	if event.is_action_pressed("escape"):
		get_tree().quit()
	
	#Enable and disable sprint
	if event.is_action_pressed("shift"):
		MovementState = MovementStates.RUNNING
	if event.is_action_released("shift"):
		MovementState = MovementStates.WALKING

	#Enable and disable sneaking
	if event.is_action_pressed("ctrl"):
		if MovementState == MovementStates.SNEAKING:
			MovementState = MovementStates.WALKING
		else:
			MovementState = MovementStates.SNEAKING

	#Store all pressed movement buttons to key_buffer variable
	if event.is_action_pressed("up"):
		key_buffer.append("up")
	elif event.is_action_pressed("down"):
		key_buffer.append("down")
	elif event.is_action_pressed("left"):
		key_buffer.append("left")
	elif event.is_action_pressed("right"):
		key_buffer.append("right")

	#Delete buttons from key_buffer if button was released
	if event.is_action_released("up"):
		key_buffer.erase("up")
	elif event.is_action_released("down"):
		key_buffer.erase("down")
	elif event.is_action_released("left"):
		key_buffer.erase("left")
	elif event.is_action_released("right"):
		key_buffer.erase("right")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	#Change speed based on MovementState
	move_state_machine()

	#Checks if player is currently in moving animation.	If True, play movement animation and stop it when sprite reaches player position.
	if is_moving:
		#Move sprite_2d to player position. Speed is determined by speed variable. 
		#If should be above destination check to prevent movement stuttering
		sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, speed)
		if global_position == sprite_2d.global_position:
			is_moving = false
			return

	#Checks if player is _not_ in moving animation.	
	if not is_moving:
		if key_buffer.size() > 0:
			update_direction()
		else:
			direction_vector = Vector2.ZERO
		move(direction_vector)


#Change speed based on MovementState
func move_state_machine() -> void:
	match MovementState:
		MovementStates.WALKING:
			speed = walking_speed
		MovementStates.RUNNING:
			speed = running_speed
		MovementStates.SNEAKING:
			speed = sneaking_speed


#Transform last string valuse from key_buffer to Vector2 values and store it in direction_vector
func update_direction() -> void:
	#Select last pressed key from key_buffer
	var last_key: String = key_buffer.back()

	#Check last pressed key value and updates direction_vector
	match last_key:
		"up":
			direction_vector = Vector2(0, -1)
		"down":
			direction_vector = Vector2(0, 1)
		"left":
			direction_vector = Vector2(-1, 0)
		"right":
			direction_vector = Vector2(1, 0)


#Check if next tile is walkable and move player to it
func move(direction: Vector2) -> void:
	#Get current tile Vector2i
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	#Get target tile Vector2i
	var target_tile: Vector2i = Vector2i(
		current_tile.x + int(direction.x),
		current_tile.y + int(direction.y)
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
