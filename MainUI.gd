extends Control

@export var game_timer: GameTimer
@onready var quota: Label = $StatTracker/quota
@onready var missed_quota_days: Label = $StatTracker/missed_quota_days
@onready var regolith: Label = $StatTracker/regolith
@onready var Day_night_month: Label = $StatTracker/Day_night_month
@onready var power_label: Label = $StatTracker/power
@onready var battery_label: Label = $StatTracker/battery_power
@onready var refined_regolith: Label = $StatTracker/refined_regolith

func _ready() -> void: 
	if GameProcessing : 
		GameProcessing.stats_updated.connect(update_ui)
		update_ui()

func update_ui() -> void:
	quota.text = "Quota : %d kg" % GameProcessing.quota
	missed_quota_days.text = "Missed Quota For %d months" % GameProcessing.total_missed_quotas
	regolith.text = "Raw Regolith amount : %.1f kg" % GameProcessing.raw_regolith_kg
	var time_of_day = "Day Time" if not GameProcessing.is_night else "Night Time"
	Day_night_month.text = "Month %d (%s)" % [GameProcessing.month, time_of_day]
	print("UPDATE_UI WAS CALLED! Current month is: ", GameProcessing.month)
	var current_power = GameProcessing.battery
	var max_power = GameProcessing.max_battery
	power_label.text = "Power : %.1f/%.1f kWh" % [current_power, max_power]
	var battery_power = GameProcessing.large_battery
	var battery_max = GameProcessing.max_large_battery
	battery_label.text = "Battery Storage : %.1f/%.1f kWh" % [battery_power, battery_max]
	var refined = GameProcessing.refined_regolith
	refined_regolith.text = "Refined Regolith amount : %.1f kg" % refined
	
