## This is a player-focused input node that inherits from base INPUT class. 
class_name PLAYER_INPUT extends INPUT


	
func handleMoveInputs(delta):
	
	#aInput = Input.is_action_just_pressed("a")
	runInput = Input.is_action_pressed("shift")
	stealthInput = Input.is_action_pressed("ctrl")
	
	if Input.is_action_pressed("up"):
		key_buffer.append("up")
	elif Input.is_action_pressed("down"):
		key_buffer.append("down")
	elif Input.is_action_pressed("left"):
		key_buffer.append("left")
	elif Input.is_action_pressed("right"):
		key_buffer.append("right")

	if Input.is_action_just_released("up"):
		key_buffer.erase("up")
	elif Input.is_action_just_released("down"):
		key_buffer.erase("down")
	elif Input.is_action_just_released("left"):
		key_buffer.erase("left")
	elif Input.is_action_just_released("right"):
		key_buffer.erase("right")
	
	if key_buffer.size() > 0:
		var last_key = key_buffer.back()

		match last_key:
			"up":
				moveInput = Vector2i(0, -1)
			"down":
				moveInput = Vector2i(0, 1)
			"left":
				moveInput = Vector2i(-1, 0)
			"right":
				moveInput = Vector2i(1, 0)
	else:
		moveInput = Vector2i.ZERO
	#print("PlayerInputController moveInput:", moveInput)
	print(key_buffer)
