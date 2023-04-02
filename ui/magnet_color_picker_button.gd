class_name MagnetColorPickerButton
extends ColorPickerButton

# We only  need this script to make presets invisible on the actual color picker
func _ready() -> void:
	get_picker().presets_visible = false
