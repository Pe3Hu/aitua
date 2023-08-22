extends MarginContainer


@onready var title = $VBox/Title
@onready var condition = $VBox/Condition
@onready var effects = $VBox/Effects

var charge = null


func fill_labels() -> void:
	title.text = str(name)
	var description = Global.dict.spell.title[title.text]
	charge = description.charge
	var value = str(description.condition.value.min)
	
	if description.condition.value.min != description.condition.value.max:
		value += " - " + str(description.condition.value.max)
	
	condition.text = description.condition.type + " " + value
	
	
	for index in description.effect:
		var effect = title.duplicate()
		effects.add_child(effect)
		var data = description.effect[index]
		
		effect.text = data.impact + " = " 
		
		if data.criterion != "no":
			effect.text += data.criterion
		
		match typeof(data.value):
			TYPE_FLOAT:
				if data.value != 0:
					match data.operator:
						"add":
							effect.text += " + "
						"multiply":
							effect.text += " * "
						"shift":
							effect.text += data.operator + " "
				
					effect.text += str(data.value)
			TYPE_STRING:
				#if data.value == "half edge":
				effect.text += data.value
