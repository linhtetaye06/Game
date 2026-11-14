class_name MoonBaseGame
extends Node
var warning_label: Label = null

var raw_regolith_tonnes: float = 5.0

var fuel_kg: float = 50.0

var battery_installed: bool = true

var battery: float = 200.0

var max_battery: float = 400.0

var food_off_days: int = 0

var devices: Dictionary = {}

var large_battery_installed: bool = false

var large_battery: float = 0.0

var max_large_battery: float = 1000.0

var storage_loss_coefficient: float = 0.10

func _init() -> void:
	devices = {
		"solar_1": Device.new("Solar Panel 1", 0.0, 35.0, true),
		"solar_2": Device.new("Solar Panel 2", 0.0, 35.0, true),
		"solar_3": Device.new("Solar Panel 3", 0.0, 35.0, true),
		"solar_4": Device.new("Solar Panel 4", 0.0, 35.0, true),
		"solar_5": Device.new("Solar Panel 5", 0.0, 35.0, true),
		"solar_6": Device.new("Solar Panel 6", 0.0, 35.0, true),
		
		"life_support": Device.new("Life Support", 9.0, 0.0, true),
		"food": Device.new("Food Production", 90.0, 0.0, false),
		"miner": Device.new("Regolith Miner", 20.0, 0.0, false),
		"extractor": Device.new("Extractor", 100.0, 0.0, false),
		"shielding": Device.new("Shielding",5.0,0.0,true),
		"Converting" : Device.new("Processing",250,0.0,false),
	}
	

func show_screen_warning(text: String) -> void:
	if warning_label:
		warning_label.text = text
		
func apply_wear_and_tear() -> void:
	for dev in devices.values():
		if dev.is_on:
			dev.durability = max(0.0, dev.durability - 1.5)
			
func check_survival_conditions() -> bool:
	if not devices["life_support"].is_on:
		show_screen_warning("💀 GAME OVER: Life Support offline! Crew asphyxiated.")
		return false

	if not devices["food"].is_on:
		food_off_days += 1
		show_screen_warning("⚠️ Food Production OFF! Days without food: %d/7" % food_off_days)
	
	if food_off_days > 7:
		show_screen_warning("💀 GAME OVER: The crew starved!")
		return false

	return true

func process_mining_and_extraction(has_power: bool) -> void:
	if not has_power:
		return

	if devices["small_miner"].is_on:
		var mined_tonnes: float = randf_range(2.0, 5.0)
		raw_regolith_tonnes += mined_tonnes
		show_screen_warning(" Miner gained %.1f tonnes of regolith." % mined_tonnes)

	if devices["extractor"].is_on:
		if raw_regolith_tonnes >= 1.0:
			raw_regolith_tonnes -= 1.0
			var extracted_kg: float = randf_range(10.0, 26.0)
			fuel_kg += extracted_kg
			show_screen_warning("Extractor produced %.1f kg of fuel." % extracted_kg)
		else:
			show_screen_warning(" Extractor idle: Need raw regolith!")

func run_day_phase(day_in_month: int) -> void:
	show_screen_warning("--- DAY %d: Solar Active ---" % day_in_month)
	
	var total_gen: float = 0.0
	var total_consumption: float = 0.0
	
	for dev in devices.values():
		if dev.is_on:
			total_gen += dev.generation
			total_consumption += dev.consumption
			
	var net_power: float = total_gen - total_consumption
	var has_power: bool = true
	
	if battery_installed:
		battery += net_power
		if battery > max_battery:
			var excess: float = battery - max_battery
			show_screen_warning("⚠️ Battery overfilled! Lost %.1f kWh." % excess)
			battery = max_battery
		elif battery < 0:
			var deficit: float = abs(battery)
			battery = 0.0
			if large_battery_installed and large_battery > 0:
				var drawn_from_large: float = deficit / (1.0 - storage_loss_coefficient)
				if large_battery >= drawn_from_large:
					large_battery -= drawn_from_large
				else:
					large_battery = 0.0
					has_power = false
			else:
				has_power = false
	else:
		if net_power < 0:
			has_power = false

	process_mining_and_extraction(has_power)
	
