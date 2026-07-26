extends Node
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _przocess(delta: float) -> void:
	#pass
#
#
## damage should not be a parameter, but shold instead be calculated by server
#@rpc("any_peer", "call_local")
##func request_attack(target: int, damage: int):
#func request_melee_attack(target: int, damage: int):
	#print("reques attack called")
	#if not multiplayer.is_server():
		##return
		#print(get_multiplayer_authority(), " is not server")
	#else:
		#print(get_multiplayer_authority(), " is server")
	#print("is multiplayer server !")
	##target.take_damage.rpc_id(target.get_multiplayer_authority(), damage)
	##target.take_damage(damage)
	#print("target: ", GameManager.player_info[target].node)
	#GameManager.player_info[target].node.take_damage.rpc_id(target, damage)
	##GameManager.player_info[target].node.take_damage(damage)
#
#@rpc("any_peer", "call_local")
#func request_make_player_take_damage(target: int, damage: int):
	#print("this func got called")
	#GameManager.player_info[target].node.take_damage_server_side.rpc_id(target, damage)
#
##
##@rpc("any_peer", "call_local")
##func cast_the_spell(selected_spelll):
	##print("cast spell ", selected_spelll)
	###var a = make_spell(selected_spelll)
	###add_spell.rpc(a)2
	###var new_spell: Spell = FIREBALL.instantiate()
	###var new_spell: Spell = selected_spelll.instantiate()
	##var new_spell: Spell = load(selected_spelll).instantiate()
	##new_spell.caster = get_parent()
	##if target_positionnnn:
		##new_spell.target_position = target_positionnnn
	##print("test ", new_spell.target_position)
	##new_spell.set_multiplayer_authority(1)
	##get_parent().get_parent().add_child(new_spell)
