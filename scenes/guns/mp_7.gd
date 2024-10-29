extends gun

# Called when the node enters the scene tree for the first time.
func _ready():
	animationplayer = $AnimationPlayer
	muzzleanimationplayer = $muzzle_flash/AnimationPlayer
	gun_barrel = $Mesh/ray
