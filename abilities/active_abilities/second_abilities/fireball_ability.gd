extends SecondAbility

@onready var cooldown_timer: Timer = $CooldownTimer


func get_used() -> void:
	print("test 1")
	request_get_used.rpc_id(1)
	print("test 1.5")
	#my_owner.start_casting_spell([SpellDatabse.fireball])


@rpc("any_peer", "call_local")
func request_get_used() -> void:
	print("test 2")
	# checks wheter ability can be used
	if not multiplayer.is_server():
		return
	if cooldown_timer.time_left != 0:
		return
	print("test 3")
	cooldown_timer.start()
	get_used_verified.rpc_id(multiplayer.get_remote_sender_id())
	my_owner.spell_cast_system.current_accessable_spells = [SpellDatabse.fireball]
	my_owner.spell_cast_system.used_from_ability = 2

	#my_owner.spell_cast_system.start_casting_spell.rpc_id(multiplayer.get_remote_sender_id())
	print("test 5")
	my_owner.spell_cast_system.start_casting_spell.rpc_id(1, [SpellDatabse.fireball])

@rpc("any_peer", "call_local")
func get_used_verified() -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	cooldown_timer.start()
	print("test 4")


@rpc("any_peer", "call_local")
func cast_the_spell(args: Array) -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	var spell = args[0]
	var target_pos = args[1]
	#if target_pos is too far from the player, fuck him up, because that would mean some kind of cheating

	var new_spell: Spell = load(spell["my_file_path"]).instantiate()
	new_spell.caster = my_owner#get_parent()
	new_spell.set_multiplayer_authority(1)
	if target_pos:
		new_spell.target_position = target_pos
	my_owner.get_parent().get_parent().add_child(new_spell)
