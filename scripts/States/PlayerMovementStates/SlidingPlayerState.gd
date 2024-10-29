class_name SlidingPlayerState
extends PlayerMovementState

@export var SPEED = 5.0
@export_range(0,1,0.05) var ACCELERATION = 0.1
@export_range(0,1,0.05) var DECELERATION = 0.25
@export var TILT_AMOUNT = 5.0
@export_range(1,6,0.1) var SLIDE_ANIM_SPEED = 4

@onready var CROUCH_SHAPECAST: ShapeCast3D = %CrouchCast

# Called when the node enters the scene tree for the first time.
func enter(previous_state):
	set_tilt(PLAYER._current_rotation)

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_velocity()

func set_tilt(player_rotation) -> void:
	var tilt = Vector3.ZERO
	tilt.z = clamp(TILT_AMOUNT * player_rotation, -0.1, 0.1)
	if tilt.z == 0.0:
		tilt.z == 0.05
	
