extends Node2D

#Store direction value for movement
var direction_vector: Vector2i = Vector2i.DOWN
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
var last_state: String


func _ready() -> void:
	last_state = input_gatherer.gather_input().actions.back()


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
		if direction_vector != Vector2i.ZERO:
			last_direction_vector = direction_vector
			move(direction_vector)
		move_state_machine(input_package.actions)
		
		

	animation(input_package.actions, last_direction_vector)
	print(is_moving)


#Change speed based on MovementState
func move_state_machine(actions: Array[String]) -> void:
	if actions.has("run"):
		speed = run_speed
		last_state = "run"
	elif actions.has("sneak"):
		speed = sneak_speed
	elif actions.has("walk"):
		speed = walk_speed
		last_state = "walk"


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


func animation(states: Array[String], direction: Vector2i) -> void:
	var current_animation: String = animation_player.current_animation
	var next_animation: String
	var is_sneaking: bool = false
	var state: String
	
	if is_moving:
		state = last_state
	elif states[-1] == "sneak":
		is_sneaking = true
		state = states[-2]
	else:
		is_sneaking = false
		state = states[-1]
	
	match direction:
		Vector2i.ZERO:
			next_animation = state + "_down"
		Vector2i.DOWN:
			next_animation = state + "_down"
		Vector2i.UP:
			next_animation = state + "_up"
		Vector2i.LEFT:
			next_animation = state + "_left"
		Vector2i.RIGHT:
			next_animation = state + "_right"
	
	if is_sneaking:
		sprite_2d.modulate = Color(1, 1, 1, 0.5)
	else:
		sprite_2d.modulate = Color(1, 1, 1, 1)
	
	if current_animation == next_animation:
		return

	animation_player.play(next_animation)


func player() -> void:
	pass
