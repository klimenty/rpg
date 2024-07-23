extends CharacterBody2D

var walk_speed = 200
var run_speed = 400
var speed = 200
var step_distance = 64
var is_walking = false
var is_running = false
var is_moving = false
var direction_vector = Vector2.ZERO
var target_position = Vector2.ZERO
var key_buffer = []
var last_direction: Vector2
@export var tile_map: TileMap
@export var player_marker: CollisionShape2D
@export var ray_cast_2d: RayCast2D


func _ready():
	target_position = global_position

func _input(event):
	
	if event.is_action_pressed("shift"):
		is_running = true
		speed = run_speed
	
	if event.is_action_released("shift"):
		speed = walk_speed
		is_running = false
	
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

	if not is_moving:
		update_direction()
			

func update_direction():
	if key_buffer.size() > 0:
		var last_key = key_buffer.back()

		match last_key:
			"up":
				direction_vector = Vector2(0, -1)
			"down":
				direction_vector = Vector2(0, 1)
			"left":
				direction_vector = Vector2(-1, 0)
			"right":
				direction_vector = Vector2(1, 0)
				
		last_direction = direction_vector
		move_in_direction()
	else:
		direction_vector = Vector2.ZERO


func move_in_direction():
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
		ray_cast_2d.target_position = direction_vector * step_distance
		
		


func _physics_process(delta):
	if is_moving:
		var distance_to_target = target_position - global_position
		if distance_to_target.length() < speed * delta:
			global_position = target_position
			is_moving = false
			if key_buffer.size() > 0:
				update_direction()
			else:
				direction_vector = Vector2.ZERO
		else:
			global_position += distance_to_target.normalized() * speed * delta
		
	#play_animation(direction_vector)


	
#func play_animation(direction):
	#if direction == Vector2.ZERO:
		#match last_direction:
			#Vector2.UP:
				#$AnimatedSprite2D.play("idle_up")
			#Vector2.DOWN:
				#$AnimatedSprite2D.play("idle_down")
			#Vector2.LEFT:
				#$AnimatedSprite2D.play("idle_left")
			#Vector2.RIGHT:
				#$AnimatedSprite2D.play("idle_right")
	#elif is_running:	
		#match direction:
			#Vector2.UP:
				#$AnimatedSprite2D.play("running_up")
			#Vector2.DOWN:
				#$AnimatedSprite2D.play("running_down")
			#Vector2.LEFT:
				#$AnimatedSprite2D.play("running_left")
			#Vector2.RIGHT:
				#$AnimatedSprite2D.play("running_right")
	#else:
		#match direction:
			#Vector2.UP:
				#$AnimatedSprite2D.play("walking_up")
			#Vector2.DOWN:
				#$AnimatedSprite2D.play("walking_down")
			#Vector2.LEFT:
				#$AnimatedSprite2D.play("walking_left")
			#Vector2.RIGHT:
				#$AnimatedSprite2D.play("walking_right")
			#
#func player():
	#pass

