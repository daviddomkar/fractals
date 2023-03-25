#include <flutter/runtime_effect.glsl>

precision highp float;

layout(location = 0) uniform vec2 resolution;

layout(location = 0) out vec4 fragColor;

const int MAX_STEPS = 127;
const float MAX_DISTANCE = 100.0;
const float EPSILON = 0.0001;
const int FRACTAL_ITERATIONS = 8;

float estimateSphereDistance(vec3 point) {
  return length(point) - 1;
}

float estimateBoxDistance(vec3 point, vec3 dimensions)
{
  vec3 q = abs(point) - dimensions;
  return length(max(q, 0)) + min(max(q.x, max(q.y, q.z)), 0);
}

float estimateMengerSpongeDistance(vec3 point)
{
  float d = estimateBoxDistance(point, vec3(1));

  float s = 1;
  for(int i = 0; i < FRACTAL_ITERATIONS; i++)
  {
      vec3 a = mod(point * s, 2) - 1;
      s *= 3;
      vec3 r = abs(1 - 3 * abs(a));

      float da = max(r.x, r.y);
      float db = max(r.y, r.z);
      float dc = max(r.z, r.x);
      float c = (min(da, min(db, dc)) - 1) / s;

      d = max(d, c);
  }

  return d;
}

float estimateMandelbulbDistance(vec3 point) {
	vec3 z = point;
	float dr = 1.0;
	float r = 0.0;
	for (int i = 0; i < FRACTAL_ITERATIONS; i++) {
		r = length(z);
		if (r > 5) break;
		
		float theta = acos(z.z / r);
		float phi = atan(z.y, z.x);
		dr =  pow(r, 8 - 1.0) * 8 * dr + 1.0;

		float zr = pow(r, 8);
		theta = theta * 8;
		phi = phi * 8;
		
		z = zr * vec3(sin(theta) * cos(phi), sin(phi) * sin(theta), cos(theta));
		z += point;
	}

	return 0.5 * log(r) * r / dr;
}

float estimateDistance(vec3 point) {
  return estimateMengerSpongeDistance(point);
  // return estimateSphereDistance(point);
  // return estimateMandelbulbDistance(point);
}

vec3 estimateNormal(vec3 point) {
    float dist = estimateDistance(point);
    vec2 epsilon = vec2(EPSILON, 0);

    vec3 normal = dist - vec3(estimateDistance(point - epsilon.xyy), estimateDistance(point - epsilon.yxy), estimateDistance(point - epsilon.yyx));

    return normalize(normal);
}

float raymarch(vec3 origin, vec3 direction) {
  float depth = 0;

  // March the ray through the scene.
  for (int i = 0; i < MAX_STEPS; i++) {
    // Estimate the distance at the current position.
    float dist = estimateDistance(origin + direction * depth);

    // If the distance is less than the epsilon, we've hit the surface.
    if (dist < EPSILON) {
      return depth;
    }

    // Otherwise, keep marching.
    depth += dist;

    // If we've gone too far, bail.
    if (depth >= MAX_DISTANCE) {
      return MAX_DISTANCE;
    }
  }

  return MAX_DISTANCE;
}

void main() {
  // Normalized coordinates. (From -1 to 1 on y axis)
  vec2 coords = (FlutterFragCoord().xy - resolution * 0.5) / resolution.y;

  vec3 origin = vec3(0, 0, 6);
  vec3 direction = normalize(vec3(coords.x, coords.y, -2));

  float depth = raymarch(origin, direction);

  // If we've gone too far, bail.
  if (depth >= MAX_DISTANCE) {
    fragColor = vec4(0.0, 0.0, 0.0, 1.0);
		return;
  }

  vec3 pointOnSurface = origin + direction * depth;

  vec3 color = estimateNormal(pointOnSurface);

  fragColor = vec4(color, 1.0);
}