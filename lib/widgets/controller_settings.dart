import 'package:flutter/material.dart';
import 'package:fractals/fractal_type.dart';

import '../controller.dart';

class ControllerSettings extends StatefulWidget {
  final Controller controller;

  const ControllerSettings({super.key, required this.controller});

  @override
  State<ControllerSettings> createState() => _ControllerSettingsState();
}

class _ControllerSettingsState extends State<ControllerSettings> {
  late FractalType _fractalType;

  @override
  void initState() {
    super.initState();
    _fractalType = FractalType.mandelbulb;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButton(
            autofocus: false,
            value: _fractalType,
            isExpanded: true,
            items: FractalType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name),
              );
            }).toList(),
            onChanged: (type) {
              setState(() {
                _fractalType = type!;
                widget.controller.fractalType = type;
              });
            },
          ),
        ],
      ),
    );
  }
}
