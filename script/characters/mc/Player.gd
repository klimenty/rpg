extends Node2D

var key_buffer: Array[String] = [] #Store all movement Inputs. Last one is used to update direction
var direction_vector: Vector2 = Vector2.ZERO #Store direction value for movement
@export var tile_map: TileMap #Store tilemap. TileMap is needed for movement so game will crash if you don't link it in scene
@export var sprite_2d: Sprite2D #Store character sprite. It moves to the Player position
@export var ray_cast_2d: RayCast2D #Store RayCast2D. It's used to check if next tile is free before moving
var is_moving: bool = false #If is True, lock player movement and actions. But you still can sprint or sneaking
var speed: float = 3.0 #This variable used for movement. Value can be altered based on user input
var cell_size: int = 64 #Store cell length. It used for RayCast2D
@export var walking_speed: float = 3.0
@export var running_speed: float = 6.0
@export var sneaking_speed: float = 1.5
var is_running: bool = false
var is_sneaking: bool = false
var action_buffer: Array[String] = []


func _ready() -> void:
	#Set default speed to walking speed at the start of scene
	speed = walking_speed


#Handles all player inputs
func _input(event: InputEvent) -> void:
	#Check if Shift is pressed and modify movement speed
	if event.is_action_pressed("shift"):
		speed = running_speed

	#Check if Shift was released and modify movement speed
	if event.is_action_released("shift"):
		speed = walking_speed

	##Check if Ctrl is pressed and modify movement speed
	#if event.is_action_pressed("ctrl"):
		#action_buffer.append("ctrl")

	##Check if Ctrl was released and modify movement speed
	#if event.is_action_released("ctrl"):
		#action_buffer.erase("ctrl")

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
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ctrl"):
		if is_sneaking:
			speed = walking_speed
			is_sneaking = false
		else:
			speed = sneaking_speed
			is_sneaking = true
	
	if is_sneaking and speed != sneaking_speed:
			is_sneaking = false
	
	#Checks if player is currently in moving animation.	If True, play movement animation and stop it when sprite reaches player position.
	if is_moving:
		#Move sprite_2d to player position. Speed is determined by speed variable. 
		#If should me above destination check to prevent movement stuttering
		sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, speed)
		#Check if sprite2D reached player position. If True, movement cycle is over and player movement is unlocked
		if global_position == sprite_2d.global_position:
			is_moving = false
			return

	#Checks if player is _not_ in moving animation.	
	if not is_moving:
		#If there is inputs in key_buffer, call function to transform input to Vector2
		if key_buffer.size() > 0:
			update_direction()
		#If there is no inputs, set direction to zero (player stays in it's place)
		else:
			direction_vector = Vector2.ZERO
		#Move character based on direction. If direction is Zero, players stays on current tile
		move(direction_vector)


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
		current_tile.x + direction.x,
		current_tile.y + direction.y,
	)
	#Get custom data layer from target tile
	var tile_data: TileData = tile_map.get_cell_tile_data(0, target_tile)
	#If target tile is not walkable, stop function
	if tile_data == null or tile_data.get_custom_data("walkable") == false:
		return
	#Point RayCast2D to next tile based on direction and cell size
	ray_cast_2d.target_position = direction_vector * cell_size
	#Update RayCast2D direction. Without this direction will change in the next cycle
	ray_cast_2d.force_raycast_update()
	#Don't allow to move player if RayCast2D collides with enemy or object
	if ray_cast_2d.is_colliding():
		return
	#lock player movement
	is_moving = true
	#Change player position to target tile
	global_position = tile_map.map_to_local(target_tile)
	#Leave Sprite2D on current tile. Without it Sptite2D will teleport with player
	sprite_2d.global_position = tile_map.map_to_local(current_tile)
