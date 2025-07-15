import 'package:flutter/widgets.dart';

class Handle {
  late Size size;
  late Offset offset;
  bool isHeld = false;
  Handle();
  bool contains(Offset position) {
    final Rect rect = offset & size;
    return rect.contains(position);
  }
}
