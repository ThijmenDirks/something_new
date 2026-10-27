extends CharacterBody2D

@export var player_id_label: Label# = $"Player ID"
#@export var animated_sprite_2d: AnimatedSprite2D# = $AnimatedSprite2D
@export var hp_bar: TextureProgressBar# = $HPBar
@export var speech_label: Label# = $SpeechLabel

var velocity_offset: float

var my_ability: Node2D

func move(speed, base_velocity) -> void:
	if not multiplayer.is_server():
		return
	velocity = (base_velocity.rotated(velocity_offset)).normalized() * speed
	move_and_slide()

	#if velocity:
		#animated_sprite_2d.play()
	#else:
		#animated_sprite_2d.stop()
	#update_movement.rpc([global_position])
	update_movement.rpc([global_position, velocity])

@rpc("any_peer", "unreliable")
func update_movement(args: Array) -> void:
	if multiplayer.get_remote_sender_id() == 1:
		#global_position = new_position[0]
		global_position = args[0]
		velocity = args[1]

func take_damage_server_side(damage: int, from: Player) -> void:
	if not multiplayer.is_server():
		return
	if damage > 0:
		die.rpc()

@rpc("authority", "call_local")
func die() -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	my_ability.all_shadow_clones.erase(self)
	queue_free()

#func _process(_delta: float) -> void:
	##if is_multiplayer_authority():
	#animated_sprite_2d.play()

@rpc("call_local")
func update_hp_bar(damage: int):
	hp_bar.value -= damage

func send_message(message: String):
	update_chat_label.rpc(message)
	await get_tree().create_timer(message.length() * 0.5).timeout
	speech_label.text = ""
	update_chat_label.rpc("")

@rpc("call_local")
func update_chat_label(message: String):
	speech_label.text = message
