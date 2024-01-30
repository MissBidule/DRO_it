import 'dart:typed_data';
import 'package:eye_dropper/eye_dropper.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

class EyeDropperWOtext extends StatefulWidget {
  const EyeDropperWOtext({
    super.key,
    required this.child,
    this.haveTextColorWidget = false,
  });

  final Widget child;
  final bool haveTextColorWidget;

  static void enableEyeDropper(
      BuildContext context, Function(Color?)? onEyeDropper) async {
    _EyeDropperWOtextState? state =
        context.findAncestorStateOfType<_EyeDropperWOtextState>();
    state?.enableEyeDropper(onEyeDropper);
  }

  @override
  State<EyeDropperWOtext> createState() => _EyeDropperWOtextState();
}

class _EyeDropperWOtextState extends State<EyeDropperWOtext> {
  final GlobalKey _renderKey = GlobalKey();

  ui.Image? _image;
  bool _enableEyeDropper = false;

  final _offsetNotifier = ValueNotifier<Offset>(const Offset(0, 0));
  final _colorNotifier = ValueNotifier<Color?>(null);
  final _byteDataStateNotifier = ValueNotifier<ByteData?>(null);
  Function(Color?)? _onEyeDropper;

  void enableEyeDropper(Function(Color?)? onEyeDropper) async {
    var renderBox = _renderKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final boundary =
        _renderKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

    // inital image - byte data
    _image = await boundary.toImage();
    _byteDataStateNotifier.value = await _image!.toByteData();

    setState(() {
      // enable color picker
      _enableEyeDropper = true;
      // place the color picker overlay's position in the center
      updatePosition(Offset(size.width / 2, size.height / 2));

      _onEyeDropper = onEyeDropper;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: onPointerDown,
          onPointerMove: onPointerMove,
          onPointerUp: onPointerUp,
          child: RepaintBoundary(
            key: _renderKey,
            child: widget.child,
          ),
        ),
        Visibility(
          visible: _enableEyeDropper,
          child: Positioned(
            left: getOverlayPosition().dx,
            top: getOverlayPosition().dy,
            child: Listener(
              onPointerMove: onPointerMove,
              onPointerUp: onPointerUp,
              child: EyeDropperOverlay(
                color: _colorNotifier.value ?? Colors.transparent,
              ),
            ),
          ),
        ),
        Visibility(
          visible: !(_colorNotifier.value != null && widget.haveTextColorWidget == false),
          child: Positioned(
            left: _offsetNotifier.value.dx - 30,
            top: _offsetNotifier.value.dy + 20,
            child: Material(
              shadowColor: Colors.black,
              elevation: 1.0,
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  _colorNotifier.value == null
                      ? ''
                      : colorToHexString(_colorNotifier.value!),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Offset getOverlayPosition() {
    double dx = _offsetNotifier.value.dx - kOverlaySize.width / 2;
    double dy =
        _offsetNotifier.value.dy - kOverlaySize.height + kEyeDropperSize / 2;
    return Offset(dx, dy);
  }

  void onPointerDown(PointerDownEvent event) {
    if (_enableEyeDropper) {
      updatePosition(event.position);
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (_enableEyeDropper) {
      updatePosition(event.position);
    }
  }

  void onPointerUp(PointerUpEvent event) async {
    if (_enableEyeDropper) {
      if (_colorNotifier.value != null) {
        _onEyeDropper?.call(_colorNotifier.value);
      }

      setState(() {
        _enableEyeDropper = false;
        _offsetNotifier.value = const Offset(0, 0);
        _colorNotifier.value = null;
        _image = null;
      });
    }
  }

  updatePosition(Offset newPosition) async {
    var color = getPixelFromByteData(
      _byteDataStateNotifier.value!,
      width: _image!.width,
      x: newPosition.dx.toInt(),
      y: newPosition.dy.toInt(),
    );

    setState(() {
      // update position
      _offsetNotifier.value = newPosition;

      // update color
      _colorNotifier.value = color;
    });
  }
}