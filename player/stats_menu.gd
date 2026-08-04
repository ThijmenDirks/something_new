extends Control

@export_category("stats")
@export var strength: int = 10
@export var dexterity: int = 10
@export var intelligence: int = 10
@export var speed: int = 400
@export var max_hp: int = 100
@export var current_hp: int = 100
@export var race: bool
@export var level: int = 1
@export var xp: int = 0
@export var pending_stat_boosts: int = 5
@export var pending_levels: int = 0
@export_category("")

var is_leveling: bool = false

var inventory_items: Array[Item]

@onready var my_owner: Player = get_parent().get_parent()
@onready var stat_thingies: HBoxContainer = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer

func _enter_tree() -> void:
	#my_owner = get_parent().get_parent()
	pass

func setup():
	get_items_from_server.rpc_id(1)
	if pending_levels:
		set_levelup_button_visibility(true)
	else:
		set_levelup_button_visibility(false)
	visible = true


@rpc("any_peer", "call_local")
func fill_inventory(items: Array):
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority():
		return


@rpc("authority", "call_local")
func get_items_from_server():
	if not multiplayer.is_server() or not multiplayer.get_remote_sender_id() == get_multiplayer_authority():
		return
	fill_inventory.rpc_id(get_multiplayer_authority(), inventory_items)

func set_levelup_button_visibility(to: bool) -> void:
	$OtherButton/LevelUpButton.visible = to

# will only get called from server
#@rpc("any_peer", "call_local")
func change_ability_server_side(ability: StringName):
	if not multiplayer.is_server():# or not multiplayer.get_remote_sender_id() == 1:
		return
	print("changed ability to: ", ability)
	var new_ability: Ability = load(ability).instantiate()
	if new_ability:
		if new_ability is FirstAbility:
			#var target_node: Node2D = get_parent().get_parent().first_ability_node
			var target_node: Control = $MarginContainer/HBoxContainer/Classtuff/SlectedClasses/HBoxContainer/FristAbility
			if target_node.get_child_count() != 0:
				target_node.get_child(0).get_removed()
				target_node.remove_child(target_node.get_child(0))
			target_node.add_child(new_ability)
			new_ability.get_added()
		elif new_ability is SecondAbility:
			#var target_node: Node2D = get_parent().get_parent().second_ability_node
			var target_node: Control = $MarginContainer/HBoxContainer/Classtuff/SlectedClasses/HBoxContainer/SecondAbility
			if target_node.get_child_count() != 0:
				target_node.get_child(0).get_removed()
				target_node.remove_child(target_node.get_child(0))
			target_node.add_child(new_ability)
			new_ability.get_added()
		elif new_ability is PassiveAbility:
			#var target_node: Node2D = get_parent().get_parent().passive_ability_node
			var target_node: Control = $MarginContainer/HBoxContainer/Classtuff/SlectedClasses/HBoxContainer/PassiveAbility
			if target_node.get_child_count() != 0:
				target_node.get_child(0).get_removed()
				target_node.remove_child(target_node.get_child(0))
			target_node.add_child(new_ability)
			new_ability.get_added()
	change_ability_client_side.rpc_id(get_multiplayer_authority(), ability)
	change_ability_client_side.rpc(ability)


@rpc("any_peer", "call_local")
func change_ability_client_side(ability):
	if not multiplayer.get_remote_sender_id() == 1:# or not is_multiplayer_authority():
		return
	print("changed ability to: ", ability)
	var new_ability: Ability = load(ability).instantiate()
	if new_ability:
		if new_ability is FirstAbility:
			#var target_node: Node2D = get_parent().get_parent().first_ability_node
			var target_node: Control = $MarginContainer/HBoxContainer/Classtuff/SlectedClasses/HBoxContainer/FristAbility
			if target_node.get_child_count() != 0:
				#target_node.get_child(0).get_removed()
				target_node.remove_child(target_node.get_child(0))
			target_node.add_child(new_ability)
			new_ability.get_added()
		elif new_ability is SecondAbility:
			#var target_node: Node2D = get_parent().get_parent().second_ability_node
			var target_node: Control = $MarginContainer/HBoxContainer/Classtuff/SlectedClasses/HBoxContainer/SecondAbility
			if target_node.get_child_count() != 0:
				#target_node.get_child(0).get_removed()
				target_node.remove_child(target_node.get_child(0))
			target_node.add_child(new_ability)
			new_ability.get_added()
		elif new_ability is PassiveAbility:
			#var target_node: Node2D = get_parent().get_parent().passive_ability_node
			var target_node: Control = $MarginContainer/HBoxContainer/Classtuff/SlectedClasses/HBoxContainer/PassiveAbility
			if target_node.get_child_count() != 0:
				#target_node.get_child(0).get_removed()
				target_node.remove_child(target_node.get_child(0))
			target_node.add_child(new_ability)
			new_ability.get_added()

