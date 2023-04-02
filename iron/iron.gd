class_name Iron
extends Sprite2D

var deleted: bool = false
var velocity: Vector2
var acceleration: Vector2
var closest_magnet: int

func _ready() -> void:
	$Timer.timeout.connect(delete)

func _physics_process(_delta):
	if (NBodySimulation.StateStep(position.x, position.y, velocity.x, velocity.y, acceleration.x, acceleration.y)):
		delete()
	else:
		position = Vector2(NBodySimulation.ox, NBodySimulation.oy);
		velocity = Vector2(NBodySimulation.ovx, NBodySimulation.ovy);
		acceleration = Vector2(NBodySimulation.oax, NBodySimulation.oay);

func delete() -> void:
	if deleted:
		return
	deleted = true
	set_physics_process(false)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()
