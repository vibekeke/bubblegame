extends Node2D
var move_speed = 100
var bobbing_amplitude = 20
var bobbing_speed = 1.6
var bobbing_time = 0
var initial_position = Vector2()
var random_size

@onready var sprite = $AnimatedSprite2D
@onready var pop_sound = $PopSound
@onready var pause_timer = $PettingTimer

var times_pressed = 0
var max_times_pressed = 10
var random_food_number = 0
var food_item = null

var hovering = false
var mouse_button_down = false
var mouse_speed = 0
var previous_mouse_position = Vector2()
var speed_threshold = 1200

var petting_paused
var pause_wait_time = 0.5



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	random_size = randf_range(0.25, 0.3)
	max_times_pressed = randi_range(1, 9)
	random_food_number = randi_range(0, 10)
	
	sprite.scale = Vector2(random_size, random_size)
	call_deferred("_set_initial_position")
	
	if random_food_number > 5:
		food_item = 0
	else:
		food_item = random_food_number
	
	#TODO: Randomize whether it carries a food item (They are all the same, just different sprites)

func _set_initial_position():
	initial_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y -= move_speed * delta
	if position.y < -200:
		print("bubble deleting self")
		queue_free()
	#Bobbing
	bobbing_time += delta * bobbing_speed
	position.x = initial_position.x + bobbing_amplitude * sin(bobbing_time)
	
	if hovering and mouse_button_down:  # Only process when hovering over the sprite
		var current_mouse_position = get_global_mouse_position()
		mouse_speed = current_mouse_position.distance_to(previous_mouse_position) / delta
		
		# Check if speed exceeds threshold
		if mouse_speed > speed_threshold:
			if not petting_paused:
				pet_bg_bubble()
		# Update previous mouse position
		previous_mouse_position = current_mouse_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_button_down = true
		elif event.button_index == 1 and not event.is_pressed():
			mouse_button_down = false
			
func _on_button_mouse_entered() -> void:
	hovering = true

func _on_button_mouse_exited() -> void:
	hovering = false

func pet_bg_bubble():
	if times_pressed > max_times_pressed:
		pop_bubble()
	else:
		times_pressed += 1
		pressed_animation_tween()

	petting_paused = true

	pause_timer.wait_time = randf_range(pause_wait_time - 0.2, pause_wait_time + 0.3)
	pause_timer.start()

var button_enabled = true
func _on_button_pressed() -> void:
	if times_pressed > max_times_pressed and button_enabled:
		button_enabled = false
		pop_bubble()
	else:
		times_pressed += 1
		pressed_animation_tween()


func _on_petting_timer_timeout() -> void:
	petting_paused = false


func pressed_animation_tween():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "scale", Vector2(random_size - 0.03, random_size - 0.03), 0.1)
	tween.tween_property(sprite, "scale", Vector2(random_size + 0.03, random_size + 0.03), 0.1)
	tween.tween_property(sprite, "scale", Vector2(random_size, random_size), 0.1)

var sound_just_played = false

func pop_bubble():
	sprite.play("pop")
	if not sound_just_played:
		pop_sound.play()
		sound_just_played = true
	
func _on_animated_sprite_2d_animation_finished() -> void:
	finish_bubble()

func finish_bubble():
	var last_position = position
	Stats.bubbles_popped += 1
	Stats.emit_signal("pregnant_bubble_popped", food_item, last_position)
	queue_free()
