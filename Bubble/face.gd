extends CharacterBody2D


var move_speed = 200


var radius = 80 # The radius of the circular area where the face can move
var center_position = Vector2(540, 990)  # The center of the circle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _physics_process(delta):
	var mouse_position = get_global_mouse_position()
	
	# Calculate the direction towards the mouse
	var direction_vector = (mouse_position - position).normalized()
	var destination = position + direction_vector * move_speed * delta
	
	var center_delta = destination - center_position
	if center_delta.length_squared() > radius * radius:
		center_delta = center_delta.normalized() * radius
	position = center_position + center_delta
	
