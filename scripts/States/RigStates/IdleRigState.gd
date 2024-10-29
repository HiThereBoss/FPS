class_name IdleRigState
extends GunRigState

func enter(_previous_state):
	rig_manager.play_idle()
	rig_manager.reset_anim_speed()

func update(delta):
	if Input.is_action_just_pressed("shoot"):
		transition.emit("FiringRigState")
	
	if Input.is_action_just_pressed("reload"):
		transition.emit("ReloadingRigState")
