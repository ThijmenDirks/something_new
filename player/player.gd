class_name Player extends CharacterBody2D

@export_category("stats")
@export var strength: int = 10 # only for reference, handled by stats_menu
@export var dexterity: int = 10 # only for reference, handled by stats_menu
@export var intelligence: int = 10 # only for reference, handled by stats_menu
@export var speed: int = 400
@export var max_hp: int = 100
@export var current_hp: int = 100
@export var race: bool
@export var level: int = 1
@export var xp: int = 0
@export var pending_stat_boosts: int = 0
@export var pending_levels: int = 0
@export_category("")

@onready var interface: Node = $Interface
@onready var speech_label: Label = $SpeechLabel
@onready var line_edit: LineEdit = $Interface/Interface/Panel/ChatLabelContainer/LineEdit
@onready var chat: VBoxContainer = $Interface/Interface/Panel/ChatLabelContainer
@onready var spell_cast_system: Node2D = $SpellCastSystem
@onready var player_id_label: Label = $"Player ID"

@export var animation_player: AnimationPlayer# = $SpriteHandler/AnimationPlayer

@export var animated_sprite_2d: AnimatedSprite2D# = $AnimatedSprite2D
@onready var spell_drawer: Control = $Interface/SpellDrawer

@onready var stats_menu: Control = $Interface/StatsMenu
@onready var right_hand_node: Node2D = $Items/RightHand
@onready var left_hand_node: Node2D = $Items/LeftHand
@onready var first_ability_node: Control = $Interface/StatsMenu/MarginContainer/HBoxContainer/Classtuff/SelectedClasses/HBoxContainer/FirstAbility#$Abilities/FirstAbility
@onready var second_ability_node: Control = $Interface/StatsMenu/MarginContainer/HBoxContainer/Classtuff/SelectedClasses/HBoxContainer/SecondAbility
@onready var passive_ability_node: Control = $Interface/StatsMenu/MarginContainer/HBoxContainer/Classtuff/SelectedClasses/HBoxContainer/PassiveAbility
@onready var hp_bar: TextureProgressBar = $HPBar

@export var sync_pos: Vector2 = Vector2.ZERO

@onready var ability_areas: Node2D = $AbilityAreas

var can_cast_spells: bool = false

var can_cast_arcane_spells: int = 3
var can_cast_divine_spells: int = 3

var uses_touchscreen: bool = false

const xp_per_level: int = 100

func _enter_tree() -> void:
	# Doing this here instead of on ready prevents bugs
	$Camera2D.enabled = is_multiplayer_authority()
	$"Player ID".text = name

func _ready() -> void:
	sync_pos = global_position

	$"Player ID".text = name
	GameManager.player_info[int(name)] = {"spawnpoint":sync_pos, "node":self}
	NetworkManager.player_disconnected.connect(_on_player_disconnected)

	interface.visible = is_multiplayer_authority()


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		# Making it 30fps (save bandwidth) and lerping with local fps to hide the stutter
		#position = lerp(position, sync_pos, 0.5)
		return

	var movement_input: Array = [Input.is_action_pressed("right_1"), Input.is_action_pressed("left_1"), Input.is_action_pressed("down_1"), Input.is_action_pressed("up_1")]
	movement_input = [Input.get_axis("left_1", "right_1"), Input.get_axis("up_1", "down_1")]
	if movement_input:
		move_client_side(movement_input)
		move_server_side.rpc_id(1, movement_input)
		# note that now there is not that "glide" effect

func move_client_side(movement_input):
	if not is_multiplayer_authority() or multiplayer.is_server():
		return
	#var new_values: Array = ability_handler("move", [input, speed])
	#input = new_values[0]
	#speed = new_values[1]
	velocity = Vector2.ZERO


	velocity.x = movement_input[0]
	velocity.y = movement_input[1]
	if velocity:
		velocity = velocity.normalized() * speed
	#update_animation(velocity)
		#animated_sprite_2d.play()
	#else:
		#animated_sprite_2d.stop()
		#velocity = velocity.move_toward(Vector2.ZERO, 0.01)

	move_and_slide()
	#sync_pos = global_position


@rpc("any_peer", "call_local", "unreliable")
func move_server_side(input) -> void:
	if not multiplayer.is_server():
		return
	var new_values: Array = ability_handler("move", [input, speed])
	input = new_values[0]
	speed = new_values[1]
	velocity = Vector2.ZERO
	#if input[0]:
		#velocity.x += 1
	#if input[1]:
		#velocity.x -= 1
	#if input[2]:
		#velocity.y += 1
	#if input[3]:
		#velocity.y -= 1

	velocity.x = input[0]
	velocity.y = input[1]
	if velocity:
		velocity = velocity.normalized() * speed
	#update_animation(velocity)
		#animated_sprite_2d.play()
	#else:
		#animated_sprite_2d.stop()
		#velocity = velocity.move_toward(Vector2.ZERO, 0.01)

	move_and_slide()
	#sync_pos = global_position
	#var new_position: Vector2 = global_position
	update_movement.rpc([global_position, velocity])

