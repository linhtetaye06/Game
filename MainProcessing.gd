class_name MoonBaseGame
extends Node

signal stats_updated 

var has_power:bool = false

var total_mined:float = 0.0

var month:int = 1

var total_month:int = 12

var is_night:bool = false

var warning_label: Label = null

var raw_regolith_kg: float = 5000.0

var fuel_kg: float = 50.0

var battery_installed: bool = true

var battery: float = 200.0

var max_battery: float = 100000.0

var food_off_days: int = 0

var devices: Dictionary = {}

var large_battery_installed: bool = false

var large_battery: float = 0.0

var max_large_battery: float = 5000000.0

var storage_loss_coefficient: float = 0.10

var refined_regolith: float = 0.0

var quota:float = 1000.0

var total_missed_quotas:int = 0

func _init() -> void:
	if GlobalData.saved_device_states.is_empty(): 
		devices = {
			"solar_1": Device.new("Solar Panel 1", 0.0, 9150.0, true),
			"solar_2": Device.new("Solar Panel 2", 0.0, 9150.0, true),
			"solar_3": Device.new("Solar Panel 3", 0.0, 9150.0, true),
			"solar_4": Device.new("Solar Panel 4", 0.0, 9150.0, true),
			"solar_5": Device.new("Solar Panel 5", 0.0, 9150.0, true),
			"solar_6": Device.new("Solar Panel 6", 0.0, 9150.0, true),
		
		"life_support": Device.new("Life Support", 3294.0, 0.0, true),
		"food": Device.new("Food Production", 0.0, 0.0, false),
		"miner_1": Device.new("Regolith Miner", 4758.0, 0.0, false),
		"miner_2": Device.new("Regolith Miner", 4758.0, 0.0, false),
		"miner_3": Device.new("Regolith Miner", 4758.0, 0.0, false),
		"extractor": Device.new("Extractor", 7320.0, 0.0, false),
		"shielding": Device.new("Shielding",1830.0,0.0,true),
		"processor" : Device.new("Processor",9150,0.0,false),
	}
	else : 
		devices = GlobalData.saved_device_states


func show_screen_warning(text: String) -> void:
	if warning_label:
		warning_label.text = text
		
func apply_wear_and_tear() -> void:
	for dev in devices.values():
		if dev.device_on:
			dev.durability = max(0.0, dev.durability - 1.5)
			
func check_survival_conditions() -> bool:
	if not devices["life_support"].device_on:
		show_screen_warning("💀 GAME OVER: Life Support offline! Crew asphyxiated.")
		return false

	if not devices["food"].device_on:
		food_off_days += 1
		show_screen_warning("⚠️ Food Production OFF! Days without food: %d/7" % food_off_days)
	
	if food_off_days > 7:
		show_screen_warning("💀 GAME OVER: The crew starved!")
		return false

	return true

func process_mining_and_extraction(has_power: bool) -> void:
	if not has_power:
		return

	var active_miners: int = 0
	var total_mined: float = 0.0

	for i in range(1, 4):
		var miner_key = "miner_%d" % i
		if devices.has(miner_key) and devices[miner_key].device_on:
			active_miners+=1
			total_mined += randf_range(2000.0, 5000.0)

	if total_mined> 0.0:
		raw_regolith_kg += total_mined
		print("Mined: ", total_mined, " | Total Regolith: ", raw_regolith_kg)
	else : 
		print("No active miners.")
	stats_updated.emit()
	
	print(" %d active miner(s) gained %.1f kilograms of regolith." % [active_miners, total_mined])
		
	if devices["extractor"].device_on:
		if raw_regolith_kg >= 1000.0:
			var consumed_raw: float = 1000.0
			raw_regolith_kg -= consumed_raw
			
			var refined_kg: float = consumed_raw * 0.8 
			refined_regolith += refined_kg
			
			show_screen_warning("Extractor processed ore: -1.0kg raw -> +%.2fkg refined regolith (20% waste)." % refined_kg)
		else:
			show_screen_warning("Extractor idle: Need raw regolith!")
	
	if devices["processor"].device_on:
		if refined_regolith >= 500:
			refined_regolith -= 500
			var extracted_fuel: float = randf_range(100.0, 260.0)
			large_battery += extracted_fuel
			show_screen_warning("Fuel Converter produced %.1f kg of fuel." % extracted_fuel)
		else:
			show_screen_warning("Fuel Converter idle: Need refined regolith!")

