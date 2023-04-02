using Godot;
using System;

public partial class NBodySimulation : Node {
	// State variables for all magnets
	double[] px, py, mass;
	byte[] r, g, b;

	// Output of the simulation
	byte[] outCol;

	// State variables for a single iron
	double x, y, vx, vy, ax, ay;
	int closestMagnet, magnetCnt;

	// Simulation parameters
	double G = 1.0f, DT = 4.0f;
	int RES = 1, MAX_ITER = 512;
	int width, height;

	public void InitializeMagnets() {
		magnetCnt = GetNode("%MagnetContainer").GetChildCount();
		px = new double[magnetCnt];
		py = new double[magnetCnt];
		mass = new double[magnetCnt];

		r = new byte[magnetCnt];
		g = new byte[magnetCnt];
		b = new byte[magnetCnt];

		for (int i = 0; i < magnetCnt; i++) {
			var n = GetNode("%MagnetContainer").GetChild(i);
			px[i] = ((Vector2) n.Get("position")).X;
			py[i] = ((Vector2) n.Get("position")).Y;
			mass[i] = (double) n.Get("mass");
			r[i] = (byte) ((Color) n.Get("self_modulate")).R8;
			g[i] = (byte) ((Color) n.Get("self_modulate")).G8;
			b[i] = (byte) ((Color) n.Get("self_modulate")).B8;
		}
	}

	public bool Step() {
		vx += ax * DT / 2.0;
		vy += ay * DT / 2.0;

		x += vx;
		y += vy;

		for (int i = 0; i < magnetCnt; i++) {
			double dx = px[i] - x, dy = py[i] - y;
			double closestDist = (px[closestMagnet] - x) * (px[closestMagnet] - x) + (py[closestMagnet] - y) * (py[closestMagnet] - y);
			double dist = dx * dx + dy * dy;
			if (dist < closestDist) {
				closestMagnet = i;
			}

			if (dist < 1.0) {
				return true;
			}
			
			double invr3 = Math.Pow(dx * dx + dy * dy, -1.5);
			
			
			ax += G * dx * invr3 * mass[i];
			ay += G * dy * invr3 * mass[i];
		}

		vx += ax * DT / 2.0;
		vy += ay * DT / 2.0;

		return false;
	}

	public byte[] Simulate() {
		width = (int) ProjectSettings.GetSetting("display/window/size/viewport_width") / RES;
		height = (int) ProjectSettings.GetSetting("display/window/size/viewport_height") / RES;

		outCol = new byte[width * height * 4];

		for (int initY = 0; initY < height; initY += RES) {
			for (int initX = 0; initX < width; initX += RES) {
				x = initX;
				y = initY;
				ax = 0;
				ay = 0;
				vx = 0;
				vy = 0;
				for (int iter = 0; iter < MAX_ITER; iter++) {
					if (Step()) {
						break;
					}
				}
				outCol[4 * (initX / RES + initY / RES * width)] = r[closestMagnet];
				outCol[4 * (initX / RES + initY / RES * width) + 1] = g[closestMagnet];
				outCol[4 * (initX / RES + initY / RES * width) + 2] = b[closestMagnet];
				outCol[4 * (initX / RES + initY / RES * width) + 3] = 255;
			}
		}

		return outCol;
	}
}
