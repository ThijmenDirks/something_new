extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var my_item: Dictionary

#@export var my_item_node_path: NodePath

func _enter_tree() -> void:
	sprite_2d = $Sprite2D
	my_item = ItemDatabase.scroll_of_fireball
	if my_item == {}:
		return
	sprite_2d.frame = my_item["frame"]
