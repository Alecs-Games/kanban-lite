import 'package:flutter/widgets.dart';
import './handle.dart';

class HandlePainter {
  HandlePainter();

  void draw(Canvas canvas, Handle handle) {
    //draw card outline
    final Rect rect = Rect.fromLTWH(
      handle.offset.dx,
      handle.offset.dy,
      handle.size.width,
      handle.size.height,
    );
    final Paint paint =
        Paint()
          ..color = const Color(0xFF000000)
          ..style = PaintingStyle.fill
          ..strokeWidth = 2;
    canvas.drawRect(rect, paint);
  }
}
