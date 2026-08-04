extends Control

@onready var camera_2d: Camera2D = $SubViewport/Camera2D
@onready var abilities_node: Control = $SubViewport/AbilitiesNode

# credits
# to Pieter-Jan Briers
# https://forum.godotengine.org/t/how-to-drag-windows/28718

var drag_point:Vector2 = Vector2.ZERO



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_point = get_global_mouse_position() - abilities_node.get_position()
			else:
				drag_point = Vector2.ZERO

	if event is InputEventMouseMotion and drag_point != Vector2.ZERO:
		abilities_node.set_position(get_global_mouse_position() - drag_point)
