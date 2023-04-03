# Manager for all in-game iron representations
class_name IronContainer
extends Node2D

@export var iron_scene: PackedScene

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_RIGHT:
		var iron: Iron = iron_scene.instantiate()
		add_child(iron)
		iron.position = to_local(event.position)