@rpc("any_peer", "call_local")
func change_stat(stat: int, amount: int) -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	if stat == 0:
		strength += amount
		stat_thingies.get_child(0).amount_label.text = str(strength)
		if strength <= 0:
			my_owner.die_server_side()
	if stat == 1:
		dexterity += amount
		stat_thingies.get_child(1).amount_label.text = str(dexterity)
		my_owner.speed += amount * 20
		if dexterity <= 0:
			my_owner.die_server_side()
	if stat == 2:
		intelligence += amount
		stat_thingies.get_child(2).amount_label.text = str(intelligence)
		if intelligence <= 0:
			my_owner.die_server_side()
	my_owner.update_stat(stat, amount)


@rpc("any_peer", "call_local")
func gain_xp(amount: int) -> void:
	var old_stat_boost_total: int = xp / 50
	var old_ability_total: int = xp / 100
	xp += amount
	change_pending_stat_boosts(xp / 50 - old_stat_boost_total)
	change_pending_levels(xp / 100 - old_ability_total)
	if pending_levels > 0 and not is_leveling:
		set_levelup_button_visibility(true)
	$MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/XPBar.value = xp % 100

func change_pending_stat_boosts(amount: int):
	pending_stat_boosts += amount
	$MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Label.text = str(pending_stat_boosts)

func change_pending_levels(amount: int):
	pending_levels += amount
	$MarginContainer/HBoxContainer/Classtuff/Label.text = str(pending_levels)


func _on_back_button_pressed() -> void:
	close.rpc_id(1)
	close()

@rpc("call_local")
func close():
	if (not is_multiplayer_authority()) and (not multiplayer.is_server()):
		return
	visible = false
	is_leveling = false
	get_parent().exit_stats_menu()

func _on_level_up_button_pressed() -> void:
	request_level_up.rpc_id(1)

@rpc("call_local")
func request_level_up():
	if not multiplayer.is_server():
		return
	if pending_levels > 0:
		level_up_server_side()
		level_up_client_side.rpc_id(get_multiplayer_authority())

func level_up_server_side() -> void:
	is_leveling = true
	if pending_levels < 1:
		set_levelup_button_visibility(false)

@rpc("any_peer", "call_local")
func level_up_client_side() -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	is_leveling = true
	set_levelup_button_visibility(false)


#@rpc("call_local")
#func change_ability(ability: PackedScene):
	#print("changed ability to: ", ability)
	#var new_ability: Ability = ability.instantiate()
	#if new_ability:
		#if new_ability is FirstAbility:
			#var target_node: Node2D = get_parent().get_parent().first_ability_node
			#if is_instance_valid(target_node.get_child(0)):
				#target_node.get_child(0).get_removed()
			#target_node.add_child(new_ability)
			#new_ability.get_added()
		#elif new_ability is SecondAbility:
			#var target_node: Node2D = get_parent().get_parent().second_ability_node
			#if is_instance_valid(target_node.get_child(0)):
				#target_node.get_child(0).get_removed()
			#target_node.add_child(new_ability)
			#new_ability.get_added()
		#elif new_ability is PassiveAbility:
			#var target_node: Node2D = get_parent().get_parent().passive_ability_node
			#if is_instance_valid(target_node.get_child(0)):
				#target_node.get_child(0).get_removed()
			#target_node.add_child(new_ability)
			#new_ability.get_added()
