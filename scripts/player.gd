class_name Player
extends CharacterBody3D

var jump_speed

@export_category("Basic Settings")
@export var JUMP_VELOCITY = 4.5
@export var SLOW_WALK_JUMP = 3.0
@export var cam_sensitivity = 0.25

@export_category("Camera Shake Settings")
@export var trauma_reduction_rate := 1.0

@export var max_z := 5.0

@export var noise : FastNoiseLite
@export var noise_speed := 50.0

@export_category("Lean settings")
@export_range(0.0, 1.0) var lean_duration: float = 0.2
enum {LEFT = -1, CENTER = 0, RIGHT = 1}
var lean_tween

var trauma := 0.0
var max_y = 3
var time := 0.0

@onready var head = $Head
@onready var camera = $Head/Neck/Camera3D
@onready var initial_rotation := camera.rotation_degrees as Vector3
@onready var hand_cam = $Head/Neck/Camera3D/SubViewportContainer/SubViewport/hand_cam

var _current_rotation: float

var base_fov = 75.0
const FOV_CHANGE = 1.5

# bob
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# gun
var bullet = load("res://scenes/guns/bullet.tscn")
var instance

var bullet_decal = preload("res://scenes/bullet_decal.tscn")
var terrain_particles = preload("res://scenes/terrain_particles.tscn")
# enemy particles added here

@onready var rig = $Head/Neck/Camera3D/SubViewportContainer/SubViewport/hand_cam/rig
@onready var _gun = rig.get_node("%primary_slot").get_child(0)
@onready var rig_anim = rig.get_node("RigAnimPlayer")
@onready var rig_manager = rig.get_node("RigManager")
var aiming = false
var aiming_animation = false

@onready var animation_tree = $AnimationTree
@onready var lean_right_collider = $Head/lean_right_collider
@onready var lean_left_collider = $Head/lean_left_collider

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Global.player = self
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Head/Neck/Camera3D/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	#_gun.link(self)

func _input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(deg_to_rad(-event.relative.x * cam_sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * cam_sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(75))
		
		_current_rotation = -event.relative.x * cam_sensitivity
		
		if !aiming:
			hand_cam.sway(-Vector2(event.relative.x * 0.6, event.relative.y * 0.4))
		else:
			hand_cam.sway(-Vector2(event.relative.x * 0.1, event.relative.y * 0.1))

func _physics_process(delta):	
	$Head/Neck/Camera3D/SubViewportContainer/SubViewport/hand_cam.global_transform = camera.global_transform
	
	lean_collision_check()
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		lean(CENTER)
	
	# Smooth jumping for rig/handcam
	if !aiming:
		hand_cam.sway(Vector3(0,-velocity.y*1.5,0))
	else:
		hand_cam.sway(Vector3(0,-velocity.y*0.3,0))
	
	#if is_on_floor():
		## Slow walking
		#if Input.is_action_pressed("slow_down"):
			#speed = SLOW_WALK_SPEED
			#jump_speed = SLOW_WALK_JUMP
		## Sprinting
		#elif Input.is_action_pressed("sprint"):
			#speed = SPRINT_SPEED
		#else:
			#speed = WALK_SPEED
			#jump_speed = JUMP_VELOCITY
	#elif (speed != SPRINT_SPEED or speed != SLOW_WALK_SPEED):
		#speed = WALK_SPEED
		#jump_speed = JUMP_VELOCITY
	#
	#if Input.is_action_pressed("shoot"):
		#_gun.shoot()
	
	if Input.is_action_just_pressed("aim"):
		rig_anim.speed_scale = rig_anim.get_animation("Aim_in").length / _gun.aim_speed
		rig_anim.play("Aim_in")
		aiming_animation = true
		var timer = get_tree().create_timer(_gun.aim_speed * 0.3)
		await timer.timeout
		aiming = true
	
	if Input.is_action_just_released("aim"):
		rig_anim.speed_scale = rig_anim.get_animation("Aim_in").length / _gun.aim_speed
		rig_anim.play_backwards("Aim_in")
		aiming_animation = false
		aiming = false
	
	if Input.is_action_just_released("lean_left") or Input.is_action_just_released("lean_right"):
		if Input.is_action_pressed("lean_left"):
			lean(LEFT)
		elif Input.is_action_pressed("lean_right"):
			lean(RIGHT)
		else:
			lean(CENTER)
	
	if Input.is_action_just_pressed("lean_left"):
		lean(LEFT)
	if Input.is_action_just_pressed("lean_right"):
		lean(RIGHT)
	
	if Input.is_action_just_pressed("primary"):
		rig_manager.switch(1)
	if Input.is_action_just_pressed("secondary"):
		rig_manager.switch(2)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	
	
	
	# timer to run through a sine curve for bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	
	# FOV
	calculate_fov(delta)
	

func _headbob(object, mult) -> Vector3:
	var pos: Vector3
	if object == "Camera":
		pos = Vector3.ZERO
		pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP * mult
		pos.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP * mult
		
	elif object == "Rig":
		pos = rig.position
		if !aiming: pos.x += cos(t_bob * BOB_FREQ / 2) * BOB_AMP * mult * 0.01
		else: pos.x += cos(t_bob * BOB_FREQ / 2) * BOB_AMP * mult * 0.005
	return pos

func _process(delta):
	# Shake
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	#if max_x * get_shake_intensity() * get_noise_from_seed(0) > 5.0:
		#head.rotation_degrees.x = initial_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	camera.rotation_degrees.y = initial_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
	camera.rotation_degrees.z = initial_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)

# Custom functions
func update_gravity(delta) -> void:
	velocity.y -= gravity * delta
	
func update_input(speed:float, acceleration:float, deceleration:float, delta:float) -> void:
	Global.debug.add_property("Velocity", roundf(velocity.length()), 1)
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			if aiming: 
				#speed = max(SLOW_WALK_SPEED, speed*0.7)
				jump_speed = SLOW_WALK_JUMP
			
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
				
		else:
			velocity.x = move_toward(velocity.x, 0, deceleration)
			velocity.z = move_toward(velocity.z, 0, deceleration)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, deceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, deceleration)

func update_velocity() -> void:
	move_and_slide()

func calculate_fov(delta):
	var velocity_clamped = clamp(velocity.length(), 0.0, 18.0)
	var target_fov 
	if !aiming_animation: 
		target_fov = base_fov + FOV_CHANGE * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	else: 
		target_fov = base_fov / _gun.scope_factor
		camera.fov = lerp(camera.fov, target_fov, delta * 4.0)
	

func lean(blend_amount: int):
	if is_on_floor():
		if lean_tween:
			lean_tween.kill()

		lean_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		lean_tween.tween_property(animation_tree, "parameters/lean_blend/blend_amount", blend_amount, lean_duration)

func lean_collision_check():
	animation_tree["parameters/left_blend/blend_amount"] = lerp(
		float(animation_tree["parameters/left_blend/blend_amount"]), float(lean_left_collider.is_colliding()), max(0.1, 0.5-lean_duration)
	)
	animation_tree["parameters/right_blend/blend_amount"] = lerp(
		float(animation_tree["parameters/right_blend/blend_amount"]), float(lean_right_collider.is_colliding()), max(0.1, 0.5-lean_duration)
	)

func add_trauma(trauma_amount : float):
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)

func get_shake_intensity() -> float:
	return trauma * trauma

func get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
