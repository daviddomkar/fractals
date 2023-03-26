import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import 'camera.dart';

class Controller {
  final FragmentProgram program;

  Controller({
    required this.program,
  });

  late FragmentShader _shader;
  late Camera _camera;
  late bool _pointerDown;

  late double _yaw;
  late double _pitch;

  void attach() {
    _shader = program.fragmentShader();
    _camera = Camera();
    _pointerDown = false;

    _yaw = -90;
    _pitch = 0;

    _updateCameraRotation(Offset.zero);
  }

  void onPointerDown(PointerDownEvent event) {
    _pointerDown = true;
    _updateCameraRotation(event.localDelta);
  }

  void onPointerMove(PointerMoveEvent event) {
    if (_pointerDown) {
      _updateCameraRotation(event.localDelta);
    }
  }

  void onPointerUp(PointerUpEvent event) {
    _pointerDown = false;
  }

  bool _isKeyPressed(LogicalKeyboardKey key) {
    return RawKeyboard.instance.keysPressed.contains(key);
  }

  void _updateCameraRotation(Offset delta) {
    double sensitivity = 0.1;
    delta *= sensitivity;

    _yaw += delta.dx;
    _pitch += delta.dy;

    if (_pitch > 89.0) _pitch = 89.0;
    if (_pitch < -89.0) _pitch = -89.0;

    Vector3 direction = Vector3(
      cos(radians(_yaw)) * cos(radians(_pitch)),
      sin(radians(_pitch)),
      sin(radians(_yaw)) * cos(radians(_pitch)),
    );

    _camera.front = direction.normalized();
  }

  void update(double deltaTime) {
    if (_isKeyPressed(LogicalKeyboardKey.keyW)) {
      _camera.position += _camera.front * deltaTime;
    }

    if (_isKeyPressed(LogicalKeyboardKey.keyS)) {
      _camera.position -= _camera.front * deltaTime;
    }

    if (_isKeyPressed(LogicalKeyboardKey.keyA)) {
      _camera.position -=
          _camera.front.cross(_camera.up).normalized() * deltaTime;
    }

    if (_isKeyPressed(LogicalKeyboardKey.keyD)) {
      _camera.position +=
          _camera.front.cross(_camera.up).normalized() * deltaTime;
    }

    if (_isKeyPressed(LogicalKeyboardKey.space)) {
      _camera.position -= _camera.up * deltaTime;
    }

    if (_isKeyPressed(LogicalKeyboardKey.shiftLeft)) {
      _camera.position += _camera.up * deltaTime;
    }
  }

  void render(Canvas canvas, Size size) {
    _shader.setFloat(0, size.width);
    _shader.setFloat(1, size.height);

    // Eye
    _camera.position.storage.forEachIndexed((index, element) {
      _shader.setFloat(index + 2, element);
    });

    // Target
    (_camera.position + _camera.front).storage.forEachIndexed((index, element) {
      _shader.setFloat(index + 5, element);
    });

    // Up
    _camera.up.storage.forEachIndexed((index, element) {
      _shader.setFloat(index + 8, element);
    });

    final paint = Paint()..shader = _shader;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, paint);
  }

  void detach() {
    _shader.dispose();
  }
}
