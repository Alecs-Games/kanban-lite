import 'package:kanban_lite/add_column_button.dart';

import 'column.dart';

class Board {
  List<Column> columns;
  static final int maxColumns = 5;
  final AddColumnButton addColumnButton;
  Board(this.columns) : addColumnButton = AddColumnButton() {
    columns[columns.length - 1].setIsLastColumn(true);
    columns[0].isFirstColumn = true;
  }
  bool canAddColumns() {
    return ((columns.length < maxColumns));
  }
  //these are relics from before adding database. now this data is updated in buildLoop.
  /*void addColumn(Column c) {
    if (columns.length < maxColumns) {
      columns.last.setIsLastColumn(false);
      columns.add(c);
      c.setIsLastColumn(true);
      canAddColumns = (columns.length < maxColumns);
    }
  }

  void removeColumn(Column c) {
    columns.remove(c);
    canAddColumns = (columns.length < maxColumns);
    columns.last.setIsLastColumn(true);
  }*/

  void updateButtons() {
    columns.first.isFirstColumn = true;
    for (int i = 1; i < (columns.length - 1); i++) {
      columns[i].setIsLastColumn(false);
      columns[i].isFirstColumn = false;
    }
    columns.last.setIsLastColumn(true);
  }
}