func burn_fuel(kg_to_burn: float) -> void:
	if not battery_installed:
		show_screen_warning("Standard battery required for fuel burning.")
		return
		
	if kg_to_burn <= 0 or kg_to_burn > fuel_kg:
		show_screen_warning("Invalid fuel amount specified.")
		return
		
	var energy_gained: float = kg_to_burn * 25.0
	if battery + energy_gained > max_battery:
		show_screen_warning("Exceeds battery capacity!")
		return
		
	fuel_kg -= kg_to_burn
	battery += energy_gained
	show_screen_warning("Burned %.1f kg fuel -> +%.1f kWh!" % [kg_to_burn, energy_gained])

func check_monthly_quota() -> bool:
	if refined_regolith >= quota:
		refined_regolith -= quota
		show_screen_warning("Monthly quota fulfilled! Deducted %.1f kg of fuel." % quota)
		month += 1
		quota = round(quota * 1.30)
		food_off_days = 0
		return true
	else:
		total_missed_quotas += 1
		show_screen_warning("Quota missed! (Total missed: %d/5)" % total_missed_quotas)
		
		if total_missed_quotas >= 5:
			show_screen_warning("GAME OVER: Missed quota 5 times total!")
			return false
			
		month += 1
		quota = round(quota * 1.30)
		food_off_days = 0
		return true

func run_day_phase(day_in_month: int) -> void:
	show_screen_warning("--- DAY %d: Solar Active ---" % day_in_month)
	
	var total_gen: float = 0.0
	var total_consumption: float = 0.0
	
	for dev in devices.values():
		if dev.device_on:
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
	
func run_night_phase(day_in_month: int) -> void:
	
	show_screen_warning("--- NIGHT %d: Backup Power Active ---" % day_in_month)
	
	var total_consumption: float = 0.0
	for dev in devices.values():
		if dev.device_on:
			total_consumption += dev.consumption
			
	var remaining_load: float = total_consumption
	
	if battery_installed and battery > 0:
		if battery >= remaining_load:
			battery -= remaining_load
			remaining_load = 0.0
		else:
			remaining_load -= battery
			battery = 0.0
				
	if remaining_load > 0 and large_battery_installed and large_battery > 0:
		var effective_draw: float = remaining_load / (1.0 - storage_loss_coefficient)
		if large_battery >= effective_draw:
			large_battery -= effective_draw
			remaining_load = 0.0
		else:
			large_battery = 0.0

	var has_power: bool = true
	if remaining_load > 0:
		show_screen_warning("BLACKOUT! Batteries drained completely!")
		has_power = false
	else:
		has_power = (battery_installed and battery >= 0) or (large_battery_installed and large_battery >= 0)

	process_mining_and_extraction(has_power)


func deposit_power(amount: float) -> void:
	if amount > battery:
		return
	battery -= amount
	large_battery += amount
	if large_battery > max_large_battery:
		large_battery = max_large_battery
	stats_updated.emit()


func set_solar_panel_state(index: int, is_on: bool) -> void:
	var device_key = "solar_%d" % (index + 1)
	if devices.has(device_key):
		devices[device_key].device_on = is_on
		GlobalData.saved_device_states = devices
		stats_updated.emit()
		
func set_miner_state(index: int, is_on: bool) -> void:
	var device_key = "miner_%d" % (index + 1)
	if devices.has(device_key):
		devices[device_key].device_on = is_on
		GlobalData.saved_device_states = devices
		stats_updated.emit()

func set_extractor_state(is_on: bool) -> void:
	if devices.has("extractor"):
		devices["extractor"].device_on = is_on
		GlobalData.saved_device_states = devices
		stats_updated.emit()
		print("Extractor state updated to: ", is_on)
		
func set_processor_state(is_on: bool) -> void:
	if devices.has("processor"):
		devices["processor"].device_on = is_on
		GlobalData.saved_device_states = devices
		stats_updated.emit()
		print("Processor state updated to: ", is_on)
		

func update_power() -> void:
	var total_gen: float = 0.0
	var total_consumption: float = 0.0
	
	for dev in devices.values():
		if dev.device_on:
			if not is_night:
				total_gen += dev.generation
			total_consumption += dev.consumption
			
	var net_power: float = total_gen - total_consumption
	var power_ok: bool = true
	
	if battery_installed:
		battery += net_power
		if battery > max_battery:
			var excess: float = battery - max_battery
			show_screen_warning("Battery overfilled! Lost %.1f kWh." % excess)
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
					power_ok = false
			else:
				power_ok = false
	else:
		if net_power < 0:
			power_ok = false

	has_power = power_ok

func check_power_availability() -> bool:
	return has_power
