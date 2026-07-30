extends Node2D

@onready var player: Player = get_parent()
@export var animation_player: AnimationPlayer

var current_animation: StringName
var last_animation: StringName

func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	get_animation_from_velocity(get_parent().velocity)

func get_animation_from_velocity(velocity: Vector2):
	if velocity == Vector2.ZERO:
		if last_animation == "walk_up" and current_animation != "idle_up":
			current_animation = "idle_up"
			update_animation.rpc("idle_up")
		if last_animation == "walk_right" and current_animation != "idle_right":
			current_animation = "idle_right"
			update_animation.rpc("idle_right")
		if last_animation == "walk_down" and current_animation != "idle_down":
			current_animation = "idle_down"
			update_animation.rpc("idle_down")
		if last_animation == "walk_left" and current_animation != "idle_left":
			current_animation = "idle_left"
			update_animation.rpc("idle_left")
	elif abs(velocity.x) >= abs(velocity.y):
		if velocity.x > 1:
			if current_animation != "walk_right":
				current_animation = "walk_right"
				update_animation.rpc("walk_right")
		else:
			if current_animation != "walk_left":
				current_animation = "walk_left"
				update_animation.rpc("walk_left")
	else:
		if velocity.y > 1:
			if current_animation != "walk_down":
				current_animation = "walk_down"
				update_animation.rpc("walk_down")
		else:
			if current_animation != "walk_up":
				current_animation = "walk_up"
				update_animation.rpc("walk_up")

@rpc("any_peer", "call_local", "unreliable")
func update_animation(new_animation: StringName):
	#if not multiplayer.get_remote_sender_id() == get_multiplayer_authority():
		#return
	last_animation = current_animation
	animation_player.play(new_animation)
