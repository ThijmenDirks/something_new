extends Node2D
# spell_cast_systemy
const FIREBALL = preload("uid://dsxug0ov6dms5") #debugg

@onready var spell_drawer: Control = $"../Interface/SpellDrawer"
@onready var aim_timer: Timer = $AimTimer

@export var all_equiped_spells: Array[Dictionary]

var spell_input: Array[int] # might get un-global
var selected_spell: Spell

var target_positionnnn: Vector2

var current_accessable_spells: Array
var used_from_ability: int # with being "not being called from ability"

var is_waiting_for_spell: bool = false # can only be true in server
var is_waiting_for_spell_target_posiiton: bool = false

func _ready() -> void:
	all_equiped_spells.append(SpellDatabse.fireball)



# since this func should only get called from player, limited_spell_list will always get something
# that is not true. it gets called from server.
@rpc("any_peer", "call_local")
func start_casting_spell_old(limited_spell_list: Array[Dictionary] = []) -> void:
	# calling this func already assumes the player can cast spells
	if not multiplayer.get_remote_sender_id() == 1:
		return
	target_positionnnn = Vector2.ZERO

	spell_drawer.setup()
	await spell_drawer.spell_is_finished
	spell_input = spell_drawer.spell_input

	#var a = get_spell_by_spell_input.rpc_id(1, spell_input)

@rpc("any_peer", "call_local")
func start_casting_spell(a: Array) -> void:
	print("test 6")
	if not multiplayer.is_server():
		return
	current_accessable_spells = a
	is_waiting_for_spell = true
	print("test 7")
	spell_drawer.setup.rpc_id(get_multiplayer_authority()) # this wont work. make it a .rpc_id(get_multiplayer_authority()).
	#await spell_drawer.spell_is_finished
	#spell_input = spell_drawer.spell_input

	return # end of function

	#var selected_spell_dict: Dictionary# = get_spell_by_spell_input(spell_input, limited_spell_list)
#
	##print("test 1 ", selected_spell)
	##if not is_instance_valid(selected_spell):
	#if selected_spell_dict == {}:
		##print("test 1.5")
		#miscast()
		#return
	#if selected_spell_dict.is_aimable:
		##print("test 2")
		#aim_timer.start()
		#await aim_timer.timeout
		##print("test 3")
	#cast_the_spell.rpc(selected_spell_dict.my_file_path)
	#cast_the_spell.rpc(load(selected_spell_dict.my_file_path))

@rpc("any_peer", "call_local")
func get_spell_by_spell_input(input: Array[int]):
	if not multiplayer.is_server():
		return
	#var limited_spell_list = current_accessable_spells
	var spell_that_will_cast: Dictionary = {}
	if current_accessable_spells:
		for spell: Dictionary in current_accessable_spells:
			if spell.input_code == input:
				spell_that_will_cast = spell
	else:
		for spell: Dictionary in all_equiped_spells:
			if spell.input_code == input:
				spell_that_will_cast = spell

	return spell_that_will_cast

	if spell_that_will_cast == {}:
		#miscast
		get_parent().position.x += 50
		return

	if spell_that_will_cast["is_aimable"]:
		aim_timer.start()
		#await aim_timer.timeout
		print("final target pos: ", target_positionnnn)

	if used_from_ability == 1:
		#get_parent().first_ability_node.get_child(0).cast_the_spell.rpc_id(1, [spell_that_will_cast, target_positionnnn])
		get_parent().first_ability_node.get_child(0).cast_the_spell.rpc([spell_that_will_cast, target_positionnnn])
	elif used_from_ability == 2:
		get_parent().second_ability_node.get_child(0).cast_the_spell.rpc([spell_that_will_cast, target_positionnnn])
	else:
		#cast_the_spell.rpc_id(1, spell_that_will_cast)
		cast_the_spell.rpc([spell_that_will_cast, target_positionnnn])


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventScreenTouch:
			#$Sprite2D.global_position = (event.position) + get_parent().position - Vector2(1920, 1080)/2
			if aim_timer.time_left != 0 or true:
				#selected_spell.target_position = to_global(event.position)
				target_positionnnn = event.position + get_parent().position - Vector2(1920, 1080)/2
				#set_target_position.rpc_id(1, target_positionnnn)
				print("target pos: ", target_positionnnn)
				print("id: ")#. get)
				if is_waiting_for_spell_target_posiiton: # this might make the previous if_statement unneccesary
					#set_target_position.rpc_id(1, event.position + get_parent().position - Vector2(1920, 1080)/2)
					aim_timer.stop()
					cast_this_spell_second_part.rpc_id(1, event.position + get_parent().position - Vector2(1920, 1080)/2)

				#selected_spell.target_position = event.position + get_parent().position - Vector2(1920, 1080)/2

				#$Sprite2D.global_position = (event.position)
				#print("target pos: ", to_global(event.position))