@rpc("any_peer", "call_remote", "unreliable")
func update_movement(args: Array) -> void:
	if multiplayer.get_remote_sender_id() == 1:
		global_position = args[0]
		velocity = args[1]

func _input(event: InputEvent) -> void:
	# make something that makes the player not move when typing one of [w,a,s,d]
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("enter_chat") and not line_edit.has_focus():
			line_edit.visible = true
			line_edit.grab_focus()
			await get_tree().process_frame
			line_edit.text = ""
		if Input.is_action_just_pressed("ui_accept"):
			send_message(line_edit.text)
			line_edit.text = ""
			line_edit.visible = false

		if Input.is_action_just_pressed("use_right_item"):
			use_right_hand()
		if Input.is_action_just_pressed("use_left_item"):
			use_left_hand()
		if Input.is_action_just_pressed("use_ability_1"):
			use_first_ability()
		if Input.is_action_just_pressed("use_ability_2"):
			use_second_ability()

func use_right_hand():
	if is_instance_valid(right_hand_node.get_child(0)):
		right_hand_node.get_child(0).get_used()

func use_left_hand():
	if is_instance_valid(left_hand_node.get_child(0)):
		left_hand_node.get_child(0).get_used()

func use_first_ability():
	if is_instance_valid(first_ability_node.get_child(0)):
		first_ability_node.get_child(0).get_used()

func use_second_ability():
	if is_instance_valid(second_ability_node.get_child(0)):
		second_ability_node.get_child(0).get_used()

func ability_handler(called_func: StringName, args: Array = []) -> Array:
	if first_ability_node.get_child_count() != 0:
		if first_ability_node.get_child(0).has_method(called_func):
			args = first_ability_node.get_child(0).call(called_func, args)
	if second_ability_node.get_child_count() != 0:
		if second_ability_node.get_child(0).has_method(called_func):
			args = second_ability_node.get_child(0).call(called_func, args)
	if passive_ability_node.get_child_count() != 0:
		if passive_ability_node.get_child(0).has_method(called_func):
			args = passive_ability_node.get_child(0).call(called_func, args)
	return args


@rpc("any_peer", "call_local")
func update_stat(stat: int, amount: int) -> void:
	if not multiplayer.get_remote_sender_id() -- 1:
		return
	if stat == 0:
		strength += amount
		if strength <= 0:
			die_server_side()
	if stat == 1:
		dexterity += amount
		if dexterity <= 0:
			die_server_side()
	if stat == 2:
		intelligence += amount
		if intelligence <= 0:
			die_server_side()
	#stats_menu.update_stat(stat, amount)

# not a rpc, will only be called from server
func take_damage_server_side(damage: int, from: Player) -> void:
	#for the actual damage
	if not multiplayer.is_server():
		return
	damage = ability_handler("take_damage_server_side", [damage, from])[0]
	take_damage_client_side.rpc_id(get_multiplayer_authority(), damage)
	current_hp -= damage
	update_hp.rpc(current_hp)
	from.has_done_damage(damage, self)
	if current_hp <= 0:
		die_server_side()
		die_client_side.rpc_id(get_multiplayer_authority())

@rpc("any_peer", "call_local")
func take_damage_client_side(damage: int) -> void:
	# only to show animation and such, idk what exaclty
	if not multiplayer.get_remote_sender_id() == 1:
		return
	pass

func has_done_damage(damage: int, to: Player) -> void:
	ability_handler("has_done_damage", [damage, to])

func take_healing_server_side(healing: int, from: Player) -> void:
	#for the actual healing
	if not multiplayer.is_server():
		return
	#if not is_multiplayer_authority():
		#print("serer takes healing: ", healing)
	healing = ability_handler("take_healing_server_side", [healing])[0]
	take_healing_client_side.rpc_id(get_multiplayer_authority(), healing)
	current_hp += healing
	from.has_done_healing(healing, self)
	if current_hp > max_hp:
		current_hp = max_hp
	update_hp.rpc(current_hp)

@rpc("any_peer", "call_local")
func take_healing_client_side(healing: int) -> void:
	# only to show animation and such, idk what exaclty
	if not multiplayer.get_remote_sender_id() == 1:
		return
	pass


