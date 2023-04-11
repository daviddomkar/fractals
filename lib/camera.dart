import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

// Camera implementation based on https://learnopengl.com/Getting-started/Camera
class Camera {
  final Vector3 _up;

  Vector3 _position;

  double _yaw;
  double _pitch;

  Camera({
    Vector3? up,
    Vector3? position,
    double yaw = -90,
    double pitch = 0,
  })  : _up = up ?? Vector3(0, 1, 0),
        _position = position ?? Vector3.zero(),
        _yaw = -90,
        _pitch = 0;

  void forward(double amount) {
    _position += front * amount;
  }

  void backward(double amount) {
    _position -= front * amount;
  }

  void left(double amount) {
    _position -= front.cross(_up).normalized() * amount;
  }

  void right(double amount) {
    _position += front.cross(_up).normalized() * amount;
  }

  void upward(double amount) {
    _position -= _up * amount;
  }

  void downward(double amount) {
    _position += _up * amount;
  }

  void rotate(Offset delta) {
    double sensitivity = 0.1;
    delta *= sensitivity;

    _yaw += delta.dx;
    _pitch += delta.dy;

    if (_pitch > 89.0) _pitch = 89.0;
    if (_pitch < -89.0) _pitch = -89.0;
  }

  Vector3 get front {
    return Vector3(
      cos(radians(_yaw)) * cos(radians(_pitch)),
      sin(radians(_pitch)),
      sin(radians(_yaw)) * cos(radians(_pitch)),
    ).normalized();
  }

  Vector3 get eye => _position;

  Vector3 get target {
    return _position + front;
  }

  Vector3 get up => _up;
}
