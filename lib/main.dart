import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'controller.dart';
import 'widgets/controller_view.dart';
import 'widgets/controller_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final program = await FragmentProgram.fromAsset('shaders/raymarching.frag');
  final controller = Controller(program: program);

  runApp(
    FractalsApp(
      controller: controller,
    ),
  );
}

class FractalsApp extends StatelessWidget {
  final Controller controller;

  const FractalsApp({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fractals',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Row(
          children: [
            Expanded(
              child: ControllerView(
                controller: controller,
              ),
            ),
            SizedBox(
              width: 320,
              child: ControllerSettings(
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
