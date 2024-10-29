extends Node3D
class_name gun

@export_category("Weapon Settings")
@export var type: String
@export var vertical_recoil: int
@export var horizontal_recoil: int
@export var kick: int
@export var rpm: int
@export var fire_modes: String

@export var scope_factor: int = 1.0
@export var aim_speed = 0.5

# should be declared with each gun under their _ready() function
var animationplayer: AnimationPlayer
var muzzleanimationplayer: AnimationPlayer
var gun_barrel

var curr_fire_mode
var curr_fire_mode_index
var fire_modes_arr: Array = []
var fire_mode_dict = {
	"A": 999,
	"III": 3,
	"II": 2,
	"S": 1
}

var max_shots: int
var shot_number: int = 0

# player stuff
var camera
var head
var player

var instance
var bullet = load("res://scenes/guns/bullet.tscn")

var muzzle_flash = load("res://scenes/guns/muzzle_flash_improved.tscn")
@export var smoke_emitters: Array[RayCast3D]
var smoke_particle_emitters = {}

var finalPosition: Vector3
var currentPosition: Vector3
var returnSpeed = 8
var recoilSpeed = 4

func link(_player):
	print("linked ", name)
	player = Global.player
	head = player.head
	camera = player.camera
	
	for smoke_emitter in smoke_emitters:
		smoke_particle_emitters[smoke_emitter.name] = smoke_emitter.get_node("GPUParticles3D")
	
	for fire_mode in fire_modes.split("/"):
		fire_modes_arr.append(fire_mode)

	curr_fire_mode = fire_modes_arr[0]
	curr_fire_mode_index = 0
	max_shots = fire_mode_dict[curr_fire_mode]
	
	player._gun = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if camera != null:
		finalPosition = lerp(finalPosition, Vector3.ZERO, returnSpeed * delta)
		currentPosition = lerp(currentPosition, finalPosition, recoilSpeed * delta)
		head.rotation_degrees.x = currentPosition.x
		camera.rotation_degrees.y = currentPosition.y

func recoil():
	finalPosition.x += randf_range(vertical_recoil*0.5, vertical_recoil)
	finalPosition.y += randf_range(-horizontal_recoil, horizontal_recoil)

func try_shoot() -> bool:
	if !animationplayer.is_playing():
		if shot_number < max_shots:
			shoot()
			return true
		else: return false
	else: return false

func shoot():
	shot_number += 1
	
	recoil()
	Global.player.add_trauma(0.5)
	
	for emitter in smoke_particle_emitters:
		if !smoke_particle_emitters[emitter].emitting:
			smoke_particle_emitters[emitter].emitting = true
		else:
			smoke_particle_emitters[emitter].emitting = false
			smoke_particle_emitters[emitter].emitting = true
	
	animationplayer.speed_scale = 1 #animationplayer.get_animation("Shoot").length * (rpm/60.0)
	animationplayer.play("Shoot")
	
	instance = bullet.instantiate()
	instance.position = gun_barrel.global_position
	instance.transform.basis = gun_barrel.global_transform.basis
	instance.transform.basis.z= -gun_barrel.global_transform.basis.z
	get_tree().current_scene.add_child(instance)

func switch_fire_mode():
	if curr_fire_mode_index < fire_modes_arr.size()-1:
		curr_fire_mode_index += 1
	else:
		curr_fire_mode_index = 0
	
	curr_fire_mode = fire_modes_arr[curr_fire_mode_index]
	max_shots = fire_mode_dict[curr_fire_mode]




