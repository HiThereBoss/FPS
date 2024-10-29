class_name GunResource
extends Resource

@export var name: String

@export_category("Weapon Orientation")
@export var position: Vector3
@export var rotation: Vector3
@export var scale: Vector3

@export_category("Weapon Visuals")
@export var scene: PackedScene

@export_category("Animations")
@export var arm_reload: String
@export var arm_reload_empty: String
@export var arm_fire: String
@export var arm_aim_in: String
