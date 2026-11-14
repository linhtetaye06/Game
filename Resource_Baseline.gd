class_name Device
extends RefCounted

var devices_name:String = ""
var consumption:float = 0.0
var generation:float = 0.0
var device_on:bool = false
var durability:float = 0.0

func _init(device_name:String = "Device", device_consumption:float = 0.0, device_generation:float = 0.0, device_on:bool = false) : 
	self.device_name = device_name
	self.consumption = device_consumption
	self.generation = device_generation
	self.device_on = device_on
