extends MarginContainer


@onready var dices = $Dices


var mana = 3


func _ready() -> void:
	for _i in mana:
		var dice = Global.scene.dice.instantiate()
		dices.add_child(dice)
	
	var values = [1,2,3]
	flip_dices(values)


func flip_dices(values_: Array) -> void:
	for _i in dices.get_child_count():
		var dice = dices.get_child(_i)
		var value = values_[_i]
		dice.flip_to_value(value)
	
