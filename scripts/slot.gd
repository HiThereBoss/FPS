extends Node3D
class_name Slot

@export_range(1,2) var SLOT:int
@export var WEAPON: GunResource
var child: Node3D
signal item_loaded(item_type: String, object: Node3D, slot:int)

func _ready():
	if SLOT == 1:
		call_deferred("load_weapon")

func load_weapon():
	var instance = WEAPON.scene.instantiate()
	self.add_child(instance)
	
	item_loaded.emit(instance.type, self, SLOT)
	
	instance.position = WEAPON.position
	instance.rotation = WEAPON.rotation
	instance.scale = WEAPON.scale
	
	instance.link(Global.player)
	
	child = self.get_child(0)

func offload_weapon():
	self.remove_child(self.get_child(0))

func fire():
	child.shoot()

func try_fire() -> bool:
	return child.try_shoot()

func is_shooting() -> bool:
	return child.animationplayer.is_playing()

func reload():
	child.animationplayer.play("Reload")

func done_reloading() -> bool:
	return !child.animationplayer.is_playing()

func reset_shot_number():
	child.shot_number = 0

func reset_anim_speed():
	child.animationplayer.speed_scale = 1.0
