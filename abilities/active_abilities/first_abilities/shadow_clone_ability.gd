extends FirstAbility

#@onready var shadow_clone: CharacterBody2D = $ShadowClone
const SHADOW_CLONE: Resource = preload("uid://dg35hfo8ls13f")

var amount_of_clones: int = 5

@onready var cooldown_timer: Timer = $CooldownTimer

@export var all_shadow_clones: Array[Node2D]


func _enter_tree() -> void:
	super()
	all_shadow_clones = all_shadow_clones.duplicate()

func get_used() -> void:
	if cooldown_timer.time_left != 0: # gets checked again at the server_side
		return
	request_get_used.rpc_id(1)


@rpc("any_peer", "call_local")
func request_get_used() -> void:
	var requesting_peer: int = multiplayer.get_remote_sender_id()
	#if multiplayer.get_unique_id() == 1:
	if not multiplayer.is_server():
		return
	if cooldown_timer.time_left != 0:
		return

	get_used_verified.rpc_id(requesting_peer)

@rpc("call_local", "any_peer")
func get_used_verified() -> void:
	cooldown_timer.start()
	for i in range(amount_of_clones):
		spawn_new_shadow_clone.rpc()

@rpc("call_local")
func spawn_new_shadow_clone() -> void:
	var new_shadow_clone = SHADOW_CLONE.instantiate()
	new_shadow_clone.velocity_offset = randf_range(0, TAU)
	new_shadow_clone.visible = true
	new_shadow_clone.global_position = global_position
	new_shadow_clone.my_ability = self
	new_shadow_clone.set_collision_layer_value(1, true)
	new_shadow_clone.set_collision_mask_value(3, true)
	all_shadow_clones.append(new_shadow_clone)
	new_shadow_clone.set_multiplayer_authority(get_multiplayer_authority())
	get_parent().get_parent().get_parent().get_parent().add_child(new_shadow_clone, true)


@rpc("any_peer", "call_local")
func move(args: Array) -> Array:
	if not multiplayer.is_server():
		return args
	var input: Array = args[0]
	var speed: int = args[1]
	var velocity: Vector2
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
	for clone in all_shadow_clones:
		clone.move(speed, velocity)
	return args


func attack(args: Array) -> Array:
	if not multiplayer.is_server():
		return args
	return args
