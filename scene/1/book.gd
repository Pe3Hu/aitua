extends MarginContainer


@onready var active = $Pages/Active
@onready var archive = $Pages/Archive


func reset() -> void:
	for page in active.get_children():
		active.remove_child(page)
		page.queue_free()
	
	for page in archive.get_children():
		archive.remove_child(page)
		page.queue_free()


func add_page(title_: String) -> void:
	var description = Global.dict.spell.title[title_]
	var page = Global.scene.page.instantiate()
	archive.add_child(page)
	page.name = title_
	page.fill_labels()


func page_archiving(page_: MarginContainer) -> void:
	var slot = Global.dict.spell.title[page_.title.text].slot
	active.remove_child(page_)
	archive.add_child(page_)
	var page = Global.scene.page.instantiate()
	active.add_child(page)
	active.move_child(page, slot)


func page_activation(page_: MarginContainer) -> void:
	var slot = Global.dict.spell.title[page_.title.text].slot
	archive.remove_child(page_)
	active.add_child(page_)
	active.move_child(page_, slot)