var spell_that_is_being_cast # should it be this global? i dont know... # if so, it should only be used at the server
@rpc("any_peer", "call_local")
func cast_this_spell_second_part(target_position: Vector2):
	if not multiplayer.is_server():
		return
	aim_timer.stop()
	target_positionnnn = target_position
	set_is_waiting_for_spell_target_posiiton.rpc_id(get_multiplayer_authority(), false)
	# maybe i dont even need this if-else
	#if spell_that_is_being_cast.is_aimable: # this cannot work RN, probably
		#pass
	#else:
		#pass
	var spell_that_will_cast = spell_that_is_being_cast

	if spell_that_will_cast == {}:
		#miscast
		get_parent().position.x += 50
		return

	if used_from_ability == 1:
		#get_parent().first_ability_node.get_child(0).cast_the_spell.rpc_id(1, [spell_that_will_cast, target_positionnnn])
		get_parent().first_ability_node.get_child(0).cast_the_spell.rpc([spell_that_will_cast, target_positionnnn])
	elif used_from_ability == 2:
		get_parent().second_ability_node.get_child(0).cast_the_spell.rpc([spell_that_will_cast, target_positionnnn])
	else:
		#cast_the_spell.rpc_id(1, spell_that_will_cast)
		cast_the_spell_final.rpc([spell_that_will_cast, target_positionnnn])

@rpc("any_peer", "call_local")
func cast_the_spell_final(args: Array):
	pass
	# and here we finally cast the spell
	var spell = args[0]#spell_that_is_being_cast
	var target_pos = args[1]
	var my_owner = get_parent()
	#if target_pos is too far from the player, fuck him up, because that would mean some kind of cheating

	var new_spell: Spell = load(spell["my_file_path"]).instantiate()
	new_spell.caster = my_owner#get_parent()
	new_spell.set_multiplayer_authority(1)
	if target_pos:
		new_spell.target_position = target_pos
	my_owner.get_parent().get_parent().add_child(new_spell)


@rpc("authority", "call_local")
func set_target_position_old(target_position: Vector2):
	target_positionnnn = target_position

@rpc("authority", "call_local")
func set_target_position(target_position):
	if not multiplayer.is_server(): # should be called from the authority
		return
	cast_this_spell_second_part(target_position)

@rpc("any_peer", "call_local")
func set_is_waiting_for_spell_target_posiiton(to: bool):
	if multiplayer.get_remote_sender_id() == 1:# or multiplayer.is_server():
		is_waiting_for_spell_target_posiiton = to

#signal spell_got_target_pos
@rpc("any_peer", "call_local") # shoulndt i tbe authority ?
func cast_the_spell(args: Array): # fisrt part
# ALERT this is the weak part, they can think up any combo
	print("authority: ", get_multiplayer_authority(), " called from: ", multiplayer.get_remote_sender_id(), " own id: ", multiplayer.get_unique_id())
	if (not multiplayer.is_server()) or (not is_waiting_for_spell):
		return
	is_waiting_for_spell = false
	var spell_dict: Dictionary = get_spell_by_spell_input(args)
	var spell_that_will_cast = spell_dict

	spell_that_is_being_cast = spell_dict

	if spell_dict != {}:
		if spell_that_will_cast["is_aimable"]:
			aim_timer.start()
			#is_waiting_for_spell_target_posiiton = true # ALERT current oopsie
			set_is_waiting_for_spell_target_posiiton.rpc_id(get_multiplayer_authority(), true)
			#set_is_waiting_for_spell_target_posiiton(true)
			#print("final target pos: ", target_positionnnn)
			return
	cast_this_spell_second_part(Vector2.ZERO)
	return

@rpc("any_peer", "call_local")
func cast_the_spell_old(args: Array): # this func has not been reviewed
	var selected_spelll = args[0]
	var target_position = args[1]
	#if not multiplayer.is_server():
		#return
	print("cast spell ", selected_spelll)
	#var a = make_spell(selected_spelll)
	#add_spell.rpc(a)2
	#var new_spell: Spell = FIREBALL.instantiate()
	#var new_spell: Spell = selected_spelll.instantiate()
	#var new_spell: Spell = load(selected_spelll.my_scene).instantiate()
	var new_spell: Spell = load(selected_spelll["my_file_path"]).instantiate()
	new_spell.caster = get_parent()
	new_spell.set_multiplayer_authority(1)
	if target_position:
		new_spell.target_position = target_position
	get_parent().get_parent().add_child(new_spell)

#func make_spell(selected_spelll):
	#return selected_spelll.duplicate()
#
#@rpc("call_local")
#func add_spell(selected_spelll):
	#get_parent().get_parent().add_child(selected_spelll)

func miscast():
	print("miscast !")
	pass


func _on_aim_timer_timeout() -> void:
	print("timeout !")
	if is_waiting_for_spell: # not needed, just for safety
		cast_this_spell_second_part(Vector2.ZERO)
