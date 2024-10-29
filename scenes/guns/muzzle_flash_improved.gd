extends Node3D

@export var max_distance = 1.0

@onready var gpu_particles: GPUParticles3D = $GPUParticles3D

func _ready():
	gpu_particles.process_material.initial_velocity_max = 5.0 * max_distance
