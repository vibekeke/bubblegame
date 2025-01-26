extends Node2D

@export var pause_wait_time : float = 0.5

@onready var bubble_sprite = $Sprite
@onready var pause_timer = $PettingPauseTimer

#Movement and mechanics
var previous_mouse_position = Vector2()

var mouse_speed = 0
var speed_threshold = 1200
var hovering = false
var mouse_button_down = false

var petting_paused = false
var is_eating = false

#FACE STUFF

var radius = 75  # The radius of the circular area where the face can move
var move_speed = 250
var center_position = position

@onready var face = $Face
@onready var eyes = $Face/Eyes
@onready var mouth = $Face/Mouth
@onready var cheecks = $Face/Mouth


#PROGRESSIONSTUFF
@onready var stress_timer = $StressTimer
var stress_waittime = 1

@onready var loneliness_timer = $LonelinessTimer
var loneliness_waittime = 1.7

@onready var animation_timer = $AnimationTimer
var animation_waittime = 2

var current_mood = "neutral"
var initial_position = Vector2()
var bobbing_amplitude = 10
var bobbing_speed = 1.5
var bobbing_time = 0

var mouse_regular = preload("res://UI/Mouses/pointer_c.png")
var mouse_hand = preload("res://UI/Mouses/hand_thin_open.png")

func _ready():
	initial_position = get_viewport_rect().size/2
	position = initial_position

	eyes.play("neutral")
	mouth.play("neutral")
	
	loneliness_timer.wait_time = loneliness_waittime
	loneliness_timer.start()
	
# Function to detect if the mouse is over the sprite
func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
		
	# Calculate the direction towards the mouse
	var direction_vector = (mouse_position - position).normalized()
	var destination = face.position + (direction_vector * move_speed * delta)
		
	var center_delta = destination - center_position
	if center_delta.length_squared() > radius * radius:
		center_delta = center_delta.normalized() * radius
		
	face.position = face.position.lerp(center_position + center_delta, 0.4)
	#face.position = center_position + center_delta
	
	#Bobbing
	bobbing_time += delta * bobbing_speed
	position.y = initial_position.y + bobbing_amplitude * sin(bobbing_time)
	
	#Petting
	if hovering and mouse_button_down:  # Only process when hovering over the sprite
		var current_mouse_position = get_global_mouse_position()
		mouse_speed = current_mouse_position.distance_to(previous_mouse_position) / delta
		
		# Check if speed exceeds threshold
		if mouse_speed > speed_threshold:
			if not petting_paused:
				pet_bubble()
		# Update previous mouse position
		previous_mouse_position = current_mouse_position


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_button_down = true
		elif event.button_index == 1 and not event.is_pressed():
			mouse_button_down = false

func _on_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(mouse_hand, Input.CURSOR_ARROW, Vector2(16, 16))
	hovering = true

func _on_mouse_exited() -> void:
	print("hoved exited")
	Input.set_custom_mouse_cursor(mouse_regular, Input.CURSOR_ARROW, Vector2(16, 16))
	hovering = false



func pet_bubble():
	#TODO: Legg til hjerter når man petter.

	Stats.petting_progress += 1
	print("Score: ", Stats.petting_progress)
	scale.x += 0.01
	scale.y += 0.01
	
	petting_paused = true

	pause_timer.wait_time = randf_range(pause_wait_time - 0.2, pause_wait_time + 0.3)
	pause_timer.start()
	
	Stats.stress_level += 1
	print("Stress increased: ", Stats.stress_level)
	#TODO: Are we gonna do something with the multiplier, or....
	stress_timer.wait_time = stress_waittime * Stats.food_multiplier * Stats.progress_multiplier
	stress_timer.start()
	
	if Stats.loneliness > 0:
		Stats.loneliness -= 1
		print("loneliness decreased: ", Stats.loneliness)
	
	manage_mood()
	animate_shrink_expand()
	
	Stats.emit_signal("just_pet")
	Stats.update_stats()
	


func manage_mood():
	if Stats.petting_progress > 50:
		victory()
	elif Stats.stress_level > 22:
		death_by_stress()
	elif Stats.loneliness > 17:
		death_by_loneliness()

	if Stats.stress_level > 16:
		current_mood = "stressed"
	elif Stats.stress_level > 12:
		current_mood = "agitated"
	elif Stats.loneliness > 12:
		current_mood = "lonely"
	elif Stats.loneliness > 6:
		current_mood = "sad"
	elif Stats.petting_progress > 27:
		current_mood = "exctatic"
	elif Stats.petting_progress > 10:
		current_mood = "happy"
	else:
		current_mood = "neutral"
	print(current_mood)
	
	update_animation() #TODO: Move this function-call


func _on_petting_pause_timer_timeout() -> void:
	petting_paused = false

func _on_stress_timer_timeout() -> void:
	if Stats.stress_level > 0:
		Stats.stress_level -= 1.5
		print("stress decreased: ", Stats.stress_level)
	stress_timer.wait_time = stress_waittime * Stats.food_multiplier * Stats.progress_multiplier
	stress_timer.start()
	manage_mood()


func _on_loneliness_timer_timeout() -> void:
	Stats.loneliness += 1
	print("loneliness increased: ", Stats.loneliness)
	
	loneliness_timer.wait_time = loneliness_waittime
	loneliness_timer.start()
	manage_mood()


func animate_shrink_expand() -> void:
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	# Shrink the sprite down to 0.8 scale, then expand it back to 1.2, and back to normal scale
	tween.tween_property(bubble_sprite, "scale", Vector2(0.32, 0.32), 0.1)
	tween.tween_property(bubble_sprite, "scale", Vector2(0.38, 0.38), 0.1)
	tween.tween_property(bubble_sprite, "scale", Vector2(0.35, 0.35), 0.1)

var shake_intensity = 3
var shake_speed = 0.1
var shake_duration = 0.3

func animate_death_by_stress():
	pass
	
func update_animation():
	if petting_paused:
		eyes.play(current_mood + "_pet")
	else:
		eyes.play(current_mood)
	
	if not is_eating:
		mouth.play(current_mood)
	

func death_by_stress():
	Stats.deaths_by_stress += 1
	Stats.game_over("stress")
	#Play death animation, await finish
	print("DIED BY STRESS")
	pause_stuff()
	queue_free()

func death_by_loneliness():
	#Play death animation, await finish
	Stats.deaths_by_loneliness += 1
	Stats.game_over("loneliness")
	print("DIED BY LONELINESS")
	pause_stuff()
	queue_free()

func pause_stuff():
	Input.set_custom_mouse_cursor(mouse_regular, Input.CURSOR_ARROW, Vector2(16, 16))
	petting_paused = true
	stress_timer.paused = true
	loneliness_timer.paused = true
	pause_timer.paused = true
	
func victory():
	Stats.victory_achieved = true
	Stats.game_over("victory")
	print("YOU WON")
	pause_stuff()
	queue_free()
