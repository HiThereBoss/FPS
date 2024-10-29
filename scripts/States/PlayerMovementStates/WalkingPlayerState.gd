class_name WalkingPlayerState

extends PlayerMovementState

@export var SPEED = 5.0
@export_range(0,1,0.05) var ACCELERATION = 0.1
@export_range(0,1,0.05) var DECELERATION = 0.25

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION, delta)
	PLAYER.update_velocity()
	
	if PLAYER.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")
	
	PLAYER.camera.transform.origin = PLAYER._headbob("Camera", 1)
	PLAYER.rig.position = PLAYER._headbob("Rig", 0.5)
	
	if Input.is_action_pressed("sprint") and PLAYER.is_on_floor():
		transition.emit("SprintingPlayerState")
	
	if Input.is_action_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
		
	if Input.is_action_pressed("slow_down") and PLAYER.is_on_floor():
		transition.emit("SlowWalkingPlayerState")

