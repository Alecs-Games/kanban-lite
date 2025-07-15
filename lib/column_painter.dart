import 'package:flutter/widgets.dart';
import './card.dart' as ca;
import './card_painter.dart';
import './column.dart' as cl;
import 'package:ionicons/ionicons.dart';

class ColumnPainter {
  late CardPainter cardPainter;

  ColumnPainter() : cardPainter = CardPainter();

  void draw(Canvas canvas, cl.Column column) {
    //draw column outline
    final Rect rect = Rect.fromLTWH(
      column.offset.dx,
      0,
      column.size.width,
      column.size.height,
    );
    final Paint paint =
        Paint()
          ..color = const Color(0xFF000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawRect(rect, paint);
    final double nameSize = column.size.height / 15;
    final double bottomButtonHeight = column.size.height / 10;
    final double cardSpacing = column.size.width / 10;
    final double cardMargin = column.size.width / 10;
    final Size cardSize = Size(
      column.size.width - (cardMargin * 2),
      ((column.size.height -
                  bottomButtonHeight -
                  (cardSpacing * 2) -
                  nameSize) /
              cl.Column.capacity) -
          cardSpacing,
    );
    //draw name box
    column.namePlate = Rect.fromLTWH(
      column.offset.dx,
      0,
      column.size.width,
      nameSize,
    );
    canvas.drawRect(column.namePlate, paint);
    //draw name text
    final double textMargin = 0;
    final textSpan = TextSpan(
      text: column.name,
      style: TextStyle(
        color: Color(0xFF000000),
        fontSize: column.size.height * 0.02,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      maxLines: null,
    );

    textPainter.layout(maxWidth: column.size.width - (textMargin * 2));

    textPainter.paint(
      canvas,
      Offset(
        column.namePlate.left +
            ((column.namePlate.width - textPainter.width) / 2),
        column.namePlate.top +
            ((column.namePlate.height - textPainter.height) / 2),
      ),
    );
    //draw cards top to bottom
    double y = column.offset.dy + cardSpacing + nameSize;
    for (int i = 0; i < column.cards.length; i++) {
      ca.Card currentCard = column.cards[i];
      if (!currentCard.handle.isHeld) {
        currentCard.offset = Offset(column.offset.dx + cardMargin, y);
      }
      y += (cardSize.height + cardSpacing);
      currentCard.size = cardSize;
      cardPainter.draw(canvas, currentCard);
    }
    //draw bottom button
    column.bottomButton = Rect.fromLTWH(
      column.offset.dx,
      column.size.height - (bottomButtonHeight),
      column.size.width,
      bottomButtonHeight,
    );
    canvas.drawRect(column.bottomButton, paint);
    //draw new card symbol if first column, otherwise draw trashcan
    IoniconsData icon = Ionicons.trash_bin_outline;
    if (column.isFirstColumn) {
      icon = Ionicons.document_text_outline;
    }
    final double fontSize = column.size.height / 20;
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
    iconTextPainter.layout(
      maxWidth: column.size.width,
      minWidth: column.size.width,
    );
    iconTextPainter.paint(
      canvas,
      Offset(
        column.bottomButton.left,
        column.bottomButton.top + (column.bottomButton.height / 4),
      ),
    );
  }
}
