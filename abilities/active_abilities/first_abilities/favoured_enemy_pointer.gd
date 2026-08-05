extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var target: Player

func _enter_tree() -> void:
	visible = get_parent().get_parent().is_multiplayer_authority()

func _physics_process(delta: float) -> void:
	print("test 1")
	if not multiplayer.is_server():
		return
	print("test 2")
	var vector_to_target: Vector2 = target.global_position - global_position
	if not target in get_overlapping_bodies():
		sprite_2d.position = vector_to_target.normalized() * 800
		sprite_2d.rotation = vector_to_target.angle() + PI/4
		print("test 3.1, ", sprite_2d.position, " ", sprite_2d.rotation)
	else:
		sprite_2d.position = vector_to_target + Vector2(0, -200)
		sprite_2d.rotation = 3*PI/4
		print("test 3.2, ", sprite_2d.position, " ", sprite_2d.rotation)
	#sprite_2d.position.x = randi_range(300, -300)
	print("test 4")
	update_transform.rpc_id(get_parent().get_parent().get_multiplayer_authority(), sprite_2d.position, sprite_2d.rotation)
	#update_transform.rpc(sprite_2d.position, sprite_2d.rotation)

# should be "authority"
@rpc("any_peer", "call_local")
func update_transform(new_position: Vector2, new_rotation: float) -> void:
	print("test 5")
	if not multiplayer.get_remote_sender_id():
		pass # ALERT should be return
	print("test 6")
	sprite_2d.position = new_position
	sprite_2d.rotation = new_rotation
