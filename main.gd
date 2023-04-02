# Manager of the entire game and NBodySimulation
# Handles simulation parameters from UI since the simulation is an autoload and can't acess the tree easily
class_name Main
extends Node

func _ready() -> void:
	randomize()
	%RenderButton.pressed.connect(render)
	%ResolutionSpinBox.value_changed.connect(_on_resolution_updated)
	%IterationSpinBox.value_changed.connect(_on_iterations_updated)
	get_viewport().get_window().size_changed.connect(_on_window_resized)

func render() -> void:
	var data = NBodySimulation.Simulate();
	%Output.visible = true
	var image: Image = Image.create_from_data(NBodySimulation.width, NBodySimulation.height, false, Image.FORMAT_RGBA8, data)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	%Output.texture = texture

func _on_window_resized() -> void:
	NBodySimulation.InitializeMagnets(%MagnetContainer)

func _on_resolution_updated(res: int) -> void:
	NBodySimulation.RES = res

func _on_iterations_updated(iter: int) -> void:
	NBodySimulation.MAX_ITER = iter;
