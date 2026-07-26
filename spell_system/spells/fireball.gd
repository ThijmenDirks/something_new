class_name Fireball extends Spell

@onready var explosion: Area2D = $Explosion

var speed: int = 800
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	print("fireball readies")
	global_position = caster.global_position
	direction = target_position - global_position


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	position = position.move_toward(target_position, speed * delta)
	if position == target_position:
		explode()


func _on_body_entered(body: Node2D) -> void:
	if not body == caster:
		explode()


func explode():
	explode_draw_stuff.rpc()
	explode_physics()


# will only be called on server, so no rpc
func explode_physics() -> void:
	if not is_multiplayer_authority() or not multiplayer.is_server():
		return
	explosion.visible = true
	for body in explosion.get_overlapping_bodies():
		body.take_damage_server_side(30)

# these tree are for debug,to make the explosion visible
	await get_tree().physics_frame
	queue_free()

@rpc
func explode_draw_stuff(): # give it a better name
	if not multiplayer.get_remote_sender_id() == 1:
		return
	explosion.visible = true
# these tree are for debug,to make the explosion visible
	await get_tree().physics_frame
	queue_free()
