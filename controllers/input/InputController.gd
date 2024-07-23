## This is a basic input node from which all will inherit. 
class_name INPUT extends Node2D

var moveInput: Vector2i	## Left and Right movement float. 
var key_buffer: Array[String]
var runInput: bool
var stealthInput: bool
#var aInput: bool

#/
## Return the Move Input float. 
func getMoveInput() -> Vector2i:
	return moveInput

#/
## Return the Jump Input bool. 
#func getRunInput() -> bool:
	#return runInput
	
	
## Return the Jump Input bool. 
#func getStealthInput() -> bool:
	#return stealthInput
#/
## Base function to handle inputs. 
#func handleMoveInputs(delta): 
#	pass
