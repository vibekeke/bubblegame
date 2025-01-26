extends Node2D

@onready var eyes_anim = $Eyes
@onready var mouth_anim = $Mouth
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	eyes_anim.play("neutral")
	mouth_anim.play("neutral")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
