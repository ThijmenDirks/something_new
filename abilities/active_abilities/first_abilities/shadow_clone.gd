extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var velocity_offset: float

var my_ability: Node2D

func move(speed, base_velocity) -> void:
	if not multiplayer.is_server():
		return
	velocity = (base_velocity.rotated(velocity_offset)).normalized() * speed
	move_and_slide()

	if velocity:
		animated_sprite_2d.play()
	else:
		animated_sprite_2d.stop()
	update_movement.rpc([global_position])

@rpc("any_peer")
func update_movement(new_position: Array) -> void:
	if multiplayer.get_remote_sender_id() == 1:
		global_position = new_position[0]

func take_damage_server_side(damage: int) -> void:
	if not multiplayer.is_server():
		return
	if damage > 0:
		die.rpc()

@rpc("any_peer", "call_local")
func die() -> void:
	if not multiplayer.get_remote_sender_id() == 1:
		return
	my_ability.all_shadow_clones.erase(self)
	queue_free()

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		animated_sprite_2d.play()
