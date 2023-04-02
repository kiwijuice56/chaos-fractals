# Manager for all in-game magnet representations
class_name MagnetContainer
extends Node2D

@export var magnet_scene: PackedScene
@export var border: int = 32 # The space around the screen where random magnets cannot spawn

var selected_magnet: Magnet

func _input(event) -> void:
	if event.is_action_pressed("ui_right", false):
		var sim = get_node("../NBodySimulation")
		sim.InitializeMagnets()
		var data = sim.Simulate();
		get_node("%Output").visible = true
		var image: Image = Image.create_from_data(sim.width, sim.height, false, Image.FORMAT_RGBA8, data)
		var texture: ImageTexture = ImageTexture.create_from_image(image)
		get_node("%Output").texture = texture

func _ready() -> void:
	get_node("%AddMagnetButton").connect("pressed", Callable(self, "add_magnet"))
	get_node("%MagnetColorPickerButton").get_picker().connect("color_changed", Callable(self, "_on_color_updated"))
	get_node("%MassSpinBox").connect("value_changed", Callable(self, "_on_mass_updated"))
	
	clear_selection()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
		clear_selection()

func add_magnet() -> void:
	var magnet = magnet_scene.instantiate()
	add_child(magnet)
	magnet.position.x = randf_range(border, -border + ProjectSettings.get("display/window/size/viewport_width"))
	magnet.position.y = randf_range(border, -border + ProjectSettings.get("display/window/size/viewport_height"))
	
	magnet.self_modulate = Color.from_hsv(randf_range(0, 1), 1, 1)
	magnet.get_node("Field").self_modulate = magnet.self_modulate
	
	magnet.connect("selected", Callable(self, "_on_magnet_selected").bind(magnet))
	_on_magnet_selected(magnet)

# It would be cleaner for the UI to be handled by other scripts, but the scope is small enough 
# to not make it a big issue
func _on_magnet_selected(magnet: Magnet) -> void:
	if is_instance_valid(selected_magnet):
		selected_magnet.deselect()
	
	selected_magnet = magnet
	selected_magnet.select()
	get_node("%MagnetStatusContainer/NoneSelectedWarning").visible = false
	get_node("%MagnetStatusContainer/ColorContainer").visible = true
	get_node("%MagnetStatusContainer/MassContainer").visible = true
	
	get_node("%MagnetColorPickerButton").color = magnet.self_modulate
	get_node("%MassSpinBox").value = magnet.mass

func clear_selection() -> void:
	if is_instance_valid(selected_magnet):
		selected_magnet.deselect()
	get_node("%MagnetStatusContainer/NoneSelectedWarning").visible = true
	get_node("%MagnetStatusContainer/ColorContainer").visible = false
	get_node("%MagnetStatusContainer/MassContainer").visible = false

func _on_color_updated(col: Color) -> void:
	if not is_instance_valid(selected_magnet):
		return
	selected_magnet.self_modulate = col
	selected_magnet.get_node("Field").self_modulate = col

func _on_mass_updated(mass: float) -> void:
	if not is_instance_valid(selected_magnet):
		return
	selected_magnet.mass = mass
