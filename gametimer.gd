class_name GameTimer
extends Node


var second_counter: int = 0
var minute_counter:int = 0
var status_timer: Timer
var month:int = 1
const total_months:int = 12



@onready var master_timer: Timer = Timer.new()

func _ready() -> void:
	master_timer = Timer.new()
	add_child(master_timer)
	master_timer.wait_time = 1.0
	master_timer.one_shot = false
	master_timer.timeout.connect(_on_master_timeout)
	master_timer.start()
	

func _on_master_timeout() -> void:
	GameProcessing.update_power()
	GameProcessing.check_survival_conditions()

	second_counter += 1
	minute_counter += 1

	if second_counter>=60 : 
		second_counter = 0
		if GameProcessing.check_power_availability() : 
			GameProcessing.process_mining_and_extraction(GameProcessing.check_power_availability())
			
	if minute_counter>=300 : 
		minute_counter=0
		
		if not GameProcessing.is_night:
			GameProcessing.run_day_phase(month)
			GameProcessing.is_night = true
		else:
			GameProcessing.run_night_phase(month)
			GameProcessing.is_night = false
			print("Month is now: ", month)
			var quota_passed = GameProcessing.check_monthly_quota()
			if not quota_passed:
				master_timer.stop()
				return
				
			month += 1
			if month > total_months:
				master_timer.stop()
				print("VICTORY: Completed 1 full year!")
	GameProcessing.stats_updated.emit()
