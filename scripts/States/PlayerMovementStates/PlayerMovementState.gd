class_name PlayerMovementState
extends State

var PLAYER: Player
@export var ANIMATION_TREE: AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	await owner.ready
	PLAYER = owner as Player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
