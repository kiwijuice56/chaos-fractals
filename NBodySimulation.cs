using Godot;
using System;

public partial class NBodySimulation : Node {
	// State variables for all magnets
	float[] px, py, mass;
	byte[] r, g, b;

	// Output of the simulation
	float ox, oy, oax, oay, ovx, ovy;
	int oClosestMagnet;

	// Simulation parameters
	float G = 1.0f, DT = 32.0f, STOP_DIST_SQ = 96.0f;
	int RES = 4, MAX_ITER = 256;
	int width, height, fullWidth, fullHeight, magnetCnt;

	public void InitializeMagnets(Node magnetContainer) {
		fullWidth = (int) GetViewport().GetWindow().Size.X;
		fullHeight = (int) GetViewport().GetWindow().Size.Y;

		magnetCnt = magnetContainer.GetChildCount();
		px = new float[magnetCnt];
		py = new float[magnetCnt];
		mass = new float[magnetCnt];

		r = new byte[magnetCnt];
		g = new byte[magnetCnt];
		b = new byte[magnetCnt];

		for (int i = 0; i < magnetCnt; i++) {
			var n = magnetContainer.GetChild(i);
			px[i] = ((Vector2) n.Get("position")).X;
			py[i] = ((Vector2) n.Get("position")).Y;
			mass[i] = (float) n.Get("mass");
			r[i] = (byte) ((Color) n.Get("self_modulate")).R8;
			g[i] = (byte) ((Color) n.Get("self_modulate")).G8;
			b[i] = (byte) ((Color) n.Get("self_modulate")).B8;
		}
	}

	public bool Step(ref float x, ref float y, ref float vx, ref float vy, ref float ax, ref float ay, ref int closestMagnet) {
		vx += ax * DT / 2.0f;
		vy += ay * DT / 2.0f;

		x += vx;
		y += vy;

		ax = 0;
		ay = 0;

		if (x < 0 || x > fullWidth || y < 0 || y > fullHeight) {
			x = Math.Clamp(x, 0, fullWidth);
			y = Math.Clamp(y, 0, fullHeight);
			vx *= 0.5f;
			vy *= 0.5f;
		}

		for (int i = 0; i < magnetCnt; i++) {
			float dx = px[i] - x, dy = py[i] - y;
			float closestDist = (px[closestMagnet] - x) * (px[closestMagnet] - x) + (py[closestMagnet] - y) * (py[closestMagnet] - y);
			float dist = dx * dx + dy * dy;
			if (dist < closestDist) {
				closestMagnet = i;
			}

			if (dist < STOP_DIST_SQ) {
				return true;
			}
			
			float invr3 = (float) Math.Pow(dx * dx + dy * dy, -1.5f);
			
			
			ax += G * dx * invr3 * mass[i];
			ay += G * dy * invr3 * mass[i];
		}

		vx += ax * DT / 2.0f;
		vy += ay * DT / 2.0f;

		return false;
	}

	// Since Godot cannot handle reference parameters, we need a helper method to transfer data
	public bool StateStep(float x, float y, float vx, float vy, float ax, float ay) {
		oClosestMagnet = 0;
		bool result = Step(ref x, ref y, ref vx, ref vy, ref ax, ref ay, ref oClosestMagnet);
		ox = x; oy = y; ovx = vx; ovy = vy; oax = ax; oay = ay;
		return result;
	}

	public byte[] Simulate() {
		width = fullWidth / RES;
		height = fullHeight / RES;

		byte[] image = new byte[width * height * 4];

		if (magnetCnt == 0) {
			return image;
		}

		for (int initY = 0; initY < height; initY++) {
			for (int initX = 0; initX < width; initX++) {
				float x = initX * RES, y = initY * RES, ax = 0, ay = 0, vx = 0, vy = 0;
				int closestMagnet = 0;
				bool escapes = true;
				int iter = 0;
				for (iter = 0; iter < MAX_ITER; iter++) {
					if (Step(ref x, ref y, ref vx, ref vy, ref ax, ref ay, ref closestMagnet)) {
						escapes = false;
						break;
					}
				}
				
				float amt = 1.0f - (iter / (float) MAX_ITER);

				image[4 * (initX + initY * width)] = (byte) (amt * r[closestMagnet]);
				image[4 * (initX + initY * width) + 1] = (byte) (amt * g[closestMagnet]);
				image[4 * (initX + initY * width) + 2] = (byte) (amt * b[closestMagnet]);
				image[4 * (initX + initY * width) + 3] = 255;
			}
		}

		return image;
	}
}
