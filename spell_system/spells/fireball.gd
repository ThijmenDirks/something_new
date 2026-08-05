class_name Fireball extends Spell

@onready var explosion: Area2D = $Explosion

var speed: int = 800
#var direction: Vector2 = Vector2.ZERO

var has_exploded:bool = false

func _ready() -> void:
	print("fireball readies")
	global_position = caster.global_position
	#direction = target_position - global_position


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if global_position == target_position:
		explode()
	position = position.move_toward(target_position, speed * delta)
	if not has_exploded:
		update_position.rpc(position)

@rpc("call_local")
func update_position(new_position: Vector2) -> void:
	global_position = new_position


func _on_body_entered(body: Node2D) -> void:
	if not is_multiplayer_authority():
		return
	if not body == caster:
		explode()


func explode() -> void:
	explode_draw_stuff.rpc()
	explode_physics()
	has_exploded = true


# will only be called on server, so no rpc
func explode_physics() -> void:
	if not is_multiplayer_authority() or not multiplayer.is_server() or has_exploded:
		return
	var base_damage = 30 + caster.intelligence
	var damage = base_damage
	explosion.visible = true
	for body in explosion.get_overlapping_bodies():
		body.take_damage_server_side(damage, caster)

# these tree are for debug,to make the explosion visible
	#await get_tree().physics_frame
	#await get_tree().physics_frame
	#await get_tree().physics_frame
	queue_free.call_deferred()

@rpc("any_peer")
func explode_draw_stuff() -> void: # give it a better name
	if not multiplayer.get_remote_sender_id() == 1:# or if multiplayer.is_server(): the server doesnt have to draw it
		return
	explosion.visible = true
# these tree are for debug,to make the explosion visible
	#await get_tree().physics_frame
	#await get_tree().physics_frame
	#await get_tree().physics_frame
	queue_free()
