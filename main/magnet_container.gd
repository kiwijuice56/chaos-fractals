# Manager for all in-game magnet representations
class_name MagnetContainer
extends Node2D

@export var magnet_scene: PackedScene

var selected_magnet: Magnet

func _ready() -> void:
	NBodySimulation.InitializeMagnets(self)
	%MagnetColorPickerButton.get_picker().color_changed.connect(_on_color_updated)
	%MassSpinBox.value_changed.connect(_on_mass_updated)
	%MagnetDeleteButton.pressed.connect(delete_selected_magnet)
	
	clear_selection()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
		add_magnet(event.position)
	if event.is_action_pressed("delete_magnet", false):
		delete_selected_magnet()
	

func add_magnet(magnet_position: Vector2) -> void:
	var magnet = magnet_scene.instantiate()
	add_child(magnet)
	magnet.position = magnet_position
	
	magnet.self_modulate = Color.from_hsv(randf_range(0, 1), 0.9, 0.9)
	magnet.get_node("Field").self_modulate = magnet.self_modulate
	
	magnet.selected.connect(_on_magnet_selected.bind(magnet))
	_on_magnet_selected(magnet)
	
	NBodySimulation.InitializeMagnets(self)

func delete_selected_magnet() -> void:
	if not is_instance_valid(selected_magnet):
		return
	remove_child(selected_magnet)
	selected_magnet.queue_free()
	NBodySimulation.InitializeMagnets(self)
	clear_selection()

# It would be cleaner for the UI to be handled by other scripts, but the scope is small enough 
# to not make it a big issue
func _on_magnet_selected(magnet: Magnet) -> void:
	if is_instance_valid(selected_magnet):
		selected_magnet.deselect()
	
	selected_magnet = magnet
	selected_magnet.select()
	%MagnetStatusContainer.get_parent().visible = true
	%MagnetColorPickerButton.color = magnet.self_modulate
	%MassSpinBox.value = magnet.mass

func clear_selection() -> void:
	if is_instance_valid(selected_magnet):
		selected_magnet.deselect()
	%MagnetStatusContainer.get_parent().visible = false

func _on_color_updated(col: Color) -> void:
	if not is_instance_valid(selected_magnet):
		return
	selected_magnet.self_modulate = col
	selected_magnet.get_node("Field").self_modulate = col
	NBodySimulation.InitializeMagnets(self)

func _on_mass_updated(mass: float) -> void:
	if not is_instance_valid(selected_magnet):
		return
	selected_magnet.mass = mass
	NBodySimulation.InitializeMagnets(self)
	if is_instance_valid(get_viewport().gui_get_focus_owner()):
		get_viewport().gui_get_focus_owner().release_focus()
