#include <flutter/runtime_effect.glsl>

precision highp float;

layout(location = 0) uniform vec2 resolution;

layout(location = 1) uniform vec3 eye;
layout(location = 2) uniform vec3 target;
layout(location = 3) uniform vec3 up;

layout(location = 4) uniform float fractalTypeValue;
layout(location = 5) uniform float warpSpace;
layout(location = 6) uniform float glow;
layout(location = 7) uniform vec4 fractalColor;
layout(location = 8) uniform vec4 rotation;
layout(location = 9) uniform float planeSlice;
layout(location = 10) uniform vec3 planeOrientation;


layout(location = 0) out vec4 fragColor;

const int MAX_STEPS = 100;
const float MAX_DISTANCE = 100.0;
const float EPSILON = 0.0001;
const int FRACTAL_ITERATIONS = 5;


vec3 rotatePoint(vec3 point, vec4 quaternion) {
  return point + 2.0 * cross(quaternion.xyz, cross(quaternion.xyz, point) + quaternion.w * point);
}

float estimateBoxDistance(vec3 point, vec3 dimensions) {
  vec3 q = abs(point) - dimensions;
  return length(max(q, 0)) + min(max(q.x, max(q.y, q.z)), 0);
}

// https://iquilezles.org/articles/menger/
float estimateMengerSpongeDistance(vec3 point) {
  float d = estimateBoxDistance(point, vec3(1));

  float s = 1;
  for(int i = 0; i < FRACTAL_ITERATIONS; i++)
  {
      point = rotatePoint(point, rotation);

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

// http://blog.hvidtfeldts.net/index.php/2011/09/distance-estimated-3d-fractals-v-the-mandelbulb-different-de-approximations/
float estimateMandelbulbDistance(vec3 point) {
	vec3 z = point;

  float power = 8.0;
	float dr = 1.0;
	float r = 0.0;

	for (int i = 0; i < FRACTAL_ITERATIONS; i++) {
    point = rotatePoint(point, rotation);

		r = length(z);
		if (r > 5) break;

		float theta = acos(z.z / r);
		float phi = atan(z.y, z.x);
		dr =  pow(r, power - 1.0) * power * dr + 1.0;

		float zr = pow(r, power);
		theta = theta * power;
		phi = phi * power;

		z = zr * vec3(sin(theta) * cos(phi), sin(phi) * sin(theta), cos(theta));
		z += point;
	}

	return 0.5 * log(r) * r / dr;
}

float estimateDistance(vec3 point) {
  if (warpSpace > 0.5) {
    point = mod(point + 3, 6) - 3;
  }

  float plane = dot(point + planeSlice, normalize(planeOrientation));

  float fractal = mix(estimateMandelbulbDistance(point), estimateMengerSpongeDistance(point), fractalTypeValue);

  return max(fractal, plane);
}

// x - distance, y - smallest distance, z - number of steps
vec3 raymarch(vec3 origin, vec3 direction) {
  float depth = 0;
  float smallestDistance = MAX_DISTANCE;

  // March the ray through the scene.
  for (int i = 0; i < MAX_STEPS; i++) {
    // Estimate the distance at the current position.
    float dist = estimateDistance(origin + direction * depth);

    // Keep track of the smallest distance we've seen.
    if (dist < smallestDistance) {
      smallestDistance = dist;
    }

    // If the distance is less than the epsilon, we've hit the surface.
    if (dist < EPSILON) {
      return vec3(depth, smallestDistance, float(i));
    }

    // Otherwise, keep marching.
    depth += dist * 0.5;

    // If we've gone too far, bail.
    if (depth >= MAX_DISTANCE) {
      return vec3(MAX_DISTANCE, smallestDistance, float(i));
    }
  }

  return vec3(MAX_DISTANCE, smallestDistance, 0);
}

vec3 rayDirection(float fieldOfView, vec2 resolution, vec2 coords) {
    vec2 xy = coords - resolution / 2.0;
    float z = resolution.y / tan(radians(fieldOfView) / 2.0);
    return normalize(vec3(xy, -z));
}

mat4 lookAt(vec3 eye, vec3 target, vec3 up){
    vec3 f = normalize(target - eye);
    vec3 s = normalize(cross(f, up));
    vec3 u = cross(s, f);

    return mat4(
        vec4(s, 0.0),
        vec4(u, 0.0),
        vec4(-f, 0.0),
        vec4(0.0, 0.0, 0.0, 1)
    );
}

vec4 getAmbientColor(vec3 result) {
  float depth = result.x;
  float steps = result.z;

  if (depth < MAX_DISTANCE) {
    return vec4(fractalColor.rgb * (1.0 - steps / MAX_STEPS), 1.0);
  } else {
    return vec4(0.0, 0.0, 0.0, 1.0);
  }
}

vec4 getGlowColor(vec3 result) {
  float depth = result.x;
  float smallestDistance = result.y;
  float steps = result.z;

  if (smallestDistance <= 1 || depth < MAX_DISTANCE) {
    vec4 ambientOcclusion = getAmbientColor(result);
    vec4 glowColor = vec4(fractalColor.rgb * (1 - pow(smallestDistance, 0.3)), 1.0);

    return mix(glowColor, ambientOcclusion, (1 - pow(smallestDistance, 0.01)));
  } else {
    return vec4(0.0, 0.0, 0.0, 1.0);
  }
}

void main() {
  mat4 view = lookAt(eye, target, up);

  vec3 direction = rayDirection(45.0, resolution, FlutterFragCoord().xy);
  vec3 viewDirection = (view * vec4(direction, 0.0)).xyz;

  vec3 result = raymarch(eye, viewDirection);

  float depth = result.x;
  float smallestDistance = result.y;
  float steps = result.z;

  vec3 pointOnSurface = eye + viewDirection * depth;

  vec4 ambientColor = getAmbientColor(result);
  vec4 glowColor = getGlowColor(result);

  vec4 color = mix(ambientColor, glowColor, glow);
  
  fragColor = color;
}