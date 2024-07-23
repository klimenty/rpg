extends CharacterBody2D

@onready var tile_map = $"../TileMap"

var speed: int = 50
var walk_speed: int = 50
var run_speed: int = 75
var step_distance = 64
var is_running = false
@export var health = 100
@export var attack = 1


var dead = false
var player_in_area = false
var player
var player_position: Vector2i
var player_last_position: Vector2i

var astar_grid = AStarGrid2D
var is_moving = false
var target_position: Vector2 = Vector2.ZERO
var direction_vector: Vector2 = Vector2.ZERO
var idle_vector: Vector2 = Vector2.DOWN
var last_direction: Vector2 = Vector2.ZERO
var path

func _ready():
	dead = false
	astar_grid = AStarGrid2D.new()
	astar_grid.cell_size = Vector2i(64, 64)
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	

func _physics_process(delta):
	if dead:
		$DetectionArea/CollisionShape2D.disabled = true

		
		
			#play_animation(direction_vector)
	
	if not dead:
		$DetectionArea/CollisionShape2D.disabled = false
		
		if is_moving:
			var distance_to_target = target_position - global_position
			if distance_to_target.length() < speed * delta:
				global_position = target_position
				is_moving = false
				idle_vector = direction_vector
				direction_vector = Vector2.ZERO
			else:
				global_position += distance_to_target.normalized() * speed * delta
		
		else:
			move()
		play_animation(direction_vector)



func move():
	if is_moving:
		return
	
	if player_in_area:
		player_position = tile_map.local_to_map(player.position)
#		if player_position != player_last_position:
#			player_last_position = player_position
		
	path = astar_grid.get_id_path(tile_map.local_to_map(global_position), player_position)
	
	print(path)
	
	if path.is_empty():
		return
	
	var path_size: int = path.size()
	
	if path_size > 5:
		is_running = true
		speed = run_speed
	else:
		is_running = false
		speed = walk_speed
	
	if path.size() > 2:
		direction_vector = path[1] - path[0]
	elif path.size() == 2:
		idle_vector = path[1] - path[0]
		direction_vector = Vector2.ZERO
	else:
		direction_vector = Vector2.ZERO
		
	if direction_vector != Vector2.ZERO:
		
		target_position = global_position + direction_vector * step_distance
		is_moving = true
		idle_vector = Vector2.ZERO
		last_direction = direction_vector
		


func _on_detection_area_body_entered(body):
	if body.has_method("player"):
		player_in_area = true
		player = body
		$DetectionArea/CollisionShape2D.shape.radius = 544.0

func _on_detection_area_body_exited(body):
	if body.has_method("player"):
		player_in_area = false
		is_running = false
#		idle_vector = direction_vector
#		direction_vector = Vector2.ZERO
		$DetectionArea/CollisionShape2D.shape.radius = 352
		


func play_animation(direction_vector):
	if health <= 0:
		$AnimatedSprite2D.play("death")
		return
	if direction_vector == Vector2.ZERO:
		match idle_vector:
			Vector2.UP:
				$AnimatedSprite2D.play("idle_up")
			Vector2.DOWN:
				$AnimatedSprite2D.play("idle_down")
			Vector2.LEFT:
				$AnimatedSprite2D.play("idle_left")
			Vector2.RIGHT:
				$AnimatedSprite2D.play("idle_right")
	elif is_running:	
		match direction_vector:
			Vector2.UP:
				$AnimatedSprite2D.play("running_up")
			Vector2.DOWN:
				$AnimatedSprite2D.play("running_down")
			Vector2.LEFT:
				$AnimatedSprite2D.play("running_left")
			Vector2.RIGHT:
				$AnimatedSprite2D.play("running_right")
	else:
		match direction_vector:
			Vector2.UP:
				$AnimatedSprite2D.play("walking_up")
			Vector2.DOWN:
				$AnimatedSprite2D.play("walking_down")
			Vector2.LEFT:
				$AnimatedSprite2D.play("walking_left")
			Vector2.RIGHT:
				$AnimatedSprite2D.play("walking_right")


func take_damage(amount: int) -> void:
	health -= amount