func has_done_healing(healing: int, to: Player) -> void:
	pass

@rpc("any_peer", "call_local")
func update_hp(new_hp: int, new_max_hp: int = -1) -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	if new_max_hp == 0:
		max_hp = 1
	elif new_max_hp != -1:
		max_hp = new_max_hp
	current_hp = new_hp
	hp_bar.value = current_hp

func die_server_side() -> void:
	if not multiplayer.is_server():
		return
	pass

@rpc("any_peer", "call_local")
func die_client_side() -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	pass

func start_casting_spell(limited_spell_list: Array[Dictionary] = []) -> void:
	spell_cast_system.start_casting_spell.rpc_id(1, limited_spell_list)

func add_spell(new_spell: Dictionary) -> void:
	spell_cast_system.equiped.append(new_spell)

func send_message(message: String):
	ability_handler("send_message", [message]) # used by: shadow clone
	speech_label.text = message # the text is being managed by a MultiplayerSynchronizer
	for player: Node in get_parent().get_children():
		if player is Player and not player == self:
			player.update_chat.rpc_id(player.get_multiplayer_authority(), message)
	update_chat.rpc(message)

	await get_tree().create_timer(message.length() * 0.5).timeout
	speech_label.text = ""

@rpc("any_peer", "call_local")
func update_chat(message: String):
	for player: Node in get_parent().get_children():
		if player is Player:
			if player.is_multiplayer_authority():
				#pass
				var new_label = Label.new()#load("uid://c1w3kuwsult0e").instantiate()
				new_label.text = message
				#if is_instance_valid(player.get_node("Interface/Interface/Panel/VBoxContainer")):
				if is_instance_valid(player.interface) or true:
					print("test: ", message, " interface: ", player.interface)
					player.interface.chat_label_container.get_child(-2).add_sibling(new_label)
					#new_label.position.x += 30

func _on_player_disconnected(pid) -> void:
	if pid == int(name):
		GameManager.player_info.erase(pid)
		queue_free()

@onready var level_timer: Timer = $LevelTimer # shouldt stay this way

# called from server, to authority and server
@rpc("any_peer", "call_local")
func gain_xp(new_xp: int) -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	print("called at id: ", multiplayer.get_unique_id())
	xp += new_xp
	if xp > xp_per_level and multiplayer.is_server():
		gain_level()
		gain_level.rpc_id(get_multiplayer_authority())

@rpc("any_peer", "call_local")
func gain_level() -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	pending_levels += 1

@rpc("any_peer", "call_local")
func level_up():
	pending_levels -= 1
	pass



#@onready var pickup_area: Area2D = $PickupArea
#
#func _on_pickup_area_area_entered(_area: Area2D) -> void:
	#interface.show_pickup_item_button()
#
#func _on_pickup_area_area_exited(_area: Area2D) -> void:
	#if pickup_area.get_overlapping_areas().is_empty():
		#interface.hide_pickup_item_button()


@onready var ping_timer: Timer = $PingTimer
# the timers wait time is 10 sec

var ping: float
var control_value: int
var received_ping: bool = true
var ping_send_time: int
#var ping_receive_time: int

func _process(delta: float) -> void:
	if multiplayer.is_server():
		if received_ping:
			received_ping = false
			ping_measure_sender()

func ping_measure_sender():
	if not multiplayer.is_server():
		return
	control_value = randi_range(100_000, 999_999)
	ping_send_time = Time.get_ticks_usec()
	ping_measure_at_player.rpc_id(get_multiplayer_authority(), control_value)
	#ping_measure_at_player.rpc(control_value)

@rpc("any_peer", "call_local")
func ping_measure_at_player(received_control_value: int):
	if multiplayer.get_remote_sender_id() == 1 and is_multiplayer_authority():
		ping_measure_receiver.rpc_id(1, received_control_value)

@rpc("authority", "call_local")
func ping_measure_receiver(received_control_value: int):
	if not multiplayer.is_server():
		return
	if received_control_value == control_value:
		ping = Time.get_ticks_usec() - ping_send_time
		var ping_msec = ping/1000
		received_ping = true
		update_ping_label.rpc_id(get_multiplayer_authority(), ping_msec)

@rpc("any_peer", "call_local")
func update_ping_label(new_ping: int):
	if not multiplayer.get_remote_sender_id() == 1 or not is_multiplayer_authority():
		return
	ping = new_ping
	interface.ping_label.text = str("ping: ", ping, " ms")


func _on_ping_timer_timeout() -> void:
	pass
	#the player must have been disconnected.
