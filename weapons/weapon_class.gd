class_name Weapon extends Area2D

@onready var timer: Timer = $Timer

@export var max_damage: int
@export var attack_cooldown_time: float

@onready var my_owner: Player = get_parent().get_parent().get_parent()


func _enter_tree() -> void:
	timer.wait_time = .1#attack_cooldown_time
	#my_owner = get_parent().get_parent().get_parent()
