extends Node2D

var key_buffer: Array[String] = [] #Store all movement Inputs. Last one is used to update direction
var direction_vector: Vector2 = Vector2.ZERO
@export var tile_map: TileMap
@export var sprite_2d: Sprite2D
@export var ray_cast_2d: RayCast2D
var is_moving: bool = false

func _input(event: InputEvent) -> void:
	#Check if Shift is pressed and modify movement speed
	#if event.is_action_pressed("shift"):
		#pass
		
	#Check if Shift was released and modify movement speed
	#if event.is_action_released("shift"):
		#pass
	
	if event.is_action_pressed("up"):
		key_buffer.append("up")
	elif event.is_action_pressed("down"):
		key_buffer.append("down")
	elif event.is_action_pressed("left"):
		key_buffer.append("left")
	elif event.is_action_pressed("right"):
		key_buffer.append("right")

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
	if is_moving:
		sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, 5)
		if global_position == sprite_2d.global_position:
			is_moving = false
			return
		
	
	if not is_moving:
		if key_buffer.size() > 0:
			update_direction()
		else:
			direction_vector = Vector2(0, 0)
		move(direction_vector)


func update_direction() -> void:
	var last_key: String = key_buffer.back()
	
	match last_key:
		"up":
			direction_vector = Vector2(0, -1)
		"down":
			direction_vector = Vector2(0, 1)
		"left":
			direction_vector = Vector2(-1, 0)
		"right":
			direction_vector = Vector2(1, 0)

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
	
	if tile_data == null or tile_data.get_custom_data("walkable") == false:
		return
	
	ray_cast_2d.target_position = direction_vector * 64
	ray_cast_2d.force_raycast_update()
	
	if ray_cast_2d.is_colliding():
		return
	
	#move player
	is_moving = true
	
	global_position = tile_map.map_to_local(target_tile)
	
	sprite_2d.global_position = tile_map.map_to_local(current_tile)
	
