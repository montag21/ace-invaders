extends Node

signal score_changed

const PENETRATION_SCORE = 10
const BACKYARD_PENETRATION_SCORE = 15
const DOUBLE_PENETRATION_SCORE = 20
const COLLATERAL_SCORE = -1
const DROPSHIP_CRASH_SCORE = -2

var penetrations
var score
var backyard_penetrations
var double_penetration_bonus
var collaterals
var crashed_dropships


func _ready():
	reset_score()
	pass

func reset_score():
	score = 0
	penetrations = 0
	backyard_penetrations = 0
	double_penetration_bonus = false
	collaterals = 0
	crashed_dropships = 0

func track_penetration():
	penetrations += 1
	check_double_penetration_bonus()
	inc_penetration_score()
	
func track_backyard_penetration():
	backyard_penetrations += 1
	check_double_penetration_bonus()
	inc_penetration_score(true)
	
func track_stacheling_death():
	collaterals += 1
	inc_score(COLLATERAL_SCORE)
	
func track_dropship_crash():
	crashed_dropships += 1
	inc_score(DROPSHIP_CRASH_SCORE)

	
func check_double_penetration_bonus():
	if !double_penetration_bonus && penetrations > 0 && backyard_penetrations > 0:
		double_penetration_bonus = true
		
func inc_penetration_score(backyard = false):
	var score_increment = PENETRATION_SCORE
	if double_penetration_bonus:
		score_increment = DOUBLE_PENETRATION_SCORE
	elif backyard:
		score_increment = BACKYARD_PENETRATION_SCORE
	inc_score(score_increment)

func inc_score(increment):
	score += increment
	emit_signal("score_changed", score)
