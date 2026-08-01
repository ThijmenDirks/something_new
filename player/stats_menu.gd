extends Control


var inventory_items: Array[Item]


func setup():
	get_items_from_server.rpc_id(1)
	visible = true


@rpc("any_peer", "call_local")
func fill_inventoyr(items: Array):
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority():
		return


@rpc("authority", "call_local")
func get_items_from_server():
	if not multiplayer.is_server() or not multiplayer.get_remote_sender_id() == get_multiplayer_authority():
		return
	fill_inventoyr.rpc_id(get_multiplayer_authority(), inventory_items)


@rpc("any_peer", "call_local")
func change_ability_server_side(ability: PackedScene):
	if not multiplayer.is_server() or not multiplayer.get_remote_sender_id() == 1:
		return
	print("changed ability to: ", ability)
	var new_ability: Ability = ability.instantiate()
	if new_ability:
		if new_ability is FirstAbility:
			var target_node: Node2D = get_parent().get_parent().first_ability_node
			if is_instance_valid(target_node.get_child(0)):
				target_node.get_child(0).get_removed()
			target_node.add_child(new_ability)
			new_ability.get_added()
		elif new_ability is SecondAbility:
			var target_node: Node2D = get_parent().get_parent().second_ability_node
			if is_instance_valid(target_node.get_child(0)):
				target_node.get_child(0).get_removed()
			target_node.add_child(new_ability)
			new_ability.get_added()
		elif new_ability is PassiveAbility:
			var target_node: Node2D = get_parent().get_parent().passive_ability_node
			if is_instance_valid(target_node.get_child(0)):
				target_node.get_child(0).get_removed()
			target_node.add_child(new_ability)
			new_ability.get_added()
	change_ability_client_side.rpc_id(get_multiplayer_authority(), ability)


@rpc("any_peer", "call_local")
func change_ability_client_side(ability):
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority():
		return
	print("changed ability to: ", ability)
	var new_ability: Ability = ability.instantiate()
	if new_ability:
		if new_ability is FirstAbility:
			var target_node: Node2D = get_parent().get_parent().first_ability_node
			if is_instance_valid(target_node.get_child(0)):
				target_node.get_child(0).get_removed()
			target_node.add_child(new_ability)
			new_ability.get_added()
		elif new_ability is SecondAbility:
			var target_node: Node2D = get_parent().get_parent().second_ability_node
			if is_instance_valid(target_node.get_child(0)):
				target_node.get_child(0).get_removed()
			target_node.add_child(new_ability)
			new_ability.get_added()
		elif new_ability is PassiveAbility:
			var target_node: Node2D = get_parent().get_parent().passive_ability_node
			if is_instance_valid(target_node.get_child(0)):
				target_node.get_child(0).get_removed()
			target_node.add_child(new_ability)
			new_ability.get_added()


func _on_back_button_pressed() -> void:
	visible = false
	get_parent().exit_stats_menu()


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
