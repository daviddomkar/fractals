import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fractals/fractal_type.dart';
import 'package:vector_math/vector_math_64.dart';

import '../controller.dart';

class ControllerSettings extends StatefulWidget {
  final Controller controller;

  const ControllerSettings({super.key, required this.controller});

  @override
  State<ControllerSettings> createState() => _ControllerSettingsState();
}

class _ControllerSettingsState extends State<ControllerSettings> {
  late FractalType _fractalType;
  late Color _fractalColor;
  late bool _warpSpace;
  late Vector3 _rotation;

  @override
  void initState() {
    super.initState();
    _fractalType = widget.controller.fractalType;
    _warpSpace = widget.controller.warpSpace;
    _fractalColor = widget.controller.fractalColor;
    _rotation = Vector3(
      degrees(widget.controller.rotation.x),
      degrees(widget.controller.rotation.y),
      degrees(widget.controller.rotation.z),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: 'Fractal Type',
                ),
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
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Warp Space'),
                value: _warpSpace,
                onChanged: (value) {
                  setState(() {
                    _warpSpace = value ?? false;
                    widget.controller.warpSpace = _warpSpace;
                  });
                },
              ),
              const SizedBox(height: 16),
              ColorPicker(
                pickerColor: _fractalColor,
                portraitOnly: true,
                enableAlpha: false,
                onHsvColorChanged: (value) {
                  setState(() {
                    _fractalColor = value.toColor();
                    final color = value.withHue(360 - value.hue).toColor();
                    widget.controller.fractalColor = color;
                  });
                },
                onColorChanged: (_) {},
              ),
              const SizedBox(height: 16),
              const Text('Rotate X'),
              Slider(
                min: -360,
                max: 360,
                divisions: 360,
                value: _rotation.x,
                label: '${_rotation.x.round()}°',
                onChanged: (value) {
                  setState(() {
                    _rotation.x = value;
                    widget.controller.rotation.x = radians(
                      value.roundToDouble(),
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Rotate Y'),
              Slider(
                min: -360,
                max: 360,
                divisions: 360,
                value: _rotation.y,
                label: '${_rotation.y.round()}°',
                onChanged: (value) {
                  setState(() {
                    _rotation.y = value;
                    widget.controller.rotation.y = radians(
                      value.roundToDouble(),
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Rotate Z'),
              Slider(
                min: -360,
                max: 360,
                divisions: 360,
                value: _rotation.z,
                label: '${_rotation.z.round()}°',
                onChanged: (value) {
                  setState(() {
                    _rotation.z = value;
                    widget.controller.rotation.z = radians(
                      value.roundToDouble(),
                    );
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
