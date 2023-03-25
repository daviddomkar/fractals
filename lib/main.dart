import 'dart:ui';

import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final program = await FragmentProgram.fromAsset('shaders/raymarching.frag');

  runApp(
    FractalsApp(
      program: program,
    ),
  );
}

class FractalsApp extends StatelessWidget {
  final FragmentProgram program;

  const FractalsApp({
    super.key,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fractals',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: CustomPaint(
          painter: RaymarchingPainter(program: program),
          child: Container(),
        ),
      ),
    );
  }
}

class RaymarchingPainter extends CustomPainter {
  final FragmentShader _shader;

  RaymarchingPainter({
    required FragmentProgram program,
  }) : _shader = program.fragmentShader();

  @override
  void paint(Canvas canvas, Size size) {
    _shader.setFloat(0, size.width);
    _shader.setFloat(1, size.height);

    final paint = Paint()..shader = _shader;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
