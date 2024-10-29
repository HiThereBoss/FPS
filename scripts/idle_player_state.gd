class_name IdlePlayerState

extends PlayerMovementState

@export var SPEED = 3.0
@export_range(0,1,0.05) var ACCELERATION = 0.1
@export_range(0,1,0.05) var DECELERATION = 0.25

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION, delta)
	PLAYER.update_velocity()
	
	if Input.is_action_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
	
	if PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
		transition.emit("WalkingPlayerState")
	
