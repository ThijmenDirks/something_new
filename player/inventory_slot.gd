extends Control

#@onready var item_name_label: Label = $PanelContainer/VBoxContainer/ItemNameLabel
#@onready var item_description_label: Label = $PanelContainer/VBoxContainer/ItemDescriptionLabel
#@onready var use_button: Button = $PanelContainer/VBoxContainer/UseButton
#@onready var control: Control = $Control
@onready var stats_menu: Control = $"../../../../../.."
@onready var sprite_2d: Sprite2D = $Sprite2D

var my_item: Dictionary

func add_item(item: Dictionary) ->void:
	my_item = item
	sprite_2d.frame = my_item["frame"]
	return


func _on_button_pressed() -> void:
	if my_item == {}:
		return
	stats_menu.info_tab.position = position
	stats_menu.info_tab.get_node("VBoxContainer/ItemNameLabel").text = my_item["name"]
	stats_menu.info_tab.get_node("VBoxContainer/ItemDescriptionLabel").text = my_item["description"]
	if my_item["slot"] == 0:
		stats_menu.info_tab.get_node("VBoxContainer/UseButton").text = "decipher"
	else:
		stats_menu.info_tab.get_node("VBoxContainer/UseButton").text = "equip"

# equip or decipher
func _on_use_button_pressed() -> void:
	pass # Replace with function body.
