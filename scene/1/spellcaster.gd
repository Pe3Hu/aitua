extends MarginContainer


@onready var book = $VBox/Book
@onready var dices = $VBox/Dices


var mana = 3
var element = null
var values = {}
var repeats = 0


func _ready() -> void:
	values.total = []
	values.current = []
	
	for _i in mana:
		var dice = Global.scene.dice.instantiate()
		dices.add_child(dice)
		dice.temp = false
	
	#test_all_spells()

	element = "earth"
	fill_book()
	var values_ = [6,4,2]
	flip_dices(values_)
	use_second_slot()

	if check_spell_condition():
		use_primary_slot()


func fill_book() -> void:
	book.reset()
	
	for title in Global.dict.spell.title:
		var description = Global.dict.spell.title[title]
		
		if description.element == element:
			book.add_page(title)
	
	for page in book.archive.get_children():
		book.page_activation(page)
	#var page = book.archive.get_child(0)


func test_all_spells() -> void:
	for element_ in Global.arr.element:
		element = element_
		fill_book()
		roll_all_substitution()
		Global.stat.element.damage[element] /= Global.dict.substitution["6"]["3"]
		print([element, Global.stat.element.damage[element]])


func roll_all_substitution() -> void:
	for substitution in Global.arr.dice.substitution[mana]:
		var edges = Global.arr.dice.substitution[mana][substitution].edges
		repeats = Global.arr.dice.substitution[mana][substitution].repeats
		flip_dices(edges)
		use_second_slot()
		var primary = book.active.get_child(0)
		print(primary.name, edges, values)
		
		while check_spell_condition() and primary.charge > 0:
			use_primary_slot()


func flip_dices(values_: Array) -> void:
	values.total = []
	values.current = []
	
	for _i in range(dices.get_child_count()-1, -1, -1):
		var dice = dices.get_child(_i)
		
		if _i < values_.size():
			var value = values_[_i]
			dice.flip_to_value(value)
		
		if dice.temp:
			dice.crush()
	
	update_total_values()


func update_total_values() -> void:
	values.total = []
	
	for dice in dices.get_children():
		var value = dice.get_current_facet_value()
		values.total.append(value)


func use_second_slot() -> void:
	var primary = book.active.get_child(0)
	var second = book.active.get_child(1)
	var description = {}
	description.primary = Global.dict.spell.title[primary.name]
	description.second = Global.dict.spell.title[second.name]
	var end = false
	
	while second.charge > 0 and !end:
		end = true
		
		match description.primary.condition.type:
			"series":
				var series = get_series()
				
				if series.size() > 1 and description.primary.condition.value.min > series.front().size():
					match description.second.effect["1"].operator:
						"shift":
							var max_shift = second.charge * description.second.effect["1"].value
							var extension = series[0].back() - 1
							var nearest = series[1].front()
							
							if extension - nearest <= max_shift:
								var shift = extension - nearest 
								second.charge -= shift
								var dice = find_dice_by_facet_value(nearest)
								
								if dice != null:
									dice.flip_to_value(extension)
									update_total_values()
									end = false
			"amount":
				match description.primary.effect["1"].criterion:
					"number of dices":
						var lowest = get_lowest_values(values.total)
						
						match description.second.effect["1"].operator:
							"facet donor":
								var donors = get_donors(lowest, description.second)
								
								if !donors.is_empty():
									add_temp_dice(donors.front(), description.second)
									second.charge -= 1
									end = false
					"fixed":
						match description.second.effect["1"].operator:
							"growth":
								var lowest = get_lowest_values(values.total)
								var donors = get_donors(lowest, description.second)
								
								if !donors.is_empty():
									var donor = donors.front()
									var dice = find_dice_by_facet_value(donor)
									var value = donor + description.second.effect["1"].value
									dice.flip_to_value(value)
									update_total_values()
									second.charge -= 1
									end = false
			"duplet":
				match description.second.condition.type:
					"parity":
						match description.second.effect["1"].operator:
							"facet donor":
								var donors = get_donors(values.total, description.second)
								
								if !donors.is_empty():
									add_temp_dice(donors.front(), description.second)
									second.charge -= 1
									end = false


func find_dice_by_facet_value(value_: int) -> Variant:
	for dice in dices.get_children():
		if dice.get_current_facet_value() == value_:
			return dice
	
	return null


func get_donors(values_: Array, description_: Dictionary) -> Array:
	var donors = []
	
	for value in values_:
		var flag = false
		match description_.condition.type:
			"value":
				flag = description_.condition.value.min <= value and description_.condition.value.max >= value
			"parity":
				var parity = value % 2
				flag = parity == 1 and description_.condition.value.min == "odd" or parity == 0 and description_.condition.value.min == "even"
		
		if flag:
			donors.append(value)
	
	return donors


func add_temp_dice(donor_: int, description_: Dictionary) -> void:
	var value = null
	
	match typeof(description_.effect["1"].value):
		TYPE_STRING:
			match description_.effect["1"].value:
				"half edge":
					value = donor_ / 2
		TYPE_INT:
			value = description_.effect["1"].value
	
	var donor = find_dice_by_facet_value(donor_)
	donor.flip_to_value(donor_ - value)
	var dice = Global.scene.dice.instantiate()
	dices.add_child(dice)
	dice.flip_to_value(value)
	update_total_values()


func check_spell_condition() -> bool:
	values.current = []
	fill_facets_values()
	var primary = book.active.get_child(0).name
	var condition = Global.dict.spell.title[primary].condition
	
	match condition.type:
		"series":
			values.current = get_longest_series()
			
			if values.current.size() >= condition.value.min:
				while values.current.size() > condition.value.min:
					values.current.pop_back()
			else:
				values.current = []
				
		"amount":
			var amount = 0
			
			for value in values.total:
				amount += value
			
			if amount >= condition.value.min:
				values.current.append_array(values.total)
		"duplet":
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
	
	return series


func get_longest_series() -> Array:
	var series = get_series()
	var max = {}
	var l = 0
	
	for values_ in series:
		if !max.has(values_.size()):
			max[values_.size()] = []
		
		max[values_.size()].append(values_)
		
		if l < values_.size():
			l = values_.size()
	
	return max[l].front()


func use_primary_slot() -> void:
	var primary = book.active.get_child(0)
	primary.charge -= 1
	var description = Global.dict.spell.title[primary.name]
	
	for effect in description.effect:
		var data = description.effect[effect]
		
		match data.impact:
			"damage":
				var damage = 0
		
				match data.criterion:
					"sum of facets":
						for value in values.current:
							damage += value
					"number of dices":
						var lowest = get_lowest_values(values.current)
						values.current = []
						values.current.append_array(lowest)
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
				
				if damage >= 0:
					print([primary, values.total, damage])
				
				if !Global.stat.element.damage.has(element):
					Global.stat.element.damage[element] = 0.0
				
				Global.stat.element.damage[element] += damage * repeats
	
	print(values.current)
	while !values.current.is_empty():
		var value = values.current.pop_front()
		var dice = find_dice_by_facet_value(value)
		dice.crush()
		update_total_values()


func get_lowest_values(values_: Array) -> Array:
	var lowest = []
	
	if !values_.is_empty():
		values_.sort()
		var primary = book.active.get_child(0).name
		var limit = Global.dict.spell.title[primary].condition.value.min
		var amount = 0
		var temp = []
		temp.append_array(values_)
		
		while amount < limit and !temp.is_empty():
			var value = temp.pop_front()
			lowest.append(value)
			amount += value
		
	return lowest


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
