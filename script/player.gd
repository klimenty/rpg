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
@export var move_up_timer: Timer
@export var move_down_timer: Timer
@export var move_left_timer: Timer
@export var move_right_timer: Timer
var timer: float


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
		#last_direction = Vector2(0, -1)
		#move_up_timer.start()
		key_buffer.append("up")
		timer = 0
	elif event.is_action_pressed("down"):
		#last_direction = Vector2(0, 1)
		#move_down_timer.start()
		key_buffer.append("down")
		timer = 0
	elif event.is_action_pressed("left"):
		#last_direction = Vector2(-1, 0)
		#move_left_timer.start()
		key_buffer.append("left")
		timer = 0
	elif event.is_action_pressed("right"):
		#last_direction = Vector2(1, 0)
		#move_right_timer.start()
		key_buffer.append("right")
		timer = 0

	if event.is_action_released("up"):
		key_buffer.erase("up")
		#move_up_timer.stop()
	elif event.is_action_released("down"):
		key_buffer.erase("down")
		#move_down_timer.stop()
	elif event.is_action_released("left"):
		key_buffer.erase("left")
		#move_left_timer.stop()
	elif event.is_action_released("right"):
		key_buffer.erase("right")
		#move_right_timer.stop()

	#if not is_moving:
		#update_direction()
			

#func update_direction():
	#if key_buffer.size() > 0:
		#if timer >= 100:
			#var last_key = key_buffer.back()
#
			#match last_key:
				#"up":
					#direction_vector = Vector2(0, -1)
				#"down":
					#direction_vector = Vector2(0, 1)
				#"left":
					#direction_vector = Vector2(-1, 0)
				#"right":
					#direction_vector = Vector2(1, 0)
					#
#
			#move_in_direction()
	#else:
		#
		#direction_vector = Vector2.ZERO


func move_in_direction():
	if direction_vector != last_direction:
		ray_cast_2d.target_position = direction_vector * step_distance
		last_direction = direction_vector
		return
	
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
	if key_buffer.size() > 0 and is_moving == false:
		timer += delta
		print(timer)
		
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
		
		if timer >= 0.08:			
			move_in_direction()
		else:
			ray_cast_2d.target_position = direction_vector * step_distance
	else:
		direction_vector = Vector2.ZERO
	
	if is_moving:
		var distance_to_target = target_position - global_position
		if distance_to_target.length() < speed * delta:
			global_position = target_position
			is_moving = false
			#if key_buffer.size() > 0:
				#update_direction()
			#else:
				#direction_vector = Vector2.ZERO
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



func _on_move_up_timer_timeout() -> void:
	key_buffer.append("up")


func _on_move_down_timer_timeout() -> void:
	key_buffer.append("down")


func _on_move_left_timer_timeout() -> void:
	key_buffer.append("left")


func _on_move_right_timer_timeout() -> void:
	key_buffer.append("right")
