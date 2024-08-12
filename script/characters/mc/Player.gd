extends Node2D

#Store all movement Inputs. Last one is used to update direction
var key_buffer: Array[Vector2i] = []
#Store direction value for movement
var direction_vector: Vector2i = Vector2i.ZERO
var last_direction_vector: Vector2i = Vector2i.ZERO
#Store tilemap. TileMap is needed for movement so game will crash if you don't link it in scene
@export var tile_map: TileMap
#@export var sprite_2d: Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var ray_cast_2d: RayCast2D
#If is True, lock player movement and actions. But you still can sprint or sneaking
var is_moving: bool = false
var is_sneaking: bool = false
var speed: float = 3.0
var cell_size: int = 64
@export var walking_speed: float = 3.0
@export var running_speed: float = 6.0
@export var sneaking_speed: float = 1.5
var main_StateMachine: LimboHSM


func _ready() -> void:
	initiate_state_machine()
	

func initiate_state_machine() -> void:
	main_StateMachine = LimboHSM.new()
	add_child(main_StateMachine)
	
	var idle_state: LimboState = LimboState.new().named("idle").call_on_enter(idle_start).call_on_update(idle_update)
	var walking_state: LimboState = LimboState.new().named("walking").call_on_enter(walking_start).call_on_update(walking_update)
	var running_state: LimboState = LimboState.new().named("running").call_on_enter(running_start).call_on_update(running_update)
	var sneaking_state: LimboState = LimboState.new().named("sneaking").call_on_enter(sneaking_start).call_on_update(sneaking_update)
	
	main_StateMachine.add_child(idle_state)
	main_StateMachine.add_child(walking_state)
	main_StateMachine.add_child(running_state)
	main_StateMachine.add_child(sneaking_state)
	
	main_StateMachine.initial_state = idle_state
	
	main_StateMachine.add_transition(main_StateMachine.ANYSTATE, idle_state, &"state_ended")
	main_StateMachine.add_transition(main_StateMachine.ANYSTATE, walking_state, &"to_walking")
	main_StateMachine.add_transition(main_StateMachine.ANYSTATE, running_state, &"to_running")
	main_StateMachine.add_transition(main_StateMachine.ANYSTATE, sneaking_state, &"to_sneaking")

	main_StateMachine.initialize(self)
	main_StateMachine.set_active(true)


func idle_start() -> void:
	if is_sneaking == true:
		is_sneaking = false
func idle_update(_delta: float) -> void:
	if key_buffer.size() > 0:
		main_StateMachine.dispatch(&"to_walking")

func walking_start() -> void:
	if is_sneaking == true:
		is_sneaking = false
	speed = walking_speed
func walking_update(_delta: float) -> void:
	if key_buffer.size() == 0:
		main_StateMachine.dispatch(&"state_ended")

func running_start() -> void:
	if is_sneaking == true:
		is_sneaking = false
	speed = running_speed
func running_update(_delta: float) -> void:
	pass
	
func sneaking_start() -> void:
	speed = sneaking_speed
func sneaking_update(_delta: float) -> void:
	pass

#Handles all player inputs
func _input(event: InputEvent) -> void:
	#TEMPORARY!
	#Exit game key
	if event.is_action_pressed("escape"):
		get_tree().quit()
	
	#Enable and disable sprint
	if event.is_action_pressed("shift"):
		main_StateMachine.dispatch(&"to_running")
	if event.is_action_released("shift"):
		main_StateMachine.dispatch(&"to_walking")

	#Enable and disable sneaking
	if event.is_action_pressed("ctrl"):
		if is_sneaking:
			is_sneaking = false
			main_StateMachine.dispatch(&"to_walking")
		else:
			is_sneaking = true
			main_StateMachine.dispatch(&"to_sneaking")

	#Store all pressed movement buttons to key_buffer variable
	if event.is_action_pressed("up"):
		key_buffer.append(Vector2i.UP)
	elif event.is_action_pressed("down"):
		key_buffer.append(Vector2i.DOWN)
	elif event.is_action_pressed("left"):
		key_buffer.append(Vector2i.LEFT)
	elif event.is_action_pressed("right"):
		key_buffer.append(Vector2i.RIGHT)

	#Delete buttons from key_buffer if button was released
	if event.is_action_released("up"):
		key_buffer.erase(Vector2i.UP)
	elif event.is_action_released("down"):
		key_buffer.erase(Vector2i.DOWN)
	elif event.is_action_released("left"):
		key_buffer.erase(Vector2i.LEFT)
	elif event.is_action_released("right"):
		key_buffer.erase(Vector2i.RIGHT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:

	#Checks if player is currently in moving animation.	If True, play movement animation and stop it when sprite reaches player position.
	if is_moving:
		#Move animated_sprite_2d to player position. Speed is determined by speed variable. 
		#If should be above destination check to prevent movement stuttering
		animated_sprite_2d.global_position = animated_sprite_2d.global_position.move_toward(global_position, speed)
		if global_position == animated_sprite_2d.global_position:
			is_moving = false
			return

	#Checks if player is _not_ in moving animation.	
	if not is_moving:
		if key_buffer.size() > 0:
			direction_vector = key_buffer.back()
			if last_direction_vector != direction_vector:
				last_direction_vector = direction_vector
		else:
			direction_vector = Vector2i.ZERO
		move(direction_vector)


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
	animated_sprite_2d.global_position = tile_map.map_to_local(current_tile)


func player() -> void:
	pass
