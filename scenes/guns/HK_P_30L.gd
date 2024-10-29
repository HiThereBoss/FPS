extends gun

# Called when the node enters the scene tree for the first time.
func _ready():
	animationplayer = $GunAnim
	muzzleanimationplayer = $gun_rig/muzzle_flash/AnimationPlayer
	gun_barrel = $gun_rig/Skeleton3D/ray
