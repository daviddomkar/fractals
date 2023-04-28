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
  late double _glow;
  late Vector3 _rotation;
  late double _planeSlice;
  late Vector3 _planeOrientation;

  @override
  void initState() {
    super.initState();
    _fractalType = widget.controller.fractalType;
    _warpSpace = widget.controller.warpSpace;
    _glow = widget.controller.glow;
    _fractalColor = widget.controller.fractalColor;
    _rotation = widget.controller.rotation.toEuler();
    _planeSlice = widget.controller.planeSlice;
    _planeOrientation = widget.controller.planeOrientation;
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
              const Text('Glow Intensity'),
              Slider(
                min: 0.0,
                max: 1.0,
                value: _glow,
                label: _glow.toStringAsFixed(2),
                onChanged: (value) {
                  setState(() {
                    _glow = value;
                    widget.controller.glow = _glow;
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
              const Text('Plane Slice'),
              Slider(
                min: -3,
                max: 3,
                value: _planeSlice,
                label: _planeSlice.toStringAsFixed(2),
                onChanged: (value) {
                  setState(() {
                    _planeSlice = value;
                    widget.controller.planeSlice = _planeSlice;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Plane Orientation X'),
              Slider(
                min: -1,
                max: 1,
                value: _planeOrientation.x,
                label: _planeOrientation.x.toStringAsFixed(2),
                onChanged: (value) {
                  setState(() {
                    _planeOrientation.x = value;
                    widget.controller.planeOrientation = _planeOrientation;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Plane Orientation Y'),
              Slider(
                min: -1,
                max: 1,
                value: _planeOrientation.y,
                label: _planeOrientation.y.toStringAsFixed(2),
                onChanged: (value) {
                  setState(() {
                    _planeOrientation.y = value;
                    widget.controller.planeOrientation = _planeOrientation;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Plane Orientation Z'),
              Slider(
                min: -1,
                max: 1,
                value: _planeOrientation.z,
                label: _planeOrientation.z.toStringAsFixed(2),
                onChanged: (value) {
                  setState(() {
                    _planeOrientation.z = value;
                    widget.controller.planeOrientation = _planeOrientation;
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
