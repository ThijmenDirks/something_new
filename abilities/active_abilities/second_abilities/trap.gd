extends Area2D

var placer: Player

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body != placer:
			body.take_damage_server_side(30, placer)
			remove_trap.rpc_id(placer.get_multiplayer_authority())
			remove_trap()

@rpc("call_local")
func remove_trap() -> void:
	get_parent().remove_child(self)
	queue_free()
