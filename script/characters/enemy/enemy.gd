extends Node2D

@export var player: Node2D
@export var tile_map: TileMap
@export var sprite_2d: Sprite2D

var a_star_grid_2d: AStarGrid2D
var is_moving: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	a_star_grid_2d = AStarGrid2D.new()
	a_star_grid_2d.region = tile_map.get_used_rect()
	a_star_grid_2d.cell_size = Vector2(64, 64)
	a_star_grid_2d.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star_grid_2d.update()
	
	var region_size = a_star_grid_2d.region.size
	var region_position = a_star_grid_2d.region.position
	
	for x in region_size.x:
		for y in region_size.y:
			var tile_position = Vector2i(
				x + region_position.x,
				y + region_position.y
			)
			
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			
			if tile_data == null or not tile_data.get_custom_data("walkable"):
				a_star_grid_2d.set_point_solid(tile_position)

#func _process(delta: float) -> void:
	#if is_moving:
		#return
	#
	#move()	



	

func move():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var occupied_positions = []
	
	for enemy in enemies:
		if enemy == self:
			continue
		
		occupied_positions.append(tile_map.local_to_map(enemy.global_position))
	
	for occupied_position in occupied_positions:
		a_star_grid_2d.set_point_solid(occupied_position)
	
	var path = a_star_grid_2d.get_id_path(
		tile_map.local_to_map(global_position),
		tile_map.local_to_map(player.global_position)
	)
	
	for occupied_position in occupied_positions:
		a_star_grid_2d.set_point_solid(occupied_position, false)
	
	path.pop_front()
	
	if path.is_empty():
		print("Can't find path")
		return
		
	if path.size() == 1:
		print("I have arrived")
		return
		
	
	var original_position = Vector2(global_position)
	global_position = tile_map.map_to_local(path[0])
	sprite_2d.global_position = original_position
	
	is_moving = true

func _physics_process(delta: float) -> void:
	if is_moving:
		sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, 2)
		
		if sprite_2d.global_position != global_position:
			return
			
		is_moving = false

	if is_moving:
		return
	
	move()	
