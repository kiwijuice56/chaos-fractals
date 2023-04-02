class_name Iron
extends Sprite2D

var x = 0

#func _ready() -> void:
#	set_physics_process(false)
#
#func _input(event) -> void:
#	if event.is_action_pressed("ui_right", false):
#		get_node("../NBodySimulation").Initialize()
#		get_node("../NBodySimulation").x = position.x
#		get_node("../NBodySimulation").y = position.y
#		set_physics_process(true)
#
#func _physics_process(delta):
#	x += 1
#	if (get_node("../NBodySimulation").Step()):
#		set_physics_process(false)
#		return
#	position.x = get_node("../NBodySimulation").x
#	position.y = get_node("../NBodySimulation").y 
