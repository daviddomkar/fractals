import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'controller.dart';

class ControllerWidget extends StatelessWidget {
  final Controller controller;

  const ControllerWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: controller.onPointerDown,
      onPointerMove: controller.onPointerMove,
      onPointerUp: controller.onPointerUp,
      behavior: HitTestBehavior.translucent,
      child: ControllerRenderWidget(
        controller: controller,
      ),
    );
  }
}

class ControllerRenderWidget extends LeafRenderObjectWidget {
  final Controller controller;

  const ControllerRenderWidget({
    super.key,
    required this.controller,
  });

  @override
  RenderBox createRenderObject(BuildContext context) {
    return ControllerRenderBox(controller: controller);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    ControllerRenderBox renderObject,
  ) {
    renderObject.controller = controller;
  }
}

class ControllerRenderBox extends RenderBox {
  Controller _controller;

  int? _frameCallbackId;
  Duration _previousDeltaDuration;

  ControllerRenderBox({
    required Controller controller,
  })  : _controller = controller,
        _previousDeltaDuration = Duration.zero;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    _scheduleTick();

    _controller.attach();
  }

  @override
  void detach() {
    _controller.detach();

    _unscheduleTick();

    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    _controller.render(context.canvas, constraints.biggest);
    context.canvas.restore();
  }

  void _scheduleTick() {
    _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_tick);
  }

  void _unscheduleTick() {
    if (_frameCallbackId != null) {
      SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId!);
    }
  }

  void _tick(Duration timestamp) {
    if (!attached) {
      return;
    }

    _scheduleTick();
    final deltaTime = _computeDeltaTime(timestamp);
    _controller.update(deltaTime);
    markNeedsPaint();
  }

  double _computeDeltaTime(Duration now) {
    Duration delta = now - _previousDeltaDuration;
    if (_previousDeltaDuration == Duration.zero) {
      delta = Duration.zero;
    }
    _previousDeltaDuration = now;
    return delta.inMicroseconds / Duration.microsecondsPerSecond;
  }

  set controller(Controller controller) {
    if (_controller == controller) {
      return;
    }

    if (attached) {
      _controller.detach();
    }

    _controller = controller;

    if (attached) {
      _controller.attach();
    }
  }
}
