extends Control
# spell_drawer
const ICON = preload("uid://duvc1h3v4qe0f")

#region
@onready var icon: Sprite2D = $Icon
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var timer: Timer = $Timer
@onready var finger_area: Area2D = $FingerArea

@export var control: Control

var spell_input: Array[int] = []

var is_first_release: bool = true#
var is_touching: bool = false
var last_collider: Area2D

#signal spell_is_finished

func _enter_tree() -> void:
	spell_input = spell_input.duplicate()

func _ready() -> void:
	spell_input = spell_input.duplicate()
	if size.x < size.y:
		size.y = size.x
		offset_bottom /= 2
		offset_top = -offset_bottom
	elif size.y < size.x:
		size.x = size.y
		offset_right /= 2
		offset_left = -offset_right

@rpc("any_peer", "call_local")
func setup():
	print("test 8")
	spell_input.clear()
	visible = true
	finger_area.position = Vector2.ZERO
	timer.start()
	#is_first_release = true
	cpu_particles_2d.position = Vector2.ZERO

func _input(event: InputEvent) -> void:
	#if not visible:
		#return
	if is_touching:
		print("is touching")
		if event is InputEventScreenDrag:
			var drag_position: Vector2 = event.position - position
			cpu_particles_2d.position = drag_position
			finger_area.position = drag_position
			for collider: Area2D in finger_area.get_overlapping_areas():
				if collider == last_collider:
					break
				if collider.get_parent().get_parent().get_parent().get_parent() == self:
					last_collider = collider
					spell_input.append(int(collider.name))

func _process(_delta: float) -> void:
	if not visible:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print("is pressing")
		is_touching = true
	else:
		print("is not touching")
		if is_touching:
			if is_first_release:#
				cpu_particles_2d.restart()
				is_first_release = false#
			else:#
				print("cast spell from let loose")
				cast_spell()
				is_first_release = true#
		is_touching = false

func cast_spell() -> void:
	print("cast the spell ! ", spell_input)
	timer.stop()
	visible = false
	#spell_is_finished.emit()
	#spell_input.clear()
	get_parent().get_parent().spell_cast_system.cast_the_spell_first_part.rpc_id(1, spell_input)
	return

#func let_loose_touch() -> void:
	#is_touching = false
	#cast_spell()


func _on_timer_timeout() -> void:
	print("cast spell from timer")
	cast_spell()
