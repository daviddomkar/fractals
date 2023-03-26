import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fractals/controller.dart';
import 'package:fractals/controller_widget.dart';

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
  final Controller controller;

  FractalsApp({
    super.key,
    required FragmentProgram program,
  }) : controller = Controller(program: program);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fractals',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: ControllerWidget(
          controller: controller,
        ),
      ),
    );
  }
}
