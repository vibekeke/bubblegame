extends Node2D


var bubble_scene = load("res://Bubble/bubble.tscn")
var sparkle_y = load("res://Effects/sparkleY.tscn")
var sparkle_b = load("res://Effects/sparkleB.tscn")
var sparkle_p = load("res://Effects/sparkleP.tscn")
var bg_bubble = load("res://BackgroundBubbles/bg_bubble.tscn")

@onready var firsttime_label = $TutorialMenu
@onready var start_menu = $StartMenu
@onready var subtitle = $StartMenu/VBoxContainer/Subtitle
@onready var victory_crown = $StartMenu/VictoryCrown

@onready var results_menu = $ResultsMenu
@onready var sparkle_crown = $ResultsMenu/SparkleCrown
@onready var result_title = $ResultsMenu/VBoxContainer/ResultTitle
@onready var message_label = $ResultsMenu/VBoxContainer/MessageLabel
@onready var friendscore_label = $ResultsMenu/VBoxContainer/FriendScoreLabel
@onready var foodscore_label = $ResultsMenu/VBoxContainer/FoodScoreLabel
@onready var tryagain_button = $ResultsMenu/VBoxContainer/TryAgainButton

@onready var boble_music = $BobleMusic
@onready var gameover_music = $GameoverMusic
@onready var victory_music = $VictoryMusic

@onready var effects_layer = $EffectsLayer
@onready var background_layer = $BackgroundLayer
@onready var bubblespawn_timer = $BubbleSpawner
@onready var generic_timer = $GenericTimer

var game_active = false
var just_won = false

var viewport_size = Vector2()
var center_position = Vector2()

var spawnpoint_A = Vector2()
var spawnpoint_B = Vector2()

var viewport_quarter = Vector2()

var stress_messages = [
	"Sometimes too much love can add a lot of pressure. Enough to make someone pop.",
	"Patience is a virtue, especially when it comes to friendships. Try being gentler!",
	"You pet the bubble too much and it exploded. Try again.",]

var lonely_messages = [
	"It's important to take care of your friends, or they might not stick around.",
	"Being neglected can leave wounds that never heal. In this case it led to death.",
	"The bubble felt too lonely and died. \nTry again."
]
var victory_messages = [
	"You have made a lifelong bond. That friendship will always be with you, no matter what happens <3",
	"Look at you go! You made another wonderful friend.",
	"You've made three friends! That means you've unlocked the secret ending. Congrats again!",
	"Ok, that's enough friends."
]
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewport_size = get_viewport_rect().size
	center_position = viewport_size/2
	
	viewport_quarter = viewport_size/4
	spawnpoint_A.y = viewport_size.y + 200
	spawnpoint_A.x = 0 + viewport_quarter.x - 100
	spawnpoint_B.y = viewport_size.y + 200
	spawnpoint_B.x = 0 + (viewport_quarter.x * 3) + 100
	
	var ui_scale = (viewport_size.x - viewport_quarter.x) / 1000
	
	firsttime_label.scale = Vector2(ui_scale, ui_scale)
	start_menu.scale = Vector2(ui_scale, ui_scale)
	results_menu.scale = Vector2(ui_scale, ui_scale)
	
	firsttime_label.position.x = center_position.x
	firsttime_label.position.y = 80
	start_menu.position.x = center_position.x
	results_menu.position.x = center_position.x
	
	
	Stats.game_over_signal.connect(_on_game_over)
	Stats.just_pet.connect(animate_sparkles)
	victory_crown.hide()
	sparkle_crown.hide()
	firsttime_label.hide()
	start_menu.show()
	results_menu.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	start_menu.hide()
	new_game()

func new_game():
	if Stats.first_time == true:
		firsttime_label.show()
		generic_timer.wait_time = 3
		generic_timer.start()
		
	Stats.reset_stats()
	var bubble_instance = bubble_scene.instantiate()
	bubble_instance.position = center_position
	bubble_instance.scale.x = viewport_quarter.y / 2 / 100
	bubble_instance.scale.y = viewport_quarter.y / 2 / 100
	get_parent().add_child(bubble_instance)
	boble_music.playing = true
	game_active = true
	bubblespawn_timer.start()
	

