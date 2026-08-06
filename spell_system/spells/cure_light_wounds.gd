extends Spell

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	draw_self()
	if not is_multiplayer_authority():
		return
	await get_tree().physics_frame
	await get_tree().physics_frame
	var target: CharacterBody2D = area_2d.get_overlapping_bodies()[1]
	if target is Player:
		target.take_healing_server_side(20 + caster.intelligence)
	

@rpc("call_local")
func draw_self() -> void:
	pass
