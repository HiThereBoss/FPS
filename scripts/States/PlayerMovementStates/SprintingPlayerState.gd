class_name SprintingPlayerState
extends PlayerMovementState

@export var SPEED = 7.0
@export_range(0,1,0.05) var ACCELERATION = 0.1
@export_range(0,1,0.05) var DECELERATION = 0.25

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION, delta)
	PLAYER.update_velocity()
	
	PLAYER.camera.transform.origin = Global.player._headbob("Camera", 2.7)
	PLAYER.rig.position = Global.player._headbob("Rig", 1.35)
	
	if Input.is_action_pressed("slow_down") and PLAYER.is_on_floor():
		transition.emit("SlowWalkingPlayerState")
		
	if Input.is_action_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	
	if Input.is_action_just_released("sprint"):
		transition.emit("WalkingPlayerState")

