extends Node

#perma-stats
var deaths_by_stress = 0
var deaths_by_loneliness = 0
var victory_achieved = false

#per round
var stress_level = 0 #Needs an increase and a cooldown
var loneliness = 0
var petting_progress = 0
var progress_multiplier = 1
var food_progress = 0
var food_multiplier = 1



signal just_pet
signal stats_updated
signal game_over_signal(cause_of_death)

func reset_stats():
	stress_level = 0
	loneliness = 0
	petting_progress = 0
	progress_multiplier = 1
	food_multiplier = 1
	food_progress = 0
	
	update_stats()

func update_stats():
	if petting_progress > Global.high_score:
		Global.high_score = petting_progress
	emit_signal("stats_updated")

func game_over(cause_of_death):
	update_stats()
	emit_signal("game_over_signal", cause_of_death)