func _on_game_over(cause_of_death):
	boble_music.playing = false
	game_active = false
	firsttime_label.hide()
	
	bubblespawn_timer.stop()
	clear_bubbles()
	
	if cause_of_death == "stress":
		sparkle_crown.hide()
		gameover_music.playing = true
		result_title.text = "GAME OVER"
		if Stats.deaths_by_stress < 3:
			message_label.text = stress_messages[Stats.deaths_by_stress - 1]
		else:
			message_label.text = stress_messages[-1]
	elif cause_of_death == "loneliness":
		sparkle_crown.hide()
		gameover_music.playing = true
		result_title.text = "GAME OVER"
		if Stats.deaths_by_loneliness < 3:
			message_label.text = lonely_messages[Stats.deaths_by_loneliness - 1]
		else:
			message_label.text = lonely_messages[-1]
	elif cause_of_death == "victory":
		victory_music.playing = true
		sparkle_crown.show()
		sparkle_crown.play()
		victory_crown.show()
		result_title.text = "Congratulations!"
		if Stats.victories < 4:
			message_label.text = victory_messages[Stats.victories -1]
		else:
			message_label.text = victory_messages[-1]

		if Stats.victories == 1:
			tryagain_button.text = "HURRAY!"
			just_won = true
	
	friendscore_label.text = "Friend score: " + str(Stats.petting_progress * 100)
	if Stats.petting_progress >= 50:
		friendscore_label.text = friendscore_label.text + " (MAX)"
	foodscore_label.text = "Bubbles popped: " + str(Stats.bubbles_popped)
	subtitle.text = "High score " + str(Stats.high_score * 100)
	
	
	results_menu.show()

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_try_again_button_pressed() -> void:
	if just_won == true:
		message_label.text = "Game made by Bekeblob. Music by Trygvert. \n\nThank you for playing my first ever (finished) game!\nSpecial thanks to CallmeClever and Tyler McAllister 
		for being cool and helpful, and to all of my friends who inspire me to make things <3"
		friendscore_label.hide()
		foodscore_label.hide()
		tryagain_button.text = "START OVER"
		just_won = false
	else: 
		gameover_music.playing = false
		victory_music.playing = false
		results_menu.hide()
		friendscore_label.show()
		foodscore_label.show()
		new_game()


func _on_main_menu_button_pressed() -> void:
	boble_music.playing = false
	gameover_music.playing = false
	victory_music.playing = false
	results_menu.hide()
	start_menu.show()

func animate_sparkles():
	var mouse_position = get_global_mouse_position()
	var sparkle_instance
	var random_amount = randi_range(1, 2)
	
	for i in random_amount:
		var random_color = randi_range(0, 2)
		var randx = randi_range(-30, 30)
		var randy = randi_range(-30, 30)
		var random_scale = randf_range(0.5, 1)
		match random_color:
			0:
				sparkle_instance = sparkle_y.instantiate()
			1:
				sparkle_instance = sparkle_b.instantiate()
			2:
				sparkle_instance = sparkle_p.instantiate()
		effects_layer.add_child(sparkle_instance)
		sparkle_instance.global_position = mouse_position + Vector2(randx, randy)
		sparkle_instance.scale = Vector2(random_scale, random_scale)
	


func _on_bubble_spawner_timeout() -> void:
	var randx = randi_range(-160, 160)
	var bg_bubble_instance = bg_bubble.instantiate()
	background_layer.add_child(bg_bubble_instance)
	
	var bubble_scale = viewport_quarter.x / 2.5 / 100
	var random_scale_multiplier = randi_range(0.8, 1.1)
	bg_bubble_instance.scale = Vector2(bubble_scale * random_scale_multiplier, bubble_scale * random_scale_multiplier)
	var random_spawnpoint = randi_range(0, 1)
	if random_spawnpoint == 0:
		print(spawnpoint_A)
		bg_bubble_instance.position = spawnpoint_A + Vector2(randx, 0)
	elif random_spawnpoint == 1:
		print(spawnpoint_B)
		bg_bubble_instance.position = spawnpoint_B + Vector2(randx, 0)
	

func clear_bubbles():
	for child in background_layer.get_children():
		child.queue_free()


func _on_generic_timer_timeout() -> void:
	if Stats.petting_progress > 2:
		firsttime_label.hide()
		Stats.first_time = false
		generic_timer.stop()
	else:
		generic_timer.wait_time = 2
		generic_timer.start()
