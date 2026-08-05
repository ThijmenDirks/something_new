extends VBoxContainer

var inventory_items: Array[Item] = [preload("res://items/scrolls/scroll_of_fireball.tscn").instantiate()]
var ground_items: Array[Area2D] = []

@onready var own_inventory: GridContainer = $OwnInventory
@onready var ground_inventory: GridContainer = $VBoxContainer/GroundInventory

@onready var stats_menu: Control = $"../../../.."
@onready var my_owner: Player = $"../../../../../.."

func setup():
	return
	get_inventory_items_from_server.rpc_id(1)
	get_ground_items_from_server.rpc_id(1)

@rpc("any_peer", "call_local")
func fill_own_inventory(items: Array):
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority():
		return
	for child in own_inventory.get_children():
		own_inventory.remove_child(child)
	for item in items:
		own_inventory.add_child(item)

@rpc("any_peer", "call_local")
func fill_ground_inventory(items: Array):
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority():
		return
	for child in ground_inventory.get_children():
		ground_inventory.remove_child(child)
	var counter: int = 0
	for item in items:
		ground_inventory.add_child(item)
		counter += 1
		if counter == 10:
			break

@rpc("authority", "call_local")
func get_inventory_items_from_server():
	if not multiplayer.is_server() or not multiplayer.get_remote_sender_id() == get_multiplayer_authority():
		return
	fill_own_inventory.rpc_id(get_multiplayer_authority(), inventory_items)


@rpc("authority", "call_local")
func get_ground_items_from_server():
	if not multiplayer.is_server() or not multiplayer.get_remote_sender_id() == get_multiplayer_authority():
		return
	ground_items = my_owner.pickup_area.get_overlapping_areas()
	fill_ground_inventory.rpc_id(get_multiplayer_authority(), ground_items)
