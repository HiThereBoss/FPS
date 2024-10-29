extends GunRigState


func enter(_previous_state):
	rig_manager.play_reload()

func update(delta):
	if rig_manager.CURRENT_SLOT.done_reloading():
		transition.emit("IdleRigState")
