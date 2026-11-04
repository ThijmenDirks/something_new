extends VBoxContainer

const INVENTORY_SLOT = preload("uid://desjwamfba0fx")

@onready var own_inventory: GridContainer = $OwnInventory
@onready var ground_inventory: GridContainer = $VBoxContainer/Label/PanelContainer/HBoxContainer/GroundInventory

@onready var stats_menu: Control = $"../../../.."
@onready var my_player: Player = $"../../../../../.."
@onready var level: Node = $"../../../../../../../.."

var own_items: Array[Item]#Array[Dictionary] = [ItemDatabase.scroll_of_fireball]#[preload("res://items/scrolls/scroll_of_fireball.tscn").instantiate()]
var ground_items: Array[Area2D]#Array[Area2D] = []

var selected_item: Item


func enter():
	for slot in own_inventory.get_children():
		slot.set_inventory(self)
	get_own_items_from_server.rpc_id(1)
	get_ground_items_from_server.rpc_id(1)

func exit() -> void:
	pass


@rpc("authority", "call_local")
func get_own_items_from_server():
	# this funs seemc superfluous
	if not multiplayer.is_server() or not multiplayer.get_remote_sender_id() == get_multiplayer_authority():
		return
	var own_item_ids: Array[int] = []
	for item in own_items:
		own_item_ids.append(item.my_id)
	fill_own_inventory.rpc_id(get_multiplayer_authority(), own_item_ids)


@rpc("authority", "call_local")
func get_ground_items_from_server():
	# this funs seemc superfluous
	if not multiplayer.is_server() or not multiplayer.get_remote_sender_id() == get_multiplayer_authority():
		return
	var ground_item_ids: Array[int] = []
	for item in my_player.pickup_area.get_overlapping_areas():
		ground_item_ids.append(item.my_id)
	#assert(false)
	fill_ground_inventory.rpc_id(get_multiplayer_authority(), ground_item_ids)
	#ground_items = my_player.pickup_area.get_overlapping_areas()


@rpc("any_peer", "call_local")
func fill_own_inventory(item_ids: Array[int]):
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority():
		return
	#for child in own_inventory.get_children():
		#own_inventory.remove_child(child)
	#for i in range(min(items.size(), 10)):
		#own_inventory.get_child(i).add_item(items[i])
	#own_items = items
	for i in range(10):
		if i < item_ids.size():
			add_item_to_own_inventory(level.all_items.get(item_ids[i]), i) # WARNING not sure what happens when the id is not in the dict !
			#own_inventory.get_child(i).set_item(items[i])
			#add_item_to_own_inventory(items[i])
		else:
			add_item_to_own_inventory(null, i)
			#own_inventory.get_child(i).set_item(null)
			#add_item_to_own_inventory(null)
	#for item in items:
	#assert(false)


@rpc("any_peer", "call_local")
func fill_ground_inventory(item_ids: Array[int]) -> void:
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority():
		return
	for child in ground_inventory.get_children():
		ground_inventory.remove_child(child)
		child.queue_free()
	for id in item_ids:
		add_item_to_ground_inventory(level.all_items.get(id))


func add_item_to_own_inventory(item: Item, slot: int=0) -> void:
	print("test 7")
	if is_instance_valid(item):
		own_items.append(item)

	for i in range(10):
		if own_inventory.get_child(i).my_item == null:
			own_inventory.get_child(i).set_item(item)
			break
		print("test 8")
	#if is_instance_valid(own_inventory.get_child(slot)):
		#own_inventory.get_child(slot).set_item(item)
		#print("test 8")

	# might be cleaner to also make this func add it to own_items, and using that same var repel the "slot" var
	# it mitght be useful to keep the "slot" var to make organiznig inventory possile. maybe store the slot in the item itself ??

func add_item_to_ground_inventory(item: Item) -> void:
	ground_items.append(item)
	if is_instance_valid(ground_inventory):
		var new_inventory_slot = INVENTORY_SLOT.instantiate()
		new_inventory_slot.is_inventory_otherwise_ground = false
		new_inventory_slot.set_inventory(self)
		new_inventory_slot.set_item(item)
		ground_inventory.add_child(new_inventory_slot)

func remove_item_from_own_inventory(item: Item) -> void:
	own_items.erase(item)
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
	if item in own_items: # actually really dirty
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
@rpc("any_peer", "call_local")
func item_entered(item_id: int) -> void:
	if not (multiplayer.get_remote_sender_id() == 1 or multiplayer.get_remote_sender_id() == 0):
		return
	var new_item: Item = level.get_node(str("Items/", item_id))
	if is_multiplayer_authority():
		add_item_to_ground_inventory(new_item)
	else: # is server, but not the server-peer
		ground_items.append(new_item)

#@rpc("any_peer", "call_local")
func item_exited(item_id: int) -> void:
	var item: Item = level.get_node(str("Items/", item_id))
	if is_multiplayer_authority():
		remove_item_from_ground_inventory(item)
	else: # is server, but not the server-peer
		ground_items.erase(item)




func _on_pickup_button_pressed() -> void:
	print("test 0")
	# should also ask for which slot to move to. for now, refuse to pickup when inventory is full
	if own_items.size() < 10:
		print("test 0.5")
		request_pickup_selected_item.rpc_id(1, selected_item.my_id)


@rpc("any_peer", "call_local")
func request_pickup_selected_item(item_id: int) -> void:
	print("test 1")
	if not multiplayer.is_server():
		return
	# check wheter can pickup using items ["nodepath"]
	var picked_item: Item = level.get_node(str("Items/", item_id))
	if not is_instance_valid(picked_item):
		return
	print("test 2")
	pickup_item_server_side(picked_item)
	pickup_selected_item_verified.rpc_id(multiplayer.get_remote_sender_id())
	remove_item_from_ground.rpc(item_id)


