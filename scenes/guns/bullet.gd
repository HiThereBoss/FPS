extends Node3D

@export var speed = 90.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var terrain_particles = get_tree().current_scene.get_node("Player").terrain_particles
@onready var bullet_decal = get_tree().current_scene.get_node("Player").bullet_decal


func _process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
	
	if ray.is_colliding():
		var col_point = ray.get_collision_point()
		var normal = ray.get_collision_normal()
		
		var terrain_particle = terrain_particles.instantiate()
		terrain_particle.global_position = col_point
		get_tree().current_scene.add_child(terrain_particle)
		
		terrain_particle.look_at(col_point + normal, Vector3.UP)
		terrain_particle.look_at(col_point + normal, Vector3.RIGHT)
		
		var bulletdecal = bullet_decal.instantiate()
		bulletdecal.global_position = col_point
		get_tree().current_scene.add_child(bulletdecal)
		
		bulletdecal.look_at(col_point + normal, Vector3.UP)
		bulletdecal.look_at(col_point + normal, Vector3.RIGHT)
		
		queue_free()
