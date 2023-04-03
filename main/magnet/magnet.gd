# In-game representation of a magnet with a position, mass, and color
class_name Magnet
extends Sprite2D

signal selected

var mass: float = 2.0: set = set_mass
var dragging: bool = false
var grab_offset: Vector2 
var field_shader: ShaderMaterial

func set_mass(new_mass: float):
	mass = new_mass
	$Field.material.set_shader_parameter("rev", mass < 0)
	$Field.material.set_shader_parameter("range", min(0.5, 0.02 + abs(mass / 256.0)))

func _ready() -> void:
	# Each magnet can have different wave parameters, so we must create a duplicate material
	$Field.material = $Field.material.duplicate()
	self.mass = 8

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and dragging:
		# The position in the simulation must be updated
		NBodySimulation.InitializeMagnets(get_parent())
		position = event.position + grab_offset
	
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
		if get_rect().has_point(to_local(event.position)):
			# We keep an offset to prevent the magnet from appearing to teleport to the mouse
			grab_offset = position - event.position 
			dragging = true
			emit_signal("selected")
			select()
			get_viewport().set_input_as_handled()
	
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = false

func select() -> void:
	$SelectedOutline.visible = true

func deselect() -> void:
	$SelectedOutline.visible = false
