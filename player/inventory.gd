extends VBoxContainer

const INVENTORY_SLOT = preload("uid://desjwamfba0fx")

@onready var own_inventory: GridContainer = $OwnInventory
@onready var ground_inventory: GridContainer = $VBoxContainer/Label/PanelContainer/HBoxContainer/GroundInventory

@onready var stats_menu: Control = $"../../../.."
@onready var my_owner: Player = $"../../../../../.."
@onready var level: Node = $"../../../../../../../.."

var inventory_items: Array[Item]#Array[Dictionary] = [ItemDatabase.scroll_of_fireball]#[preload("res://items/scrolls/scroll_of_fireball.tscn").instantiate()]
var ground_items: Array[Area2D]#Array[Area2D] = []

var selected_item: Item

func setup():
	#return
	for slot in own_inventory.get_children():
		slot.set_inventory(self)
	get_inventory_items_from_server.rpc_id(1)
	get_ground_items_from_server.rpc_id(1)


@rpc("authority", "call_local")
func get_inventory_items_from_server():
	# this funs seemc superfluous
	if not multiplayer.is_server() or not multiplayer.get_remote_sender_id() == get_multiplayer_authority():
		return
	fill_own_inventory.rpc_id(get_multiplayer_authority(), inventory_items)


@rpc("authority", "call_local")
func get_ground_items_from_server():
	# this funs seemc superfluous
	if not multiplayer.is_server() or not multiplayer.get_remote_sender_id() == get_multiplayer_authority():
		return
	ground_items = my_owner.pickup_area.get_overlapping_areas()
	fill_ground_inventory.rpc_id(get_multiplayer_authority(), ground_items)


@rpc("any_peer", "call_local")
func fill_own_inventory(items: Array):
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority():
		return
	#for child in own_inventory.get_children():
		#own_inventory.remove_child(child)
	#for i in range(min(items.size(), 10)):
		#own_inventory.get_child(i).add_item(items[i])
	inventory_items = items
	for i in range(10):
		if i < items.size():
			add_item_to_own_inventory(items[i], i)
			#own_inventory.get_child(i).set_item(items[i])
			#add_item_to_own_inventory(items[i])
		else:
			add_item_to_own_inventory(null, i)
			#own_inventory.get_child(i).set_item(null)
			#add_item_to_own_inventory(null)
	#for item in items:


@rpc("any_peer", "call_local")
func fill_ground_inventory(items: Array):
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority():
		return
	#for child in ground_inventory.get_children():
		#ground_inventory.remove_child(child)
	#for i in range(min(items.size(), 10)):
		#ground_inventory.get_child(i).add_item(items[i])
	ground_items = items
	for child in ground_inventory.get_children():
		ground_inventory.remove_child(child)
		child.queue_free()
	for item in items:
		add_item_to_ground_inventory(item)


func add_item_to_own_inventory(item: Item, slot: int) -> void:
	own_inventory.get_child(slot).set_item(item)
	# might be vleaner to also make this func add it to inventory_items, and using that same var repel the "slot" var
	# it mitght be useful to keep the "slot" var to make organiznig inventory possile. maybe store the slot in the item itself ??

func add_item_to_ground_inventory(item: Item) -> void:
	var new_inventory_slot = INVENTORY_SLOT.instantiate()
	new_inventory_slot.is_inventory_otherwise_ground = false
	new_inventory_slot.set_inventory(self)
	new_inventory_slot.set_item(item)
	ground_inventory.add_child(new_inventory_slot)

func remove_item_from_own_inventory(item: Item) -> void:
	inventory_items.erase(item)
	for child in own_inventory.get_children():
		if child.my_item == item:
			child.set_item(null)
			#own_inventory.remove_child(child)
			#child.queue_free()

func remove_item_from_ground_inventory(item: Item) -> void:
	ground_items.erase(item)
	for child in ground_inventory.get_children():
		if child.my_item == item:
			ground_inventory.remove_child(child)
			child.queue_free()


func set_selected_item(item: Item) -> void:
	if not is_instance_valid(item):
		return
	selected_item = item
	stats_menu.info_tab.position = position
	stats_menu.info_tab.get_node("VBoxContainer/ItemNameLabel").text = item.name
	stats_menu.info_tab.get_node("VBoxContainer/ItemDescriptionLabel").text = item.description
	if item in inventory_items: # actually really dirty
		stats_menu.info_tab.get_node("VBoxContainer/PickupButton").visible = false
		stats_menu.info_tab.get_node("VBoxContainer/DropButton").visible = true
	else:
		stats_menu.info_tab.get_node("VBoxContainer/PickupButton").visible = true
		stats_menu.info_tab.get_node("VBoxContainer/DropButton").visible = false
	if item is Scroll:
		stats_menu.info_tab.get_node("VBoxContainer/UseButton").text = "decipher"
	else:
		stats_menu.info_tab.get_node("VBoxContainer/UseButton").text = "equip"
	stats_menu.info_tab.visible = true


