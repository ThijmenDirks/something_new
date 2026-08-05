class_name projectile extends Area2D

@export var damage: int = 20
@export var speed: int = 800
@export var shooter: Node

var max_range: int = 1000
var distance_traveled: float

var direction: Vector2 = Vector2.ZERO

func _enter_tree() -> void:
	if not multiplayer.is_server():
		set_collision_layer_value(2, false)
		set_collision_mask_value(1, false)
		set_collision_mask_value(3, false)

func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	position += direction * speed * delta
	distance_traveled += speed * delta
	if distance_traveled > max_range:
		hit_draw_stuff.rpc()

func _on_body_entered(body: Node2D) -> void:
	if not multiplayer.is_server():
		return
	if body != shooter:
		hit_physics(body)
		hit_draw_stuff.rpc()


func hit_physics(target: Node):
	if multiplayer.is_server():
		if target is CharacterBody2D:
			target.take_damage_server_side(damage, shooter)

@rpc("call_local")
func hit_draw_stuff():
	queue_free()
