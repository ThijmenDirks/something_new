extends VBoxContainer

var inventory_items: Array[Dictionary] = [ItemDatabase.scroll_of_fireball]#[preload("res://items/scrolls/scroll_of_fireball.tscn").instantiate()]
var ground_items: Array[Area2D] = []

@onready var own_inventory: GridContainer = $OwnInventory
@onready var ground_inventory: GridContainer = $VBoxContainer/GroundInventory

@onready var stats_menu: Control = $"../../../.."
@onready var my_owner: Player = $"../../../../../.."

func setup():
	#return
	get_inventory_items_from_server.rpc_id(1)
	get_ground_items_from_server.rpc_id(1)

@rpc("any_peer", "call_local")
func fill_own_inventory(items: Array):
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority():
		return
	#for child in own_inventory.get_children():
		#own_inventory.remove_child(child)
	#for item in items:
		#own_inventory.add_child(item)
	for i in range(min(items.size(), 10)):
		own_inventory.get_child(i).add_item(items[i])
		# please uses the add_item_to_own_inventory function

@rpc("any_peer", "call_local")
func fill_ground_inventory(items: Array):
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority():
		return
	#for child in ground_inventory.get_children():
		#ground_inventory.remove_child(child)
	#var counter: int = 0
	#for item in items:
		#ground_inventory.add_child(item)
		#counter += 1
		#if counter == 10:
			#break
	for i in range(min(items.size(), 10)):
		ground_inventory.get_child(i).add_item(items[i])

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




func add_item_to_own_inventory(item) -> void:
	pass




func ground_area_exited(item: Area2D) -> void:
	pass
	# loop trough ground_inventory, if the dicts ["node_path"] equals that of the item, remove it.
	# if the ground_inventory is now >= 10:# , put the 10th (9th) value in a var
	# loop trough the groundInventory slots, if their dicts ["node_path"] equals that of the item, replace their dict with the 10th (9th) value in ground_inventory # that in the var, or some "amtpy_item" otehrwise


func pickup_item(item) -> void:
	request_pickup_item.rpc_id(1, item)


@rpc
func request_pickup_item(item) -> void:
	pass
	# check wheter can pickup using items ["nodepath"]
	pickup_item_server_side(item)
	pickup_item_verified.rpc_id(multiplayer.get_remote_sender_id())
	remove_item_from_ground.rpc(item["nodepath"])



func pickup_item_server_side(nodepath):
	pass
	#add item to inventory var

@rpc
func pickup_item_verified():
	pass
	#add item to inventory var and node

@rpc
func remove_item_from_ground(nodepath):
	pass
	#time.get_parent().remove_child(get_node(nodepath) # does not work exaclty like this with the reltaive/absolute nodepath and such
	#item.queue_free()
	# thiw will trigger the on_area_exited
