import 'package:flutter/widgets.dart';
import 'handle.dart';
import 'column.dart' as cl;

class Card {
  String text;
  String? id; // Firestore document ID
  Size size;
  Offset offset;
  Handle handle;
  Rect deleteButton;
  cl.Column? column;
  bool deletable;

  Card(this.text, {this.id})
    : size = Size.zero,
      offset = Offset.zero,
      handle = Handle(),
      deleteButton = Rect.zero,
      deletable = false;

  factory Card.fromFirestore(String id, Map<String, dynamic> data) {
    return Card(data['text'] ?? '', id: id);
  }
}
