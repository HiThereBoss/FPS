extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = get_tree().create_timer(10)
	await timer.timeout
	queue_free()

