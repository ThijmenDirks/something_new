class_name Item extends Area2D # Might gonna extend something else, in which case weapons need a lil tree overhaul

#var my_owner: Node
#@export var my_dic: Dictionary # not sure wheter this will be used. it wont
@onready var my_owner: Player# = get_parent().get_parent().get_parent()
@export var my_id: int # also used asname
@export var description: String
@export var sprite_frame: int

#var id: int = 0


#func _ready() -> void:
	#if multiplayer.is_server() and my_id == 0:
		#return
		#generate_id()

func _enter_tree() -> void:
	my_owner = get_parent().get_parent().get_parent()
	if is_instance_valid(my_owner):
		set_multiplayer_authority(my_owner.get_multiplayer_authority())

func get_picked_up() -> void:
	pass

#func generate_id() -> void:
	#var new_id: int
	#var is_valid: bool = false
	#while not is_valid:
		#new_id = randi_range(100_000, 999_999)
		#if get_parent().get_parent().name == "Level": # this is currently most likely not the case
			#if new_id not in get_parent().get_parent().all_item_ids:
				#is_valid = true
		#else: # just for debug
			#is_valid = true # just for debug
	#set_id.rpc(new_id)


@rpc("call_local")
func set_id(new_id: int) -> void:
	print("id set to: ", new_id)
	my_id = new_id
	name = str(new_id)
