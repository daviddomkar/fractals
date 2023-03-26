import 'package:vector_math/vector_math_64.dart';

class Camera {
  Vector3 position;
  Vector3 front;
  Vector3 up;

  Camera()
      : position = Vector3(0, 0, 6),
        front = Vector3(0, 0, -1),
        up = Vector3(0, 1, 0);
}
