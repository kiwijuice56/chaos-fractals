class_name NBodySimulation
extends Node

const dt = 16.0
const G = 1.0
const STATIONARY_LIMIT: int = 16
const ABSOLUTE_LIMIT: int = 256
const STATIONARY: float = 0.001

var resolution: int = 2

func _input(event) -> void:
	if event.is_action_pressed("ui_right", false):
		get_node("%Output").visible = true
		simulate()

func simulate() -> void:
	var pos_x: Array = []
	var pos_y: Array = []
	var mass: Array = []
	var r: Array = []
	var g: Array = []
	var b: Array = []
	
	var out: PoolByteArray = []
	
	var width: int
	var height: int
	
	for child in get_node("%MagnetContainer").get_children():
		pos_x.append(child.position.x)
		pos_y.append(child.position.y)
		mass.append(child.mass)
		r.append(child.self_modulate.r8)
		g.append(child.self_modulate.g8)
		b.append(child.self_modulate.b8)
	
	for init_y in range(0, ProjectSettings.get("display/window/size/height"), resolution):
		height += 1
		for init_x in range(0, ProjectSettings.get("display/window/size/width"), resolution):
			if height == 1:
				width += 1
			var last_x: float = init_x
			var last_y: float = init_y 
			var x: float = init_x
			var y: float = init_y
			var v_x: float = 0
			var v_y: float = 0
			var a_x: float = 0
			var a_y: float = 0
			
			var c_x: float = 10000
			var c_y: float = 10000
			var c_i: int = 0
			
			var stationary: int = 0
			for iter in range(ABSOLUTE_LIMIT):
				v_x += a_x * dt / 2
				v_y += a_y * dt / 2
				
				x += v_x * dt
				y += v_y * dt
				
				for m_i in range(len(pos_x)):
					if (((c_x - x) * (c_x - x) + (c_y - y) * (c_y - y)) > (pos_x[m_i] - x) * (pos_x[m_i] - x) + (pos_y[m_i] - y) * (pos_y[m_i] - y)):
						c_x = pos_x[m_i]
						c_y = pos_y[m_i]
						c_i = m_i
					
					var dx: float = pos_x[m_i] - x
					var dy: float = pos_y[m_i] - y
					var inv_r3: float = pow(dx * dx + dy * dy, -1.5)
					a_x += G * (dx * inv_r3) * mass[m_i]
					a_y += G * (dy * inv_r3) * mass[m_i]
				
				if ((last_x - x) * (last_x - x) + (last_y - y) * (last_y - y) < STATIONARY):
					stationary += 1
					if stationary > STATIONARY_LIMIT:
						break
					else:
						stationary = 0
				last_x = x
				last_y = y
				
				v_x += a_x * dt / 2
				v_y += a_y * dt / 2
			out.append(r[c_i])
			out.append(g[c_i])
			out.append(b[c_i])
			out.append(255)
	var texture: ImageTexture = ImageTexture.new()
	var image: Image = Image.new()
	image.create_from_data(width, height, false, Image.FORMAT_RGBA8, out)
	texture.create_from_image(image)
	get_node("%Output").texture = texture

