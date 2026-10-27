extends Control

#@onready var item_name_label: Label = $PanelContainer/VBoxContainer/ItemNameLabel
#@onready var item_description_label: Label = $PanelContainer/VBoxContainer/ItemDescriptionLabel
#@onready var use_button: Button = $PanelContainer/VBoxContainer/UseButton
#@onready var control: Control = $Control

#@onready var stats_menu: Control = $"../../../../../.." # ALERT this does not work
@export var sprite_2d: Sprite2D

var my_item_dict: Dictionary # isnt this outdated ?

var is_inventory_otherwise_ground: bool
var my_item: Item
var stats_menu: Control
var my_inventory: Control

#func _ready() -> void:
	#stats_menu = get_node("../MarginContainer/HBoxContainer/VBoxContainer/Inventory")

func add_item_dict(item: Dictionary) ->void:
	my_item_dict = item
	sprite_2d.frame = my_item_dict["frame"]
	return

func set_inventory(inventory: Control) -> void:
	my_inventory = inventory
	stats_menu = inventory.get_parent().get_parent().get_parent().get_parent()

func set_item(item: Item) -> void:
	my_item = item
	if is_instance_valid(item):
		sprite_2d.frame = item.get_node("Sprite2D").frame
	else:
		sprite_2d.frame = 90





func _on_button_pressed() -> void:
	my_inventory.set_selected_item(my_item)
