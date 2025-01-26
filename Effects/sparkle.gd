extends Node2D

@onready var animation = $AnimatedSprite2D
@onready var timer = $Timer
var random_speed = 100
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play()
	timer.start()
	random_speed = randi_range(80, 100)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y = move_toward(position.y, -1, random_speed * delta)

func _on_timer_timeout() -> void:
	queue_free()
