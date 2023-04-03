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
	double G = 1.0, DT = 32.0, STOP_DIST_SQ = 96.0;
	int RES = 4, MAX_ITER = 256;
	int width, height, fullWidth, fullHeight, magnetCnt;

	public void InitializeMagnets(Node magnetContainer) {
		double winWidth = (double) GetViewport().GetWindow().Size.X;
		double winHeight = (double) GetViewport().GetWindow().Size.Y;
		
		fullWidth = (int) (winWidth);
		fullHeight = (int) (winHeight);

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

	public bool Step(ref double x, ref double y, ref double vx, ref double vy, ref double ax, ref double ay, ref int closestMagnet) {
		vx += ax * DT / 2.0;
		vy += ay * DT / 2.0;

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
			double dx = px[i] - x, dy = py[i] - y;
			double closestDist = (px[closestMagnet] - x) * (px[closestMagnet] - x) + (py[closestMagnet] - y) * (py[closestMagnet] - y);
			double dist = dx * dx + dy * dy;
			if (dist < closestDist) {
				closestMagnet = i;
			}

			if (dist < STOP_DIST_SQ) {
				return true;
			}
			
			double invr3 = Math.Pow(dx * dx + dy * dy, -1.5f);
			
			
			ax += G * dx * invr3 * mass[i];
			ay += G * dy * invr3 * mass[i];
		}

		vx += ax * DT / 2.0;
		vy += ay * DT / 2.0;

		return false;
	}

	// Since Godot cannot handle reference parameters, we need a helper method to transfer data...
	// Also, there are no doubles in GdScript!
	public bool StateStep(float x, float y, float vx, float vy, float ax, float ay) {
		oClosestMagnet = 0;
		
		double dox = x, doy = y, dovx = vx, dovy = vy, doax = ax, doay = ay;
		bool result = Step(ref dox, ref doy, ref dovx, ref dovy, ref doax, ref doay, ref oClosestMagnet);
		ox = (float) dox; oy = (float) doy; 
		ovx = (float) dovx; ovy = (float) dovy; 
		oax = (float) doax; oay = (float) doay;

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
				double x = initX * RES + RES / 2.0, y = initY * RES + RES / 2.0, ax = 0, ay = 0, vx = 0, vy = 0;
				int closestMagnet = 0;
				int iter = 0;
				for (iter = 0; iter < MAX_ITER; iter++) {
					if (Step(ref x, ref y, ref vx, ref vy, ref ax, ref ay, ref closestMagnet)) {
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
