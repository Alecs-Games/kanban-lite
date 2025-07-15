import 'package:flutter/widgets.dart';
import './board.dart';
import './column.dart' as cl;
import 'column_painter.dart';
import 'add_column_button_painter.dart';

//import 'card_painter.dart';

class BoardPainter extends CustomPainter {
  final Board board;
  final ColumnPainter columnPainter;
  final AddColumnButtonPainter addColumnButtonPainter;
  //final ColumnPainter columnPainter;

  BoardPainter(this.board)
    : columnPainter = ColumnPainter(),
      addColumnButtonPainter = AddColumnButtonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    //draw columns left to right
    final int spacing = 20;
    final int columnCount = board.columns.length;
    final double columnWidth = size.width / 6;
    final double columnHeight = size.height;
    double x = 0;
    for (int i = 0; i < columnCount; i++) {
      cl.Column currColumn = board.columns[i];
      currColumn.size = Size(columnWidth, columnHeight);
      currColumn.offset = Offset(x, 0);
      columnPainter.draw(canvas, currColumn);
      x += columnWidth + spacing;
    }
    //draw add column button
    if (board.canAddColumns()) {
      addColumnButtonPainter.draw(
        canvas,
        x,
        Size(columnWidth, columnHeight),
        board.addColumnButton,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
