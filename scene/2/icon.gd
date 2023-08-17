extends MarginContainer


@onready var label = $Label


func _ready():
	update_size()


func update_size() -> void:
	custom_minimum_size = Vector2(Global.vec.size.letter)
