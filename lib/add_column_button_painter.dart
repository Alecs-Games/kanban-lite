import 'package:flutter/widgets.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kanban_lite/add_column_button.dart';

class AddColumnButtonPainter {
  //draw rect
  void draw(
    Canvas canvas,
    double startWidth,
    Size columnSize,
    AddColumnButton button,
  ) {
    final Size padding = Size(columnSize.width / 4, columnSize.height / 1.2);
    final Rect rect = Rect.fromLTWH(
      startWidth + (padding.width / 2),
      padding.height / 2,
      columnSize.width - padding.width,
      columnSize.height - padding.height,
    );
    final Paint paint =
        Paint()
          ..color = const Color(0xFF000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    button.rect = rect;
    canvas.drawRect(rect, paint);
    //draw icon
    IoniconsData icon = Ionicons.add_outline;
    final double fontSize = columnSize.height / 20;
    final iconTextSpan = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        color: Color(0xFF000000),
        fontSize: fontSize,
        fontFamily: 'Ionicons',
        package: icon.fontPackage,
      ),
    );
    final iconTextPainter = TextPainter(
      text: iconTextSpan,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      maxLines: null,
    );
    iconTextPainter.layout();
    iconTextPainter.paint(
      canvas,
      Offset(
        rect.left + ((rect.width - iconTextPainter.width) / 2),
        rect.top + ((rect.height - iconTextPainter.height) / 2),
      ),
    );
  }
}
