extends MarginContainer


@onready var bg = $BG
@onready var icon = $HBox/Icon

var dice = null
var value = null


func init(value_: int) -> void:
	value = value_


func _ready() -> void:
	var style = StyleBoxFlat.new()
	bg.set("theme_override_styles/panel", style)
	update_size()
	icon.label.text = str(value)


func update_size() -> void:
	custom_minimum_size = Vector2(Global.vec.size.facet)

