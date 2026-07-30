class_name Weapon extends HandItem

@onready var timer: Timer = $Timer

@export var max_damage: int
@export var attack_cooldown_time: float

@export var rotation_speed: float = 5 # in rad

#@onready var my_owner: Player = get_parent().get_parent().get_parent()


func _enter_tree() -> void:
	super()
	set_multiplayer_authority(1)
	timer = get_node("Timer")
	if is_instance_valid(timer):
		pass
		#timer.wait_time = .1#attack_cooldown_time
	else:
		assert(false)
	#my_owner = get_parent().get_parent().get_parent()
	visible = my_owner.is_multiplayer_authority()
	rotation = randf_range(0, TAU)
	if is_instance_valid(get_parent()):
		if get_parent().name == "RightHand":
			print("is in right hand !")
		elif get_parent().name == "LeftHand":
			print("is in left hand !")
			rotation_speed *= -1
		else:
			print("hand is called: ", get_parent().name)

func _process(delta: float) -> void:
	#super()
	rotation = wrapf(rotation + rotation_speed * delta, 0, TAU)
