class_name MoonBaseGame
extends Node

signal stats_updated 
signal display_warning(text: String)

var has_power:bool = false

var total_mined:float = 0.0

var month:int = 1

var total_month:int = 12

var is_night:bool = false

var raw_regolith_kg: float = 5000.0

var fuel_kg: float = 50.0

var battery_installed: bool = true

var battery: float = 200.0

var max_battery: float = 8000.0

var food_off_days: int = 0

var devices: Dictionary = {}

var large_battery_installed: bool = false

var large_battery: float = 0.0

var max_large_battery: float = 4000.0

var storage_loss_coefficient: float = 0.10

var refined_regolith: float = 0.0

var quota:float = 500.0

var total_missed_quotas:int = 0

var is_dust_storm_active: bool = false

var is_solar_flare_active: bool = false

var is_asteroid_disaster_active: bool = false

func _init() -> void:
	if GlobalData.saved_device_states.is_empty(): 
		devices = {
			"solar_1": Device.new("Solar Panel 1", 0.0, 1.25, true),
			"solar_2": Device.new("Solar Panel 2", 0.0, 1.25, true),
			"solar_3": Device.new("Solar Panel 3", 0.0, 1.25, true),
			"solar_4": Device.new("Solar Panel 4", 0.0, 1.25, true),
			"solar_5": Device.new("Solar Panel 5", 0.0,1.25, true),
			"solar_6": Device.new("Solar Panel 6", 0.0, 1.25, true),
		
		"life_support": Device.new("Life Support", 0.45, 0.0, true),
		"food": Device.new("Food Production", 0.0, 0.0, false),
		"miner_1": Device.new("Regolith Miner", 0.65, 0.0, false),
		"miner_2": Device.new("Regolith Miner", 0.65, 0.0, false),
		"miner_3": Device.new("Regolith Miner", 0.65, 0.0, false),
		"extractor": Device.new("Extractor", 1.0, 0.0, false),
		"shielding": Device.new("Shielding",0.25,0.0,true),
		"processor" : Device.new("Processor",1.25,0.0,false),
	}
	else : 
		devices = GlobalData.saved_device_states


		
func apply_wear_and_tear() -> void:
	for dev in devices.values():
		if dev.device_on:
			dev.durability = max(0.0, dev.durability - 1.5)
			
func check_survival_conditions() -> bool:
	if battery < 50.0:
		display_warning.emit("💀 GAME OVER: You don't have enough battery to use life support!")
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
			total_mined += randf_range(300.0, 400.0)

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
			
			display_warning.emit("Extractor processed ore: -1.0kg raw -> +%.2fkg refined regolith (20% waste)." % refined_kg)
		else:
			display_warning.emit("Extractor idle: Need raw regolith!")
	
	if devices["processor"].device_on:
		if refined_regolith >= 500:
			refined_regolith -= 500
			var extracted_fuel: float = randf_range(100.0, 260.0)
			large_battery += extracted_fuel
			display_warning.emit("Fuel Converter produced %.1f kg of fuel." % extracted_fuel)
		else:
			display_warning.emit("Fuel Converter idle: Need refined regolith!")

func burn_fuel(kg_to_burn: float) -> void:
	if not battery_installed:
		display_warning.emit("Standard battery required for fuel burning.")
		return
		
	if kg_to_burn <= 0 or kg_to_burn > fuel_kg:
		display_warning.emit("Invalid fuel amount specified.")
		return
		
	var energy_gained: float = kg_to_burn * 25.0
	if battery + energy_gained > max_battery:
		display_warning.emit("Exceeds battery capacity!")
		return
		
	fuel_kg -= kg_to_burn
	battery += energy_gained
	display_warning.emit("Burned %.1f kg fuel -> +%.1f kWh!" % [kg_to_burn, energy_gained])

func check_monthly_quota() -> bool:
	if refined_regolith >= quota:
		refined_regolith -= quota
		display_warning.emit("Monthly quota fulfilled! Deducted %.1f kg of fuel." % quota)
		month += 1
		quota += 500
		food_off_days = 0
		return true
	else:
		total_missed_quotas += 1
		display_warning.emit("Quota missed! (Total missed: %d/5)" % total_missed_quotas)
		
		if total_missed_quotas >= 5:
			display_warning.emit("GAME OVER: Missed quota 5 times total!")
			return false
			
		month += 1
		quota = round(quota * 1.30)
		food_off_days = 0
		return true

func run_day_phase(day_in_month: int) -> void:
	display_warning.emit("--- DAY %d: Solar Active ---" % day_in_month)
	
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
			display_warning.emit("⚠️ Battery overfilled! Lost %.1f kWh." % excess)
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
	
	display_warning.emit("--- NIGHT %d: Backup Power Active ---" % day_in_month)
	
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
		display_warning.emit("BLACKOUT! Batteries drained completely!")
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


var current_month: int = 1


func update_power() -> void:
	if current_month == 7:
		if not is_solar_flare_active:
			is_solar_flare_active = true
			display_warning.emit("☀️ ALERT: Solar flare event in Month 10! Radiation shielding power draw increased by 60%.
			Real World Occurence: The August 172 Solar Storms
			NASA Resource / Source: NASA Space Radiation Analysis Group (SRAG) 
			& LPI Apollo Archive — NASA / USRA Interplanetary Conditions during the Apollo Missions Study.")
	else:
		is_solar_flare_active = false

	if current_month == 10:
		if not is_dust_storm_active:
			is_dust_storm_active = true
			display_warning.emit("⚠️ ALERT: Massive dust storm in Month 11! Solar generation severely restricted.
			Real World Occurence: The Apollo 17 Thermal And Joint Jamming
			NASA Resource / Source: NASA Glenn Research Center Technical Memorandum — NASA TM-2005-213610: 
				The Effects of Lunar Dust on EVA Systems During the Apollo Missions.")
	else:
		is_dust_storm_active = false

	if current_month == 12:
		if not is_asteroid_disaster_active:
			is_asteroid_disaster_active = true
			display_warning.emit("☄️ ALERT: Asteroid impact in Month 12! Miner 1, Solar Panel 1, and Solar Panel 2 disabled.
			Real World Occurence: The September 11, 2013 Impact Flash
			NASA Resource / Source: NASA Meteoroid Environment Office (MEO) & Marshall Space Flight Center 
			— NASA MEO Lunar Impact Monitoring Portal.")
	else:
		is_asteroid_disaster_active = false

	var total_gen: float = 0.0
	var total_consumption: float = 0.0
	
	for key in devices.keys():
		var dev = devices[key]
		
		var disabled_by_asteroid = is_asteroid_disaster_active and (key == "miner_1" or key == "solar_1" or key == "solar_2")
		
		if dev.device_on and not disabled_by_asteroid:
			if not is_night:
				var gen_amount = dev.generation
				
				if key.begins_with("solar") and is_dust_storm_active:
					gen_amount *= 0.25
					
				total_gen += gen_amount
				
			var consumption_amount = dev.consumption
			
			if key == "shielding" and is_solar_flare_active:
				consumption_amount *= 1.60
				
			total_consumption += consumption_amount
			
	var net_power: float = total_gen - total_consumption
	var power_ok: bool = true
	
	if battery_installed:
		battery += net_power
		if battery > max_battery:
			var excess: float = battery - max_battery
			display_warning.emit("Battery overfilled! Lost %.1f kWh." % excess)
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
			has_power = false

	has_power = power_ok

func check_power_availability() -> bool:
	return has_power


	
