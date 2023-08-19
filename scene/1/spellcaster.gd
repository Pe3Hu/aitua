extends MarginContainer


@onready var dices = $Dices


var mana = 3
var spell = null
var values = {}
var repeats = 0


func _ready() -> void:
	values.total = []
	values.current = []
	
	for _i in mana:
		var dice = Global.scene.dice.instantiate()
		dices.add_child(dice)
	
	test_all_spells()
	
#	var values_ = [5,5,1,1]
#	flip_dices(values_)
#
#	if check_spell_condition():
#		apply_spell()


func test_all_spells() -> void:
	for title in Global.dict.spell.title:
		spell = title
		roll_all_substitution()
		Global.stat.spell.damage[spell] /= Global.dict.substitution["6"]["3"]
		print([spell, Global.stat.spell.damage[spell]])
	


func roll_all_substitution() -> void:
	for substitution in Global.arr.dice.substitution[mana]:
		var edges = Global.arr.dice.substitution[mana][substitution].edges
		repeats = Global.arr.dice.substitution[mana][substitution].repeats
		flip_dices(edges)
		
		if check_spell_condition():
			apply_spell()


func flip_dices(values_: Array) -> void:
	values.total = []
	
	for _i in dices.get_child_count():
		var dice = dices.get_child(_i)
		var value = values_[_i]
		dice.flip_to_value(value)
		values.total.append(value)


func check_spell_condition() -> bool:
	values.current = []
	fill_facets_values()
	var description = Global.dict.spell.title[spell]
	var condition = Global.dict.spell.title[spell].condition
	
	match condition.type:
		"series":
			values.current = get_series()
			
			if values.current.size() >= condition.value:
				while values.current.size() > condition.value:
					values.current.pop_back()
			else:
				values.current = []
		"amount":
			var amount = 0
			
			for value in values.total:
				amount += value
			
			if amount >= condition.value:
				values.current.append_array(values.total)
		"duplicate":
			values.current = get_duplicate()
	
	return !values.current.is_empty()


func fill_facets_values() -> void:
	values.total = []
	
	for dice in dices.get_children():
		var value = dice.get_current_facet_value()
		values.total.append(value)


func get_series() -> Array:
	var uniques = []
	
	for value in values.total:
		if !uniques.has(value):
			uniques.append(value)
	
	uniques.sort()
	
	var series = [[uniques.back()]]
	
	for _i in range(uniques.size()-1, -1, -1):
		if _i > 0:
			var a = uniques[_i]
			var b = uniques[_i - 1]
			
			if a != b + 1:
				series.append([b])
			else:
				
				series.back().append(b)
	
	var max = {}
	var l = 0
	
	for values_ in series:
		if !max.has(values_.size()):
			max[values_.size()] = []
		
		max[values_.size()].append(values_)
		
		if l < values_.size():
			l = values_.size()
	
	return max[l].front()


func apply_spell() -> void:
	var description = Global.dict.spell.title[spell]
	var type = Global.dict.spell.title[spell].condition.type
	
	for effect in Global.dict.spell.title[spell].effect:
		var data = Global.dict.spell.title[spell].effect[effect]
		
		match data.impact:
			"damage":
				var damage = 0
		
				match data.criterion:
					"facet sum":
						for value in values.current:
							damage += value
					"number of cubes":
						get_lowest_values()
						damage = values.current.size()
						
					"maximum facet":
						for value in values.current:
							if value > damage:
								damage = value
				
				match data.operator:
					"add":
						damage += data.value
					"multiply":
						damage *= data.value
				
				
				#print([values.total, damage])
				
				if !Global.stat.spell.damage.has(spell):
					Global.stat.spell.damage[spell] = 0.0
				
				Global.stat.spell.damage[spell] += damage * repeats


func get_lowest_values() -> void:
	values.current.sort()
	var limit = Global.dict.spell.title[spell].condition.value
	var amount = 0
	var lowest = []
	
	while amount < limit:
		var value = values.current.pop_front()
		lowest.append(value)
		amount += value
	
	values.current = []
	values.current.append_array(lowest)


func get_duplicate() -> Array:
	var edges = {}
	
	for value in values.total:
		if !edges.has(value): 
			edges[value] = 0
		
		edges[value] += 1
	
	var max = 0
	
	for edge in edges:
		if edges[edge] > 1 and edge > max:
			max = edge
	
	if max > 0:
		return [max, max]
	else:
		return []
