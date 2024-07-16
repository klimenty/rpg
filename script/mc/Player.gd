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

func _ready():
	target_position = global_position

func _input(event):
	if event.is_action_pressed("sprint"):
		is_running = true
		speed = run_speed
	
	if event.is_action_released("sprint"):
		speed = walk_speed
		is_running = false
	
	if event.is_action_pressed("ui_up"):
		key_buffer.append("ui_up")
	elif event.is_action_pressed("ui_down"):
		key_buffer.append("ui_down")
	elif event.is_action_pressed("ui_left"):
		key_buffer.append("ui_left")
	elif event.is_action_pressed("ui_right"):
		key_buffer.append("ui_right")

	if event.is_action_released("ui_up"):
		key_buffer.erase("ui_up")
	elif event.is_action_released("ui_down"):
		key_buffer.erase("ui_down")
	elif event.is_action_released("ui_left"):
		key_buffer.erase("ui_left")
	elif event.is_action_released("ui_right"):
		key_buffer.erase("ui_right")

	if not is_moving:
		update_direction()
		

func update_direction():
	if key_buffer.size() > 0:
		var last_key = key_buffer.back()

		match last_key:
			"ui_up":
				direction_vector = Vector2(0, -1)
			"ui_down":
				direction_vector = Vector2(0, 1)
			"ui_left":
				direction_vector = Vector2(-1, 0)
			"ui_right":
				direction_vector = Vector2(1, 0)
				
		last_direction = direction_vector
		move_in_direction()
	else:
		direction_vector = Vector2.ZERO


func move_in_direction():
	if direction_vector != Vector2.ZERO:
		target_position = global_position + direction_vector * step_distance
		is_moving = true


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
		
	play_animation(direction_vector)


	
func play_animation(direction):
	if direction == Vector2.ZERO:
		match last_direction:
			Vector2.UP:
				$AnimatedSprite2D.play("idle_up")
			Vector2.DOWN:
				$AnimatedSprite2D.play("idle_down")
			Vector2.LEFT:
				$AnimatedSprite2D.play("idle_left")
			Vector2.RIGHT:
				$AnimatedSprite2D.play("idle_right")
	elif is_running:	
		match direction:
			Vector2.UP:
				$AnimatedSprite2D.play("running_up")
			Vector2.DOWN:
				$AnimatedSprite2D.play("running_down")
			Vector2.LEFT:
				$AnimatedSprite2D.play("running_left")
			Vector2.RIGHT:
				$AnimatedSprite2D.play("running_right")
	else:
		match direction:
			Vector2.UP:
				$AnimatedSprite2D.play("walking_up")
			Vector2.DOWN:
				$AnimatedSprite2D.play("walking_down")
			Vector2.LEFT:
				$AnimatedSprite2D.play("walking_left")
			Vector2.RIGHT:
				$AnimatedSprite2D.play("walking_right")
			
func player():
	pass
