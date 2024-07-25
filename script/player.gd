extends CharacterBody2D

var walk_speed: int = 200 #Default character speed
var run_speed: int = 400 #Speed when player hold shift
var speed: int = walk_speed #S
var step_distance: int = 64 #Grid size
var is_walking: bool = false #If True, speed = walk_speed
var is_running: bool = false #If True, speed = run_speed
var is_moving: bool = false #If True, lock player movement
var direction_vector: Vector2 = Vector2.ZERO #Direction of character to move or look
var target_position: Vector2 = Vector2.ZERO #Store next position to move
var key_buffer: Array[String] = [] #Store all movement Inputs. Last one is used to update direction
@export var tile_map: TileMap #Store active tilemap
@export var player_marker: CollisionShape2D
@export var ray_cast_2d: RayCast2D
@export var movement_timer: float #Check how long movement Input was pressed
#var tile_coord: Vector2
var last_position: Vector2


func _ready() -> void:
	#Reset movement target tile
	target_position = global_position

func _input(event: InputEvent) -> void:
	#Check if Shift is pressed and modify movement speed
	if event.is_action_pressed("shift"):
		is_running = true
		speed = run_speed
		
	#Check if Shift was released and modify movement speed
	if event.is_action_released("shift"):
		speed = walk_speed
		is_running = false
	
	if event.is_action_pressed("up"):
		key_buffer.append("up")
		movement_timer = 0
	elif event.is_action_pressed("down"):
		key_buffer.append("down")
		movement_timer = 0
	elif event.is_action_pressed("left"):
		key_buffer.append("left")
		movement_timer = 0
	elif event.is_action_pressed("right"):
		key_buffer.append("right")
		movement_timer = 0

	if event.is_action_released("up"):
		key_buffer.erase("up")
	elif event.is_action_released("down"):
		key_buffer.erase("down")
	elif event.is_action_released("left"):
		key_buffer.erase("left")
	elif event.is_action_released("right"):
		key_buffer.erase("right")

func move_in_direction() -> void:
	
	if direction_vector != Vector2.ZERO:
		target_position = global_position + direction_vector * step_distance
		var current_tile: Vector2i = tile_map.local_to_map(global_position)
		var target_tile: Vector2i = Vector2i(
			current_tile.x + direction_vector.x,
			current_tile.y + direction_vector.y,
			)
		var tile_data: TileData = tile_map.get_cell_tile_data(0, target_tile)
		if tile_data == null or tile_data.get_custom_data("walkable") == false:
			return
		
		is_moving = true
		look_in_direction()


func look_in_direction() -> void:
	ray_cast_2d.target_position = direction_vector * step_distance


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


func _physics_process(delta: float) -> void:
	if key_buffer.size() > 0 and is_moving == false:

		movement_timer += delta

		update_direction()

		if movement_timer <= 0.08:
			look_in_direction()
		else:
			move_in_direction()
	else:
		direction_vector = Vector2.ZERO
	
	
	if not is_moving:
		last_position = global_position
	
	if is_moving:
		var distance_to_target: Vector2 = target_position - global_position
		if distance_to_target.length() < speed * delta:
			global_position = target_position
			is_moving = false
		else:
			#global_position += distance_to_target.normalized() * speed * delta
			
			var collisionVar: KinematicCollision2D = move_and_collide(distance_to_target.normalized() * speed * delta)
			if collisionVar != null:
				print(collisionVar)
				target_position = last_position
			else:
				move_and_collide(distance_to_target.normalized() * speed * delta)
				
func player() -> void:
	pass
