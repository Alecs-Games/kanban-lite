import 'package:flutter/widgets.dart';
import 'package:kanban_lite/handle_painter.dart';
import './card.dart' as ca;
import 'package:ionicons/ionicons.dart';

class CardPainter {
  static const double textMargin = 8.0;
  late HandlePainter handlePainter;
  CardPainter() : handlePainter = HandlePainter();

  void draw(Canvas canvas, ca.Card card) {
    //draw card outline
    final Rect rect = Rect.fromLTWH(
      card.offset.dx,
      card.offset.dy,
      card.size.width,
      card.size.height,
    );
    final Paint paint =
        Paint()
          ..color = const Color(0xFF000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawRect(rect, paint);
    //draw handle
    card.handle.offset = card.offset;
    card.handle.size = Size(card.size.width, card.size.height / 3);
    handlePainter.draw(canvas, card.handle);
    //draw text
    final textSpan = TextSpan(
      text: card.text,
      style: TextStyle(
        color: Color(0xFF000000),
        fontSize: card.size.height * 0.15,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      maxLines: null,
    );

    textPainter.layout(maxWidth: card.size.width - (textMargin * 2));

    textPainter.paint(
      canvas,
      card.offset + Offset(textMargin, textMargin + card.handle.size.height),
    );
    //draw trash can if deletable
    if (card.deletable) {
      Offset deleteButton =
          card.offset +
          Offset((card.size.width / 5) * 4, (card.size.height / 5) * 4);
      Size deleteButtonSize = Size(card.size.width / 5, card.size.height / 5);
      card.deleteButton = (deleteButton & deleteButtonSize);
      final IoniconsData icon = Ionicons.close_circle_outline;
      final fontSize = card.size.height * 0.15;
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
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: null,
      );
      iconTextPainter.layout(maxWidth: card.deleteButton.width);
      iconTextPainter.paint(
        canvas,
        card.offset +
            Offset(
              card.size.width - card.deleteButton.width,
              card.size.height - card.deleteButton.height,
            ),
      );
    }
  }
}
