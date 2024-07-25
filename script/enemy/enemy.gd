extends CharacterBody2D

@export var tile_map: TileMap

var speed: int = 50
var walk_speed: int = 50
var run_speed: int = 75
var step_distance: int = 64
var is_running: bool = false


var player_in_area: bool = false
var player: CharacterBody2D
var player_position: Vector2i = Vector2i.ZERO

var astar_grid: AStarGrid2D
var is_moving: bool = false
var target_position: Vector2 = Vector2.ZERO
var direction_vector: Vector2 = Vector2.ZERO
var look_vector: Vector2 = Vector2.DOWN
var last_direction: Vector2 = Vector2.ZERO
var path: Array[Vector2i]
var state: String = 'idle'
var last_position: Vector2

func _ready() -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2i(64, 64)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

	var region_size: Vector2 = astar_grid.region.size
	var region_position: Vector2 = astar_grid.region.position

	for x in region_size:
		for y in region_size:
			var tile_position: Vector2i = Vector2i(
				x + region_position.x,
				y + region_position.y,
			)

			var tile_data: TileData = tile_map.get_cell_tile_data(0, tile_position)

			if tile_data == null or not tile_data.get_custom_data("walkable"):
				astar_grid.set_point_solid(tile_position)


func move_in_direction() -> void:

	if direction_vector != Vector2.ZERO:
		target_position = global_position + direction_vector * step_distance
		var current_tile: Vector2i = tile_map.local_to_map(global_position)
		var target_tile: Vector2i = Vector2i(
			current_tile.x + direction_vector.x,
			current_tile.y + direction_vector.y,
			)
		var tile_data: TileData = tile_map.get_cell_tile_data(0, target_tile)
		if tile_data.get_custom_data("walkable") == false:
			return

		is_moving = true

func update_direction() -> void:
	if is_moving:
		return
	var enemies: Array[Variant] = get_tree().get_nodes_in_group("enemies")
	var occupied_positions: Array[Vector2i] = []

	for enemy: Variant in enemies:
		if enemy == self:
			pass
		occupied_positions.append(tile_map.local_to_map(enemy.global_position))

	for occupoed_position in occupied_positions:
		astar_grid.set_point_solid(occupoed_position)

	if player_in_area:
		player_position = tile_map.local_to_map(player.position)

	match state:
		"idle":
			player_position = Vector2i.ZERO
			return
		"pursuit":
			path = astar_grid.get_id_path(tile_map.local_to_map(global_position), player_position)
			speed = run_speed
		"searching":
			path = astar_grid.get_id_path(tile_map.local_to_map(global_position), player_position)
			speed = walk_speed

	for occupoed_position in occupied_positions:
		astar_grid.set_point_solid(occupoed_position, false)

	if path.is_empty():
		return

	var path_size: int = path.size()

	if path_size > 2:
		direction_vector = path[1] - path[0]
	elif path_size == 2:
		look_vector = path[1] - path[0]
		direction_vector = Vector2.ZERO
		if player_in_area == false:
			state = "idle"
	else:
		direction_vector = Vector2.ZERO

	if direction_vector != Vector2.ZERO:

		target_position = global_position + direction_vector * step_distance
		is_moving = true
		look_vector = Vector2.ZERO
		last_direction = direction_vector


func _physics_process(delta: float) -> void:

	if not is_moving:
		last_position = global_position
		update_direction()
		move_in_direction()

	if is_moving:
		var distance_to_target: Vector2 = target_position - global_position
		if distance_to_target.length() < speed * delta:
			global_position = target_position
			is_moving = false
			look_vector = direction_vector
			direction_vector = Vector2.ZERO
		else:
			var collisionVar: KinematicCollision2D = move_and_collide(distance_to_target.normalized() * speed * delta)
			if collisionVar != null:
				print(collisionVar)
				target_position = last_position
			else:
				move_and_collide(distance_to_target.normalized() * speed * delta)


func _on_detection_area_body_entered(body: CharacterBody2D) -> void:
	if body.has_method("player"):
		player_in_area = true
		player = body
		state = "pursuit"
		speed = run_speed
		$DetectionArea/CollisionShape2D.shape.radius = 544.0

func _on_detection_area_body_exited(body: CharacterBody2D) -> void:
	if body.has_method("player"):
		player_in_area = false
		is_running = false
		state = "searching"
		speed = walk_speed
		$DetectionArea/CollisionShape2D.shape.radius = 352
