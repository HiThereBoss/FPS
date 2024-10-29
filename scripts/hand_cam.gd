extends Camera3D

@onready var rig = $rig
#@onready var primary_animation_player = %primary_slot.get_child(0).animationplayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rig.position.x = lerp(rig.position.x, 0.0, delta*8)
	rig.position.y = lerp(rig.position.y, 0.0, delta*8)
	
	#if Input.is_action_just_pressed("reload"):
		#primary_animation_player.play("Reload")

func sway(sway_amount):
	rig.position.x += sway_amount.x * 0.0005
	rig.position.y += sway_amount.y * 0.0005


