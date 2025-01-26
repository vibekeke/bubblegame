extends Node2D


var bubble_scene = load("res://Bubble/bubble.tscn")
var sparkle_y = load("res://Effects/sparkleY.tscn")
var sparkle_b = load("res://Effects/sparkleB.tscn")
var sparkle_p = load("res://Effects/sparkleP.tscn")

@onready var start_menu = $StartMenu
@onready var results_menu = $ResultsMenu

@onready var result_title = $ResultsMenu/VBoxContainer/ResultTitle
@onready var message_label = $ResultsMenu/VBoxContainer/MessageLabel
@onready var friendscore_label = $ResultsMenu/VBoxContainer/FriendScoreLabel
@onready var foodscore_label = $ResultsMenu/VBoxContainer/FoodScoreLabel
@onready var tryagain_button = $ResultsMenu/VBoxContainer/TryAgainButton

@onready var boble_music = $BobleMusic
@onready var gameover_music = $GameoverMusic
@onready var victory_music = $VictoryMusic

@onready var effects_layer = $EffectsLayer

var game_active = false
var just_won = false
var center_position = Vector2()

var stress_messages = [
	"Sometimes too much love can add a lot of pressure. Enough to make someone pop.",
	"Patience is a virtue, especially when it comes to friendships",
	"You pet the bubble too much and it exploded. Try again",]

var lonely_messages = [
	"It's important to take care of your friends, or you might lose them forever.",
	"Being neglected can leave lasting scars. In this case it led to death.",
	"The bubble felt too lonely and died. Try again"
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_position = get_viewport_rect().size/2
	start_menu.position.x = center_position.x
	results_menu.position.x = center_position.x
	
	Stats.game_over_signal.connect(_on_game_over)
	Stats.just_pet.connect(animate_sparkles)
	start_menu.show()
	results_menu.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	start_menu.hide()
	new_game()

func new_game():
	Stats.reset_stats()
	var bubble_instance = bubble_scene.instantiate()
	bubble_instance.position = center_position
	get_parent().add_child(bubble_instance)
	boble_music.playing = true
	game_active = true
	

func _on_game_over(cause_of_death):
	boble_music.playing = false
	game_active = false
	#TODO: Should actually show results screen and try again
	if cause_of_death == "stress":
		gameover_music.playing = true
		if Stats.deaths_by_stress < 3:
			message_label.text = stress_messages[Stats.deaths_by_stress - 1]
		else:
			message_label.text = stress_messages[-1]
	elif cause_of_death == "loneliness":
		gameover_music.playing = true
		if Stats.deaths_by_loneliness < 3:
			message_label.text = lonely_messages[Stats.deaths_by_loneliness - 1]
		else:
			message_label.text = lonely_messages[-1]
	elif cause_of_death == "victory":
		victory_music.playing = true
		result_title.text = "Congratulations!"
		message_label.text = "You have made a lifelong bond. That friendship will always be with you, no matter what happens <3"
		tryagain_button.text = "HURRAY!"
		just_won = true
	
	foodscore_label.text = "Foods ate: " + str(Stats.food_progress)
	friendscore_label.text = "Friend score: " + str(Stats.petting_progress * 100)
	
	
	results_menu.show()

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_try_again_button_pressed() -> void:
	if just_won == true:
		message_label.text = "Game made by Bekeblob. Music by Trygvert. \n\nThank you for playing my first ever (finished) game!\nSpecial thanks to CallmeClever and Tyler McAllister 
		for their support and wisdom, and to all of my friends for existing on earth."
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
	
	
			
