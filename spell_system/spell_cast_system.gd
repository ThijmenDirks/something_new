extends Node2D
# spell_cast_system
const FIREBALL = preload("uid://dsxug0ov6dms5") #debugg

@onready var spell_drawer: Control = $"../Interface/SpellDrawer"
@onready var aim_timer: Timer = $AimTimer

@export var all_equiped_spells: Array[Dictionary]

#var spell_input: Array[int] # might get un-global
var selected_spell: Spell

var limited_spell_list: Array
var used_from_ability: int # with 0 being "not being called from ability"

var is_waiting_for_spell: bool = false # can only be true in server
var is_waiting_for_spell_target_position: bool = false

var spell_that_is_being_cast # should it be this global? i dont know... # if so, it should only be used at the server # probalby yes, it should be this global

func _ready() -> void:
	all_equiped_spells.append(SpellDatabse.fireball)


@rpc("any_peer", "call_local")
func start_casting_spell(limited_spells: Array) -> void:
	if not multiplayer.is_server():
		return
	limited_spell_list = limited_spells
	is_waiting_for_spell = true
	spell_drawer.setup.rpc_id(get_multiplayer_authority())


@rpc("any_peer", "call_local") # shoulndt it be authority ?
func cast_the_spell_first_part(spell_input: Array[int]) -> void:
# ALERT this is the weak part, they can think up any combo
	if (not multiplayer.is_server()) or (not is_waiting_for_spell):
		return
	is_waiting_for_spell = false
	spell_that_is_being_cast = get_spell_by_spell_input(spell_input)
	if spell_that_is_being_cast != {}:
		if spell_that_is_being_cast["is_aimable"]:
			aim_timer.start()
			set_is_waiting_for_spell_target_position.rpc_id(get_multiplayer_authority(), true)
			return
	cast_this_spell_second_part(Vector2.ZERO)
	return


@rpc("any_peer", "call_local")
func get_spell_by_spell_input(input: Array[int]) -> Dictionary:
	if not multiplayer.is_server():
		return {}
	var spell_that_will_cast: Dictionary = {}
	if not limited_spell_list.is_empty():
		for spell in limited_spell_list:
			if spell.input_code == input:
				spell_that_will_cast = spell
				break
	else:
		for spell: Dictionary in all_equiped_spells:
			if spell.input_code == input:
				spell_that_will_cast = spell
				break
	return spell_that_will_cast


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventScreenTouch:
			if is_waiting_for_spell_target_position:
				aim_timer.stop()
				cast_this_spell_second_part.rpc_id(1, event.position + get_parent().position - Vector2(1920, 1080)/2)


@rpc("any_peer", "call_local")
func cast_this_spell_second_part(target_position: Vector2) -> void:
	if not multiplayer.is_server():
		return
	aim_timer.stop()
	set_is_waiting_for_spell_target_position.rpc_id(get_multiplayer_authority(), false)

	if spell_that_is_being_cast == {}:
		miscast()
		return

	if used_from_ability == 1:
		get_parent().first_ability_node.get_child(0).cast_the_spell.rpc([spell_that_is_being_cast, target_position])
	elif used_from_ability == 2:
		get_parent().second_ability_node.get_child(0).cast_the_spell.rpc([spell_that_is_being_cast, target_position])
	else:
		cast_the_spell_final.rpc([spell_that_is_being_cast, target_position])


@rpc("any_peer", "call_local")
func cast_the_spell_final(args: Array) -> void:
	# and here we finally cast the spell
	if not multiplayer.get_remote_sender_id() == 1:
		return
	var spell: Dictionary = args[0]
	var target_pos : Vector2 = args[1]
	var my_owner: Node = get_parent()
	#if target_pos is too far from the player, fuck him up, because that would mean some kind of cheating

	var new_spell: Spell = load(spell["my_file_path"]).instantiate()
	new_spell.caster = my_owner
	new_spell.set_multiplayer_authority(1)
	if target_pos:
		new_spell.target_position = target_pos
	my_owner.get_parent().get_parent().add_child(new_spell)


@rpc("any_peer", "call_local")
func set_is_waiting_for_spell_target_position(to: bool) -> void:
	if multiplayer.get_remote_sender_id() == 1:# or multiplayer.is_server():
		is_waiting_for_spell_target_position = to


func miscast() -> void:
	print("miscast !")
	get_parent().position.x += 50
	pass


func _on_aim_timer_timeout() -> void:
	print("timeout !")
	if is_waiting_for_spell: # not needed, just for safety
		cast_this_spell_second_part(Vector2.ZERO)
