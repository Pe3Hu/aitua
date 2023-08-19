extends Node


var rng = RandomNumberGenerator.new()
var arr = {}
var num = {}
var vec = {}
var dict = {}
var flag = {}
var node = {}
var stat = {}
var color = {}
var scene = {}



func _ready() -> void:
	init_arr()
	init_num()
	init_vec()
	init_dict()
	init_node()
	init_stat()
	init_color()
	init_scene()


func init_arr() -> void:
	arr.edge = [1, 2, 3, 4, 5, 6]
	
	init_dice_substitutions()


func init_dice_substitutions() -> void:
	arr.dice = {}
	arr.dice.substitution = {}
	
	var n = 6 
	
	for _i in 2:
		var l = _i + 2
		
		var cubes = []
		
		for _j in l:
			cubes.append(n)
			
		var substitutions = get_all_substitutions(cubes)
		arr.dice.substitution[l] = {}
		var sum = 0
		
		for substitution in substitutions:
			substitution.sort()
			
			if !arr.dice.substitution[l].has(substitution):
				arr.dice.substitution[l][substitution] = {}
				arr.dice.substitution[l][substitution].repeats = 0
				arr.dice.substitution[l][substitution].edges = []
				
				for index in substitution:
					var edge = arr.edge[index]
					arr.dice.substitution[l][substitution].edges.append(edge)
			
			arr.dice.substitution[l][substitution].repeats += 1
			sum += 1


func init_num() -> void:
	num.index = {}


func init_dict() -> void:
	dict.neighbor = {}
	dict.neighbor.linear3 = [
		Vector3( 0, 0, -1),
		Vector3( 1, 0,  0),
		Vector3( 0, 0,  1),
		Vector3(-1, 0,  0)
	]
	dict.neighbor.linear2 = [
		Vector2( 0,-1),
		Vector2( 1, 0),
		Vector2( 0, 1),
		Vector2(-1, 0)
	]
	dict.neighbor.diagonal = [
		Vector2( 1,-1),
		Vector2( 1, 1),
		Vector2(-1, 1),
		Vector2(-1,-1)
	]
	dict.neighbor.zero = [
		Vector2( 0, 0),
		Vector2( 1, 0),
		Vector2( 1, 1),
		Vector2( 0, 1)
	]
	dict.neighbor.hex = [
		[
			Vector2( 1,-1), 
			Vector2( 1, 0), 
			Vector2( 0, 1), 
			Vector2(-1, 0), 
			Vector2(-1,-1),
			Vector2( 0,-1)
		],
		[
			Vector2( 1, 0),
			Vector2( 1, 1),
			Vector2( 0, 1),
			Vector2(-1, 1),
			Vector2(-1, 0),
			Vector2( 0,-1)
		]
	]
	
	dict.substitution = {}
	dict.substitution["6"] = {}
	dict.substitution["6"]["2"]= 36
	dict.substitution["6"]["3"]= 216
	
	init_spell()


func init_spell() -> void:
	dict.spell = {}
	dict.spell.title = {}
	var path = "res://asset/json/aitua_spell.json"
	var array = load_data(path)
	
	for data in array:
		dict.spell.title[data.title] = {}
		dict.spell.title[data.title].condition = {}
		dict.spell.title[data.title].effect = {}
		
		for key in data:
			var words = key.rsplit(" ")
			var flag = true
			
			for subkey in dict.spell.title[data.title]:
				if words.has(subkey):
					flag = false
					
					if subkey == "effect":
						var index = words[2]
						var str = words[1]
						
						if !dict.spell.title[data.title][subkey].has(index):
							dict.spell.title[data.title][subkey][index] = {}
							
						dict.spell.title[data.title][subkey][index][str] = data[key]
					else:
						var str = ""
						
						for _i in words.size():
							var word = words[_i]
							
							if word != subkey:
								if str != "":
									str += " "
								
								str += word
						
						dict.spell.title[data.title][subkey][str] = data[key]
			if flag:
				dict.spell.title[data.title][key] = data[key]
		
		dict.spell.title[data.title].erase("title")


func init_node() -> void:
	node.game = get_node("/root/Game")


func init_stat() -> void:
	stat.spell = {}
	stat.spell.damage = {}


func init_scene() -> void:
	#scene.hell = load("res://scene/0/hell.tscn")
	scene.spellcaster = load("res://scene/1/spellcaster.tscn")
	scene.spell = load("res://scene/1/spell.tscn")
	
	scene.icon = load("res://scene/2/icon.tscn")
	scene.dice = load("res://scene/2/dice.tscn")
	scene.facet = load("res://scene/2/facet.tscn")
	
	pass


func init_vec():
	vec.size = {}
	
	vec.size.facet = Vector2(25, 25)
	#vec.size.unit = Vector2(80, 24)
	#vec.size.cell = Vector2(vec.size.unit)
	vec.size.letter = Vector2(23, 23)
	vec.size.letter2 = Vector2(31, 23)
	vec.size.letter3 = Vector2(46, 23)
	
	#num.size.facet.R = vec.size.unit.x / 2 * 1.25
	#num.size.facet.r =  num.size.unit.R * sqrt(3) / 2
	init_window_size()


func init_window_size():
	vec.size.window = {}
	vec.size.window.width = ProjectSettings.get_setting("display/window/size/viewport_width")
	vec.size.window.height = ProjectSettings.get_setting("display/window/size/viewport_height")
	vec.size.window.center = Vector2(vec.size.window.width/2, vec.size.window.height/2)


func init_color():
	color.indicator = {}


func save(path_: String, data_: String):
	var path = path_ + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data_)


func load_data(path_: String):
	var file = FileAccess.open(path_, FileAccess.READ)
	var text = file.get_as_text()
	var json_object = JSON.new()
	var parse_err = json_object.parse(text)
	return json_object.get_data()



func get_all_substitutions(array_: Array):
	var result = [[]]
	
	for _i in array_.size():
		var slot_options = array_[_i]
		var next = []
		
		for arr_ in result:
			for option in slot_options:
				var pair = []
				pair.append_array(arr_)
				pair.append(option)
				next.append(pair)
		
		result = next
		for _j in range(result.size()-1,-1,-1):
			if result[_j].size() < _i+1:
				result.erase(result[_j])
	
	return result
