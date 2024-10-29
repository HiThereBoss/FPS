class_name RigManager
extends Node3D

@export var slots: Array[Node3D]

@onready var arm_anim_player: AnimationPlayer = $fps_rig/ArmsAnimPlayer

@onready var primary_slot = self.get_parent().get_node("%primary_slot")

var CURRENT_WEAPON_TYPE: String
var CURRENT_SLOT: Node3D

var SLOTS = {
	1: null,
	2: null
}

func _ready():
	for slot:Slot in slots:
		SLOTS[slot.SLOT] = slot
		slot.item_loaded.connect(_on_item_loaded)
		
	CURRENT_SLOT = SLOTS[1]

func _on_item_loaded(item_type, object, slot):
	CURRENT_WEAPON_TYPE = item_type
	CURRENT_SLOT = SLOTS[slot]
	play_idle()

func play_idle():
	var arm_anim_player: AnimationPlayer = $fps_rig/ArmsAnimPlayer
	if arm_anim_player.is_playing():
		arm_anim_player.stop()
	arm_anim_player.play("FP_idle_" + CURRENT_WEAPON_TYPE)

func play_fire():
	if arm_anim_player.is_playing():
		arm_anim_player.stop()
	arm_anim_player.speed_scale = CURRENT_SLOT.get_child(0).animationplayer.speed_scale
	arm_anim_player.play("FP_fire_" + CURRENT_WEAPON_TYPE)

func play_reload():
	if arm_anim_player.is_playing():
		arm_anim_player.stop()
	arm_anim_player.play("FP_reload_" + CURRENT_WEAPON_TYPE)
	
	CURRENT_SLOT.reload()

func reset_anim_speed():
	arm_anim_player.speed_scale = 1.0
	CURRENT_SLOT.reset_anim_speed()

func switch(slot: int):
	CURRENT_SLOT.offload_weapon()
	CURRENT_SLOT = SLOTS[slot]
	CURRENT_SLOT.load_weapon()
