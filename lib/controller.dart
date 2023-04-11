import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fractals/fractal_type.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:window_manager/window_manager.dart';
import 'camera.dart';

class Controller with WindowListener {
  final FragmentProgram program;

  final Set<LogicalKeyboardKey> _logicalKeysPressed;

  late FractalType fractalType;
  late bool warpSpace;

  late FragmentShader _shader;
  late Camera _camera;
  late bool _pointerDown;

  late double _fractalTypeValue;

  Controller({
    required this.program,
  }) : _logicalKeysPressed = {} {
    fractalType = FractalType.mandelbulb;
    warpSpace = false;

    _camera = Camera(
      position: Vector3(-4, -1, 4),
      yaw: -90 + 45,
      pitch: 10,
    );
    _pointerDown = false;
    _fractalTypeValue = fractalType.value;
  }

  void attach() {
    _shader = program.fragmentShader();
    RawKeyboard.instance.addListener(onKey);
    windowManager.addListener(this);
  }

  void detach() {
    windowManager.removeListener(this);
    RawKeyboard.instance.removeListener(onKey);
    _shader.dispose();
  }

  void onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      _logicalKeysPressed.add(event.logicalKey);
    } else if (event is RawKeyUpEvent) {
      _logicalKeysPressed.remove(event.logicalKey);
    }
  }

  @override
  void onWindowBlur() {
    _logicalKeysPressed.clear();
  }

  void onPointerDown(PointerDownEvent event) {
    primaryFocus?.unfocus();
    _pointerDown = true;
    _camera.rotate(event.localDelta);
  }

  void onPointerMove(PointerMoveEvent event) {
    if (_pointerDown) {
      _camera.rotate(event.localDelta);
    }
  }

  void onPointerUp(PointerUpEvent event) {
    _pointerDown = false;
  }

  bool _isKeyPressed(LogicalKeyboardKey key) {
    return _logicalKeysPressed.contains(key);
  }

  void update(double deltaTime) {
    if (_isKeyPressed(LogicalKeyboardKey.keyW)) {
      primaryFocus?.unfocus();
      _camera.forward(deltaTime);
    }

    if (_isKeyPressed(LogicalKeyboardKey.keyS)) {
      primaryFocus?.unfocus();
      _camera.backward(deltaTime);
    }

    if (_isKeyPressed(LogicalKeyboardKey.keyA)) {
      primaryFocus?.unfocus();
      _camera.left(deltaTime);
    }

    if (_isKeyPressed(LogicalKeyboardKey.keyD)) {
      primaryFocus?.unfocus();
      _camera.right(deltaTime);
    }

    if (_isKeyPressed(LogicalKeyboardKey.space)) {
      primaryFocus?.unfocus();
      _camera.upward(deltaTime);
    }

    if (_isKeyPressed(LogicalKeyboardKey.shiftLeft)) {
      primaryFocus?.unfocus();
      _camera.downward(deltaTime);
    }

    _animateFractalType(deltaTime);
  }

  void _animateFractalType(double deltaTime) {
    final amount = (fractalType.value - _fractalTypeValue);
    _fractalTypeValue += amount * deltaTime * 5;
  }

  void render(Canvas canvas, Size size) {
    // Set uniforms
    _shader.setFloat(0, size.width);
    _shader.setFloat(1, size.height);

    _shader.setFloat(2, _fractalTypeValue);

    // Eye
    _camera.eye.storage.forEachIndexed((index, element) {
      _shader.setFloat(index + 3, element);
    });

    // Target
    _camera.target.storage.forEachIndexed((index, element) {
      _shader.setFloat(index + 6, element);
    });

    // Up
    _camera.up.storage.forEachIndexed((index, element) {
      _shader.setFloat(index + 9, element);
    });

    _shader.setFloat(12, warpSpace ? 1 : 0);

    // Create a rectangle that covers the entire canvas and attach shader
    final paint = Paint()..shader = _shader;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw the rectangle
    canvas.drawRect(rect, paint);
  }
}
