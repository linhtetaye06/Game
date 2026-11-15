extends Control

@export var game_timer: GameTimer
@onready var quota: Label = $StatTracker/quota
@onready var missed_quota_days: Label = $StatTracker/missed_quota_days
@onready var regolith: Label = $StatTracker/regolith
@onready var Day_night_month: Label = $StatTracker/Day_night_month
@onready var power_label: Label = $StatTracker/power
@onready var battery_label: Label = $StatTracker/battery_power
@onready var refined_regolith: Label = $StatTracker/refined_regolith
@onready var warning_label = $WarningControl/WarningContainer/Warning

func _ready() -> void: 
	if GameProcessing : 
		GameProcessing.stats_updated.connect(update_ui)
		update_ui()
	GameProcessing.display_warning.connect(show_screen_warning)

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
	

var warning_timer: SceneTreeTimer

func show_screen_warning(text: String) -> void:
	if not warning_label:
		return
		
	warning_label.text = text
	warning_label.visible = true
	
	await get_tree().create_timer(5.0).timeout
	
	if is_instance_valid(warning_label):
		warning_label.text = ""
		warning_label.visible = false



@onready var day_node: TextureRect = $WindowDay
@onready var night_node: TextureRect = $WindowNight
@onready var asteroid_day_node: TextureRect = $WindowAsteroidDay
@onready var asteroid_night_node: TextureRect = $WindowAsteroidNight
@onready var solar_flare_node: TextureRect = $WindowSolarFlare     
@onready var dust_storm_node: TextureRect = $WindowDustStorm       

func _process(delta: float) -> void:
	var current_month: int = GameProcessing.current_month
	var is_night_time: bool = GameProcessing.is_night
	
	day_node.visible = false
	night_node.visible = false
	asteroid_day_node.visible = false
	asteroid_night_node.visible = false
	solar_flare_node.visible = false
	dust_storm_node.visible = false
	
	if current_month == 10:
		solar_flare_node.visible = true
	elif current_month == 11:
		dust_storm_node.visible = true
	elif current_month == 12:
		if is_night_time:
			asteroid_night_node.visible = true
		else:
			asteroid_day_node.visible = true
	else:
		if is_night_time:
			night_node.visible = true
		else:
			day_node.visible = true
