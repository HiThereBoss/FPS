class_name FiringRigState
extends GunRigState

func enter(_previous_state):
	rig_manager.CURRENT_SLOT.fire()
	rig_manager.play_fire()

func update(delta):
	if Input.is_action_pressed("shoot"):
		if rig_manager.CURRENT_SLOT.try_fire():
			rig_manager.play_fire()
	
	if !rig_manager.CURRENT_SLOT.is_shooting():
		transition.emit("IdleRigState")

func exit():
	rig_manager.CURRENT_SLOT.reset_shot_number()
	rig_manager.CURRENT_SLOT.reset_anim_speed()
