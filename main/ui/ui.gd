class_name UI
extends Control

var ui_hidden: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hide_ui", false):
		if ui_hidden:
			unhide_ui()
		else:
			hide_ui()
		ui_hidden = not ui_hidden

func hide_ui() -> void:
	$MarginContainer.visible = false
	$HideLabel.visible = true
	$HideLabel.modulate.a = 1
	get_tree().create_tween().tween_property($HideLabel, "modulate:a", 0, 2.0)

func unhide_ui() -> void:
	$MarginContainer.visible = true
	$HideLabel.visible = false
