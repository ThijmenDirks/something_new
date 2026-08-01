extends Control

@onready var camera_2d: Camera2D = $SubViewport/Camera2D
@onready var abilities_node: Control = $SubViewport/AbilitiesNode

#func _process(delta: float) -> void:
	#if randi_range(0, 1) == 0:
		#camera_2d.position.x += 1
	#else:
		#camera_2d.position.x -= 1
	#camera_2d.position.x += randi_range(-10, 10)

#extends PanelContainer
# credits
# to Pieter-Jan Briers
# https://forum.godotengine.org/t/how-to-drag-windows/28718

var drag_point:Vector2 = Vector2.ZERO



func _input(event: InputEvent) -> void:
	print("input")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_point = get_global_mouse_position() - abilities_node.get_position()
			else:
				drag_point = Vector2.ZERO

	if event is InputEventMouseMotion and drag_point != Vector2.ZERO:
		abilities_node.set_position(get_global_mouse_position() - drag_point)
