extends Node

var open_hand_cursor = preload("res://assets/cursor_opened-export.png")
var closed_hand_cursor = preload("res://assets/cursor_closed-export.png")
var custom_mouse = false

func _input(event):
	if Input.is_action_just_pressed("interact") and custom_mouse:
		Input.set_custom_mouse_cursor(closed_hand_cursor)
	elif Input.is_action_just_released("interact") and custom_mouse:
		Input.set_custom_mouse_cursor(open_hand_cursor)