# not finished
#@rpc("any_peer", "call_local")
# unused
func item_entered(item_id: int) -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	#var item_node_path: String
	var new_item: Item = level.get_node(str("Items/", item_id))
	ground_items.append(new_item)
	add_item_to_ground_inventory(new_item)

#@rpc("any_peer", "call_local")
func item_exited(item: Item) -> void:
	#print("removing id: ", item_id)
	#if not multiplayer.get_remote_sender_id() == 1:
		#return
	#for item: Item in ground_items:
		#if item.my_id:
	remove_item_from_ground_inventory(item)



func _on_pickup_button_pressed() -> void:
	# should also ask for which slot to move to. for now, refuse to piclup when inventory is full
	if inventory_items.size() < 10:
		request_pickup_selected_item(selected_item.my_id)


@rpc("any_peer", "call_local")
func request_pickup_selected_item(item_id: int) -> void:
	print("test 1.0")
	if not multiplayer.is_server():
		return

	# check wheter can pickup using items ["nodepath"]

	var picked_item: Item = level.get_node(str("Items/", item_id))
	#for item in ground_items:
		#if item.my_id == item_id:
			#picked_item = item
			#break
	if not is_instance_valid(picked_item):
		return
	pickup_item_server_side(picked_item)
	pickup_selected_item_verified.rpc_id(multiplayer.get_remote_sender_id())
	remove_item_from_ground.rpc(str("Items/", item_id))


func pickup_item_server_side(item: Item):
	print("test 2")
	#ground_items.erase(item)
	if not is_multiplayer_authority():
		inventory_items.append(item)
	#add item to inventory var
	# remove it from ground_inventory. DONT! exited area should fix that
	# remove the item from the floor and the tree, the item shold become a orphan, UNLESS it is equiped instead of pickedup.

@rpc("any_peer", "call_local")
func pickup_selected_item_verified():
	print("test 3")
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority:
		return
	#var picked_item: Item = level.get_node(str("Items/", item_id))
	#for item in ground_items:
		#if item.my_id == item_id:
			#picked_item = item
			#break
	if not is_instance_valid(selected_item):
		return
	inventory_items.append(selected_item)
	add_item_to_own_inventory(selected_item, inventory_items.size() - 1)
	#add item to inventory var and node

@rpc("any_peer", "call_local")
func remove_item_from_ground(item_nodepath: NodePath):
	print("test 4")
	if not multiplayer.get_remote_sender_id() == 1:
		return
	var item: Item = level.get_node(item_nodepath)
	if is_instance_valid(item):
		item.get_parent().remove_child(item)
		print("removed item: ", item, "path:l ", item_nodepath)
	else:
		print("didnt remove item ", item_nodepath)
	#item.get_parent().remove_child(get_node(nodepath) # does not work exaclty like this with the reltaive/absolute nodepath and such
	# thiw will trigger the on_body_exited




func _on_drop_button_pressed() -> void:
	request_drop_selected_item(selected_item.my_id)


@rpc("authority", "call_local")
func request_drop_selected_item(item_id: int) -> void:
	if not multiplayer.is_server():
		return

	# check wheter can pickup using items ["nodepath"]

	var dropped_item: Item = level.all_items[item_id]
	#for item in ground_items:
		#if item.my_id == item_id:
			#picked_item = item
			#break
	if not is_instance_valid(dropped_item):
		return
	drop_item_server_side(dropped_item)
	drop_selected_item_verified.rpc_id(multiplayer.get_remote_sender_id())
	add_item_to_ground.rpc(item_id, stats_menu.get_parent().get_parent().global_position)


func drop_item_server_side(item: Item):
	if not is_multiplayer_authority():
		inventory_items.erase(item)
	#add item to inventory var
	# remove it from ground_inventory. DONT! exited area should fix that
	# remove the item from the floor and the tree, the item shold become a orphan, UNLESS it is equiped instead of pickedup.

@rpc("any_peer", "call_local")
func drop_selected_item_verified():
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority:
		return
	#var picked_item: Item = level.get_node(str("Items/", item_id))
	#for item in ground_items:
		#if item.my_id == item_id:
			#picked_item = item
			#break
	if not is_instance_valid(selected_item):
		return
	#inventory_items.erase(selected_item)
	remove_item_from_own_inventory(selected_item)
	#add item to inventory var and node

@rpc("any_peer", "call_local")
func add_item_to_ground(item_id: int, drop_position: Vector2):
	if not multiplayer.get_remote_sender_id() == 1:
		return
	var item: Item = level.all_items[item_id]
	if is_instance_valid(item):
		item.global_position = drop_position
		level.items_node.add_child(item)
		#print("removed item: ", item, "path:l ", item_nodepath)
	#else:
		#print("didnt remove item ", item_nodepath)
	#item.get_parent().remove_child(get_node(nodepath) # does not work exaclty like this with the reltaive/absolute nodepath and such
	# thiw will trigger the on_body_exited
