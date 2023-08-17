extends MarginContainer


@onready var pb = $ProgressBar
@onready var bg = $BG
@onready var label = $Label

var unit = null
var target = null


func _ready():
	update_size()


func update_size() -> void:
	var vector = Vector2(Global.vec.size.letter3)
	custom_minimum_size = vector


func update_color() -> void:
	var max_h = 360.0
	var s = 0.9
	var v = {}
	v["fill"] = 1.0
	v["background"] = 0.5
	var h = null
	
	match name:
		"Integrity":
			h = 300.0 / max_h
		"Armor":
			h = 110.0 / max_h
		"Apparatus":
			h = 0.0 / max_h
	
	for key in v:
		var style = StyleBoxFlat.new()
		pb.set("theme_override_styles/" + key, style)
		var color = Color.from_hsv(h, s, v[key])
		style.set_bg_color(color)


func add_value(value_: int) -> void:
	var a = name
	if target.mechanism.active:
		var value = value_
		
		if value_ > 0:
			value = min(value_, pb.max_value - pb.value)
		else:
			value = min(value_, pb.value)
			
			if name == "Apparatus":
				unit.hex.target.integrity.add_value(value)
		
		pb.value += value
		
		if name == "Integrity":
			var percentage = float(pb.value) / pb.max_value
			
			if percentage < 0.5:
				target.mechanism.disrupt()
		
		if pb.value >= pb.max_value:
			pb.value = pb.max_value
		
		if pb.value <= pb.min_value:
			pb.value = pb.min_value
			
			match name:
				"Armor":
					unit.switch_indicators()
				"Apparatus":
					if unit.vulnerable:
						var vulnerable_damage = -pb.max_value * 3
						unit.hex.target.integrity.add_value(vulnerable_damage)
						
						if unit.marker:
							unit.marker = false
				"Integrity":
						target.mechanism.disrupt()
		
		if name != "Integrity":
			label.text = str(pb.value)

