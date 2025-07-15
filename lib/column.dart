import './card.dart' as ca;
import './card_painter.dart';
import 'package:flutter/widgets.dart';

class Column {
  static const int capacity = 5;

  String name;
  String? id; // Firestore document ID
  List<ca.Card> cards;
  Size size;
  Offset offset;
  Rect bottomButton;
  Rect namePlate;
  bool _isLastColumn;
  bool isFirstColumn;

  Column(this.cards, this.name, {this.id})
    : size = Size.zero,
      offset = Offset.zero,
      bottomButton = Rect.zero,
      namePlate = Rect.zero,
      _isLastColumn = false,
      isFirstColumn = false;
  bool canAddCards() {
    return (cards.length < capacity);
  }
  //these were used before database integration. Now this info is handled in the stream builder
  /*void addCard(ca.Card card) {
    if (cards.length < capacity) {
      cards.add(card);
      card.column = this;
      card.deletable = _isLastColumn;
    }
  }

  void removeCard(ca.Card card) {
    cards.remove(card);
  }*/

  void setIsLastColumn(bool status) {
    _isLastColumn = status;
    for (ca.Card c in cards) {
      c.deletable = _isLastColumn;
    }
  }

  bool getIsLastColumn() {
    return _isLastColumn;
  }

  factory Column.fromFirestore(
    String id,
    Map<String, dynamic> data,
    List<ca.Card> cards,
  ) {
    return Column(cards, data['name'] ?? 'Untitled', id: id);
  }
}
