import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:vector_math/vector_math_64.dart';

import '../controller.dart';
import '../extensions.dart';
import '../fractal_type.dart';

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
  late double _planeY;
  late Vector3 _planeRotation;

  @override
  void initState() {
    super.initState();
    _fractalType = widget.controller.fractalType;
    _warpSpace = widget.controller.warpSpace;
    _fractalColor = widget.controller.fractalColor;
    _rotation = widget.controller.rotation.toEuler();
    _planeY = widget.controller.planeY;
    _planeRotation = widget.controller.planeRotation.toEuler();
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
                min: -180,
                max: 180,
                value: _rotation.x,
                label: '${_rotation.x.round()}°',
                onChanged: (value) {
                  setState(() {
                    _rotation.x = value.roundToDouble();
                    widget.controller.rotation.setEuler(
                      radians(_rotation.x),
                      radians(_rotation.y),
                      radians(_rotation.z),
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Rotate Y'),
              Slider(
                min: -180,
                max: 180,
                value: _rotation.y,
                label: '${_rotation.y.round()}°',
                onChanged: (value) {
                  setState(() {
                    _rotation.y = value.roundToDouble();
                    widget.controller.rotation.setEuler(
                      radians(_rotation.x),
                      radians(_rotation.y),
                      radians(_rotation.z),
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Rotate Z'),
              Slider(
                min: -180,
                max: 180,
                value: _rotation.z,
                label: '${_rotation.z.round()}°',
                onChanged: (value) {
                  setState(() {
                    _rotation.z = value.roundToDouble();
                    widget.controller.rotation.setEuler(
                      radians(_rotation.x),
                      radians(_rotation.y),
                      radians(_rotation.z),
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Plane Y'),
              Slider(
                min: -1.5,
                max: 1.5,
                value: _planeY,
                label: _planeY.toStringAsFixed(2),
                onChanged: (value) {
                  setState(() {
                    _planeY = value;
                    widget.controller.planeY = _planeY;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Plane Rotate X'),
              Slider(
                min: -180,
                max: 180,
                value: _planeRotation.y,
                label: '${_planeRotation.y.round()}°',
                onChanged: (value) {
                  setState(() {
                    _planeRotation.y = value.roundToDouble();
                    widget.controller.planeRotation.setEuler(
                      radians(_planeRotation.x),
                      radians(_planeRotation.y),
                      radians(_planeRotation.z),
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Plane Rotate Z'),
              Slider(
                min: -180,
                max: 180,
                value: _planeRotation.z,
                label: '${_planeRotation.z.round()}°',
                onChanged: (value) {
                  setState(() {
                    _planeRotation.z = value.roundToDouble();
                    widget.controller.planeRotation.setEuler(
                      radians(_planeRotation.x),
                      radians(_planeRotation.y),
                      radians(_planeRotation.z),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
