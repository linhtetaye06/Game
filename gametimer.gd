class_name GameTimer
extends Node


@export var game_backend: MoonBaseGame

var month:int = 1

const total_months:int = 12

var is_night:bool = false


@onready var phase_timer: Timer = Timer.new()

func _ready() -> void:
	phase_timer = Timer.new()
	add_child(phase_timer)
	phase_timer.wait_time = 3.0
	phase_timer.one_shot = false
	phase_timer.timeout.connect(_on_phase_timeout)
	phase_timer.start()

func _on_phase_timeout() -> void:
	if not is_night:
		game_backend.run_day_phase(month)
		is_night = true
	else:
		game_backend.run_night_phase(month)
		is_night = false
		print("Month is now: ", month)
		var quota_passed = game_backend.check_monthly_quota()
		if not quota_passed:
			phase_timer.stop()
			return
			
		month += 1
		if month > total_months:
			phase_timer.stop()
			print("VICTORY: Completed 1 full year!")
	game_backend.stats_updated.emit()
