extends Node2D

@export var player: Node2D #Store player node for pathfinding
@export var tile_map: TileMap #Store tilemap. TileMap is needed for movement so game will crash if you don't link it in scene
@export var sprite_2d: Sprite2D #Store character sprite. It moves to the enemy position
@export var ray_cast_2d: RayCast2D
@export var detection_area: CollisionShape2D
var cell_size: int = 64
var cone_of_sight_length: int = 3
var a_star_grid_2d: AStarGrid2D #Store AStarGrid2D. It's used for pathfinding
var is_moving: bool = false #If is True, lock character movement and actions
var speed: float = 2.0 #This variable used for movement. Value can be altered based on user input
var sight_direction: Vector2 = Vector2.DOWN
var target: Node
var target_position: Vector2
var target_area: Area2D
var target_last_position: Vector2
var next_step: Vector2
enum States {
	IDLE,
	CHASE
}
var State: int = States.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_controller(State)
	
	#Creates a new AStarGrid2D
	a_star_grid_2d = AStarGrid2D.new()
	#Set AStarGrid2D region to all used tiles in scene
	a_star_grid_2d.region = tile_map.get_used_rect()
	#Set AStarGrid2D sell size
	a_star_grid_2d.cell_size = Vector2(64, 64)
	#Forbid character to move diagonally
	a_star_grid_2d.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	#Updates AStarGrid2D. Without it new parameters won't work
	a_star_grid_2d.update()

	#Store size of region
	var region_size: Vector2i = a_star_grid_2d.region.size
	#Make all tiles on the grid without "walkable" tag non walkable
	#Check all x axis values of tiles
	for x: int in region_size.x:
		#Check all y axis values of tiles
		for y: int in region_size.y:
			#Select a tile with x and y coordinates
			var tile_position: Vector2i = Vector2i(x, y)
			#Collect data_layer infromation from layer 0 of selected tile
			var tile_data: TileData = tile_map.get_cell_tile_data(0, tile_position)
			#If there is no tile or it dosent gave "walkable" tag, make position non walkable
			if tile_data == null or not tile_data.get_custom_data("walkable"):
				a_star_grid_2d.set_point_solid(tile_position)

#Move character
func move() -> void:
	#Store all characters in "enemies" group
	var enemies: Variant = get_tree().get_nodes_in_group("enemies")
	#Stores all positions of characters in "enemies" grou[
	var occupied_positions: Array[Vector2i] = []

	#Adds enemies positions to occupied_positions array
	for enemy: Variant in enemies:
		#Ignore own position so it won't become non walkable later
		if enemy == self:
			continue
		#Adds enemies positions to occupied_positions array
		occupied_positions.append(tile_map.local_to_map(enemy.global_position))

	#Makes all positions in occupied_positions non walkable
	for occupied_position in occupied_positions:
		a_star_grid_2d.set_point_solid(occupied_position)

	#Find a path from current position to player position
	var path: Array = a_star_grid_2d.get_id_path(
		tile_map.local_to_map(global_position),
		tile_map.local_to_map(target_position)
	)

	#Make all enemies pisitions walkable again. Character already have path so they won't stuck in each other
	for occupied_position in occupied_positions:
		a_star_grid_2d.set_point_solid(occupied_position, false)

	#First position in path always Vector2i(0, 0) so we get rid of it
	path.pop_front()

	#If there is no path, stop function
	if path.is_empty():
		print("Can't find path")
		return

	#Last value in the path is player position. We stop movement so character won't try to get to occupied position
	if path.size() == 1:
		#print("I have arrived")
		state_controller(States.IDLE)
		return

	#Store current position for Sprite2D
	var original_position: Vector2 = Vector2(global_position)
	sight_direction = path[1] - path[0]
	#Move character to new position
	global_position = tile_map.map_to_local(path[0])
	#Leaves Sprite2D in original position for walking animation
	sprite_2d.global_position = original_position
	#Lock out character movement until movement animation is finished
	is_moving = true

func _physics_process(_delta: float) -> void:
	#Checks if character is currently in moving animation.	If True, play movement animation and stop it when sprite reaches character position.
	if is_moving:
		#Move sprite_2d to character position. Speed is determined by speed variable. 
		#It should be above destination check to prevent movement stuttering
		sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, speed)
		#Check if sprite2D reached player position. If True, movement cycle is over and player movement is unlocked
		if global_position == sprite_2d.global_position:
			is_moving = false
			return
		#Stop function and don't alow to move again if is_moving is True
		return

	state_controller(State)

	if State == States.IDLE:
		if Engine.get_physics_frames() % 20 == 0:
			update_raycast_direction()
		if ray_cast_2d.is_colliding():
			friend_or_foe()
	
	if State == States.CHASE:
		update_target_position()
		move()
	
func update_raycast_direction() -> void:
	ray_cast_2d.target_position = sight_direction * cell_size * cone_of_sight_length
	#Update RayCast2D direction. Without this direction will change in the next cycle
	ray_cast_2d.force_raycast_update()


func friend_or_foe() -> void:
	var colliding_object: Variant = ray_cast_2d.get_collider().get_parent()
	if colliding_object.has_method("player"):
		target = colliding_object
		
		State = States.CHASE

func state_controller(current_state: int) -> void:
	State = current_state
	
	match State:
		States.IDLE:
			ray_cast_2d.enabled = true
			detection_area.disabled = true
		States.CHASE:
			ray_cast_2d.enabled = false
			detection_area.disabled = false


func update_target_position() -> void:
	if target == null:
		target_position = target_last_position
	else:
		target_position = target.global_position

func _on_detection_area_area_exited(_area: Area2D) -> void:
	if _area.get_parent() == target:
		target_last_position = Vector2(target.global_position)
		target = null


func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("player"):
		target = area.get_parent()