func pickup_item_server_side(item: Item):
	print("test 3")
	if not is_multiplayer_authority():
		own_items.append(item)
		item.owner = self
		print("test 4 this should ot be printed cause no peers at hte moment")

@rpc("any_peer", "call_local")
func pickup_selected_item_verified():
	print("test 5")
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority:
		return
	if not is_instance_valid(selected_item):
		return
	print("test 6")
	#own_items.append(selected_item)
	add_item_to_own_inventory(selected_item, own_items.size())
	#selected_item.owner = self # not sure whether i meant "my_owner"
	selected_item.my_owner = self
	print("test 9")
	#add item to inventory var and node

@rpc("any_peer", "call_local")
func remove_item_from_ground(item_id: int):
	print("test 10")
	if not multiplayer.get_remote_sender_id() == 1:
		return
	var item: Item = level.get_node(str("Items/", item_id))
	if is_instance_valid(item):
		item.get_parent().remove_child(item)
	print("test 11")



func _on_drop_button_pressed() -> void:
	request_drop_selected_item.rpc_id(1,selected_item.my_id)


@rpc("authority", "call_local")
func request_drop_selected_item(item_id: int) -> void:
	if not multiplayer.is_server():
		return
	# check wheter can pickup using items ["nodepath"]
	var dropped_item: Item = level.all_items[item_id]
	if not is_instance_valid(dropped_item):
		return
	drop_item_server_side(dropped_item)
	drop_selected_item_verified.rpc_id(multiplayer.get_remote_sender_id())
	add_item_to_ground.rpc(item_id, stats_menu.get_parent().get_parent().global_position)


func drop_item_server_side(item: Item):
	if not is_multiplayer_authority():
		own_items.erase(item)

@rpc("any_peer", "call_local")
func drop_selected_item_verified():
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority:
		return
	if not is_instance_valid(selected_item):
		return
	remove_item_from_own_inventory(selected_item)

@rpc("any_peer", "call_local")
func add_item_to_ground(item_id: int, drop_position: Vector2):
	if not multiplayer.get_remote_sender_id() == 1:
		return
	var item: Item = level.all_items[item_id]
	if is_instance_valid(item):
		item.global_position = drop_position
		level.items_node.add_child(item)

func _on_use_button_pressed() -> void:
	if selected_item is HandItem: # might later make an "Equipable" class
		pass
	if selected_item is Scroll:
		pass


func _on_equip_armor_button_pressed() -> void:
	request_equip_armor.rpc_id(1, selected_item.my_id)

@rpc("authority", "call_local")
func request_equip_armor(item_id: int) -> void:
	if not multiplayer.is_server():
		return
	# check wheter can equip (?) using items ["nodepath"]
	var equiped_item: Item# = level.get_node(str("Items/", item_id))

	for item in own_inventory:
		if item.my_id == item_id:
			equiped_item = item
			remove_item_from_own_inventory(equiped_item)
	for item in ground_inventory:
		if item.my_id == item_id:
			equiped_item = item
			remove_item_from_ground_inventory(equiped_item)
			remove_item_from_ground.rpc(item_id)

	if not is_instance_valid(equiped_item):
		return

	# remove current armor
	if my_player.armor_node.get_children():
		if own_items.size() < 10:
			add_item_to_own_inventory(my_player.armor_node.get_child(0), own_items.size() - 1)
		else:
			add_item_to_ground_inventory(my_player.armor_node.get_child(0))
			add_item_to_ground.rpc(my_player.armor_node.get_child(0).my_id, stats_menu.get_parent().get_parent().global_position)

	equip_armor_server_side(equiped_item)
	equip_armor_verified.rpc_id(multiplayer.get_remote_sender_id())
	#remove_item_from_ground.rpc(str("Items/", item_id))

# shouldnt the armor be equiped at every peer ?
func equip_armor_server_side(item: Item) -> void:
	if not is_multiplayer_authority():
		own_items.erase(item)
		my_player.armor_node.add_child(item)

@rpc("any_peer", "call_local")
func equip_armor_verified() -> void:
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority:
		return
	if not is_instance_valid(selected_item) or not selected_item is Armor:
		return
	if my_player.armor_node.get_children():
		if own_items.size() < 10:
			add_item_to_own_inventory(my_player.armor_node.get_child(0), own_items.size() - 1)
		else:
			add_item_to_ground_inventory(my_player.armor_node.get_child(0))
	my_player.armor_node.add_child(selected_item)
	#own_items.append(selected_item)
	#add_item_to_own_inventory(selected_item, own_items.size() - 1)



func _on_equip_left_button_pressed() -> void:
	pass # Replace with function body.

func _on_equip_right_button_pressed() -> void:
	pass # Replace with function body.

@rpc("authority", "call_local")
func request_equip_hand_item(item_id: int, right_hand_otherwise_left: bool) -> void:
	pass

func equip_hand_item_server_side(item: Item) -> void:
	pass

@rpc("any_peer", "call_local")
func equip_hand_item_verified() -> void:
	pass

func find_item_in_inventories_by_id(item_id: int) -> Item:
	for item in own_inventory:
		if item.my_id == item_id:
			return item
	for item in ground_inventory:
		if item.my_id == item_id:
			return item
	return null


# 1: bij moeder vragen naarhuisarts toen diagnose, -> hunnnusbellen naar dossier
# 2: Romy kan briefschrijven voor naar UU over kutjeugd en zo extra tijd zonder autisme
# 3: moeder vragen naar waar dossier moet zijn
# 4: AB het spectrum, daar ook gedoe, miss. dat zij iets hebben.

# nieuwediagnse: eerst ff naar Romy, wilt ze graag
