extends Control

@export var game_backend: MoonBaseGame
@export var game_timer: GameTimer
@onready var quota: Label = $StatTracker/quota
@onready var missed_quota_days: Label = $StatTracker/missed_quota_days
@onready var regolith: Label = $StatTracker/regolith
@onready var Day_night_month: Label = $StatTracker/Day_night_month

func _ready() -> void: 
	if game_backend : 
		game_backend.stats_updated.connect(update_ui)
		update_ui()

func update_ui() -> void:
	quota.text = "Quota : %d kg" % game_backend.quota
	missed_quota_days.text = "Missed Quota For %d months" % game_backend.total_missed_quotas
	regolith.text = "Regolith amount : %.1f t" % game_backend.raw_regolith_tonnes
	var time_of_day = "Day Time" if not game_timer.is_night else "Night Time"
	Day_night_month.text = "Month %d (%s)" % [game_timer.month, time_of_day]
	print("UPDATE_UI WAS CALLED! Current month is: ", game_timer.month)
	
