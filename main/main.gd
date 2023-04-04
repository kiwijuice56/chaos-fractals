# Manager of the entire game and NBodySimulation
# Handles simulation parameters from UI since the simulation is an autoload and can't acess the tree easily
class_name Main
extends Node

func _ready() -> void:
	randomize()
	%RenderButton.pressed.connect(render)
	%SaveImageButton.pressed.connect(save_image)
	%ResolutionSpinBox.value_changed.connect(_on_resolution_updated)
	%IterationSpinBox.value_changed.connect(_on_iterations_updated)
	get_viewport().get_window().size_changed.connect(_on_window_resized)

func render() -> void:
	var data = NBodySimulation.Simulate();
	%Output.visible = true
	var image: Image = Image.create_from_data(NBodySimulation.width, NBodySimulation.height, false, Image.FORMAT_RGBA8, data)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	%Output.texture = texture
	%Output.scale = Vector2(1, 1) * NBodySimulation.RES

func save_image() -> void:
	if (%Output.texture != null):
		%Output.texture.image.save_png("./render%d.png" % randi_range(10000000,100000000))

func _on_window_resized() -> void:
	NBodySimulation.InitializeMagnets(%MagnetContainer)

func _on_resolution_updated(res: int) -> void:
	NBodySimulation.RES = res
	if is_instance_valid(get_viewport().gui_get_focus_owner()):
		get_viewport().gui_get_focus_owner().release_focus()

func _on_iterations_updated(iter: int) -> void:
	NBodySimulation.MAX_ITER = iter
	if is_instance_valid(get_viewport().gui_get_focus_owner()):
		get_viewport().gui_get_focus_owner().release_focus()
