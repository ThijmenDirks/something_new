class_name Player extends CharacterBody2D

@onready var interface: Node = $Interface
@onready var speech_label: Label = $SpeechLabel
@onready var line_edit: LineEdit = $Interface/Interface/Panel/VBoxContainer/LineEdit
@onready var chat: VBoxContainer = $Interface/Interface/Panel/VBoxContainer
@onready var spell_cast_system: Node2D = $SpellCastSystem

@export var animated_sprite_2d: AnimatedSprite2D# = $AnimatedSprite2D
@onready var spell_drawer: Control = $Interface/SpellDrawer

@onready var right_hand_node: Node2D = $Items/RightHand
@onready var left_hand_node: Node2D = $Items/LeftHand
@onready var first_ability_node: Node2D = $Abilities/FirstAbility
@onready var second_ability_node: Node2D = $Abilities/SecondAbility
@onready var passive_ability_node: Node2D = $Abilities/PassiveAbility
@onready var hp_bar: TextureProgressBar = $HPBar

@export var sync_pos: Vector2 = Vector2.ZERO

var speed: int = 400
var max_hp: int = 100
@export var current_hp: int = 100

var can_cast_spells: bool = false

var uses_touchscreen: bool = false

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
	if movement_input:
		move.rpc_id(1, movement_input)
		# note that now there is not that "glide" effect

@rpc("any_peer", "call_local")
func move(input) -> void:
	if not multiplayer.is_server():
		return
	var new_values: Array = ability_handler("move", [input, speed])
	input = new_values[0]
	speed = new_values[1]
	velocity = Vector2.ZERO
	if input[0]:
		velocity.x += 1
	if input[1]:
		velocity.x -= 1
	if input[2]:
		velocity.y += 1
	if input[3]:
		velocity.y -= 1

	if velocity:
		velocity = velocity.normalized() * speed
		animated_sprite_2d.play()
	else:
		animated_sprite_2d.stop()
		#velocity = velocity.move_toward(Vector2.ZERO, 0.01)

	move_and_slide()
	#sync_pos = global_position
	var new_position: Vector2 = global_position
	update_movement.rpc([new_position])

@rpc("any_peer", "call_remote")
func update_movement(new_position: Array) -> void:
	if multiplayer.get_remote_sender_id() == 1:
		global_position = new_position[0]

func _input(event: InputEvent) -> void:
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
			if is_instance_valid(right_hand_node.get_child(0)):
				print("right hand used !")
				right_hand_node.get_child(0).get_used()
		if Input.is_action_just_pressed("use_left_item"):
			if is_instance_valid(left_hand_node.get_child(0)):
				left_hand_node.get_child(0).get_used()
		if Input.is_action_just_pressed("use_ability_1"):
			if is_instance_valid(first_ability_node.get_child(0)):
				first_ability_node.get_child(0).get_used()
		if Input.is_action_just_pressed("use_ability_2"):
			if is_instance_valid(second_ability_node.get_child(0)):
				second_ability_node.get_child(0).get_used()


func ability_handler(called_func: StringName, args: Array = []) -> Array:
	if is_instance_valid(first_ability_node.get_child(0)):
		if first_ability_node.get_child(0).has_method(called_func):
			args = first_ability_node.get_child(0).call(called_func, args)
	if is_instance_valid(second_ability_node.get_child(0)):
		if second_ability_node.get_child(0).has_method(called_func):
			args = second_ability_node.get_child(0).call(called_func, args)
	if is_instance_valid(passive_ability_node.get_child(0)):
		if passive_ability_node.get_child(0).has_method(called_func):
			args = passive_ability_node.get_child(0).call(called_func, args)
	return args

@rpc("any_peer", "call_local")
func take_damage_client_side(damage: int) -> void:
	# only to show animation and such, idk what exaclty
	if not multiplayer.get_remote_sender_id() == 1:
		return
	pass


# not a rpc, will only be called from server
func take_damage_server_side(damage: int) -> void:
	#for the actual damage
	if not multiplayer.is_server():
		return
	damage = ability_handler("take_damage_server_side", [damage])[0]
	take_damage_client_side.rpc_id(get_multiplayer_authority(), damage)
	current_hp -= damage
	update_hp.rpc(current_hp)
	if current_hp <= 0:
		die_server_side()
		die_client_side.rpc_id(get_multiplayer_authority())

@rpc("any_peer", "call_local")
func update_hp(new_hp) -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
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

func start_casting_spell(limited_spell_list: Array[Dictionary] = []):
	spell_cast_system.start_casting_spell(limited_spell_list)

func send_message(message: String):
	speech_label.text = message
	update_chat.rpc(message)

	await get_tree().create_timer(message.length() * 0.5).timeout
	speech_label.text = ""

@rpc("any_peer", "call_local")
func update_chat(message):
	for i: Node in get_parent().get_children():
		if i is CharacterBody2D:
			if i.is_multiplayer_authority():
				#pass
				var new_label = Label.new()#load("uid://c1w3kuwsult0e").instantiate()
				new_label.text = message
				i.chat.get_child(-2).add_sibling(new_label)
				new_label.position.x += 30

func _on_player_disconnected(pid) -> void:
	if pid == int(name):
		GameManager.player_info.erase(pid)
		queue_free()


@onready var ping_timer: Timer = $PingTimer
# the times wait time is 10 sec

var ping: float
var control_value: int
var received_ping: bool = true

func _process(delta: float) -> void:
	if multiplayer.is_server():
		if received_ping:
			received_ping = false
			ping_measure_sender()

func ping_measure_sender():
	control_value = randi_range(100_000, 999_999)
	ping_timer.start()
	ping_measure_at_player.rpc_id(get_multiplayer_authority(), control_value)

@rpc("any_peer", "call_local")
func ping_measure_at_player(control_value):
	if multiplayer.get_remote_sender_id() == 1:
		ping_measure_receiver.rpc_id(1, control_value)

@rpc("call_local")
func ping_measure_receiver(received_control_value):
	if not multiplayer.is_server():
		return
	if received_control_value == control_value:
		ping_timer.stop()
		ping = 10 - ping_timer.time_left
		received_ping = true


func _on_ping_timer_timeout() -> void:
	pass
	#the player must have been disconnected.
