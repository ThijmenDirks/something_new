extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var my_item: Dictionary

#@export var my_item_node_path: NodePath

func _enter_tree() -> void:
	print("gound item exists !! parent: ", get_parent(), " doubble: ", get_parent().get_parent(), " peer: ", multiplayer.get_unique_id())
	sprite_2d = $Sprite2D
	my_item = ItemDatabase.scroll_of_fireball
	if my_item == {}:
		return
	sprite_2d.frame = my_item["frame"]
