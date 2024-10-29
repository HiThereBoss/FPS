extends PlayerMovementState

@export var SPEED = 3.0
@export_range(0,1,0.05) var ACCELERATION = 0.1
@export_range(0,1,0.05) var DECELERATION = 0.25
@export_range(1, 6, 0.1) var CROUCH_SPEED = 4.0

@onready var CROUCH_SHAPECAST: ShapeCast3D = %CrouchCast

var tween: Tween

func enter(_previous_state):
	CROUCH_SHAPECAST.add_exception($"../..")
	if tween:
		tween.kill()

	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(ANIMATION_TREE, "parameters/crouch_blend/blend_amount", 1.0, 1.0/CROUCH_SPEED)

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION, delta)
	PLAYER.update_velocity()
	
	PLAYER.camera.transform.origin = PLAYER._headbob("Camera", 1)
	PLAYER.rig.position = PLAYER._headbob("Rig", 0.5)
	
	if Input.is_action_just_released("crouch") and PLAYER.is_on_floor():
		transition.emit("WalkingPlayerState")

func uncrouch():
	if CROUCH_SHAPECAST.is_colliding() == false and Input.is_action_just_pressed("crouch") == false:
		if tween:
			await tween.finished
		transition.emit("IdlePlayerState")
	elif CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch()

func exit() -> void:
	if tween:
		tween.kill()

	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(ANIMATION_TREE, "parameters/crouch_blend/blend_amount", 0.0, 1.0/CROUCH_SPEED)
