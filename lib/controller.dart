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
  late double glow;
  late Color fractalColor;
  late Quaternion rotation;
  late double planeSlice;
  late Vector3 planeOrientation;

  late FragmentShader _shader;
  late Camera _camera;
  late bool _pointerDown;

  late double _fractalTypeValue;

  Controller({
    required this.program,
  }) : _logicalKeysPressed = {} {
    fractalType = FractalType.mandelbulb;
    warpSpace = false;
    glow = 0.5;
    fractalColor = const Color(0xFFFF0000);
    rotation = Quaternion.identity();
    planeSlice = 1.5;
    planeOrientation = Vector3(0, -1, 0);

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

    // Eye
    _camera.eye.storage.forEachIndexed((index, element) {
      _shader.setFloat(index + 2, element);
    });

    // Target
    _camera.target.storage.forEachIndexed((index, element) {
      _shader.setFloat(index + 5, element);
    });

    // Up
    _camera.up.storage.forEachIndexed((index, element) {
      _shader.setFloat(index + 8, element);
    });

    _shader.setFloat(11, _fractalTypeValue);
    _shader.setFloat(12, warpSpace ? 1 : 0);
    _shader.setFloat(13, glow);
    _shader.setFloat(14, fractalColor.red / 255);
    _shader.setFloat(15, fractalColor.blue / 255);
    _shader.setFloat(16, fractalColor.green / 255);
    _shader.setFloat(17, fractalColor.alpha / 255);

    rotation.storage.forEachIndexed((index, element) {
      _shader.setFloat(index + 18, element);
    });

    _shader.setFloat(22, planeSlice);

    planeOrientation.storage.forEachIndexed((index, element) {
      _shader.setFloat(index + 23, element);
    });

    // Create a rectangle that covers the entire canvas and attach shader
    final paint = Paint()..shader = _shader;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw the rectangle
    canvas.drawRect(rect, paint);
  }
}
