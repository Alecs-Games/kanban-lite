import 'package:cloud_firestore/cloud_firestore.dart';
import 'card.dart' as ca;
import 'column.dart' as cl;

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream that constantly updates when database is changed
  Stream<List<cl.Column>> watchBoard(String boardId) {
    return _firestore
        .collection('boards')
        .doc(boardId)
        .collection('columns')
        .orderBy('index')
        .snapshots()
        .asyncMap((colSnapshot) async {
          print('[Firestore] Fetched ${colSnapshot.docs.length} columns');

          final columns = await Future.wait(
            colSnapshot.docs.map((colDoc) async {
              final colData = colDoc.data();
              final colId = colDoc.id;

              final cardsSnapshot =
                  await colDoc.reference.collection('cards').get();
              final cards =
                  cardsSnapshot.docs.map((cardDoc) {
                    final card = ca.Card.fromFirestore(
                      cardDoc.id,
                      cardDoc.data(),
                    );
                    print('   ↳ Card "${card.id}" = "${card.text}"');
                    return card;
                  }).toList();

              final column = cl.Column.fromFirestore(colId, colData, cards);
              print('→ Column "${column.name}" (ID: ${column.id})');
              return column;
            }),
          );

          return columns;
        });
  }

  Future<void> addColumn(String boardId, String name) async {
    final colRef = _firestore
        .collection('boards')
        .doc(boardId)
        .collection('columns');
    final snapshot = await colRef.get();
    final index = snapshot.docs.length;

    await colRef.add({'name': name, 'index': index});
  }

  Future<void> addCard(String boardId, String columnId, String text) async {
    await _firestore
        .collection('boards')
        .doc(boardId)
        .collection('columns')
        .doc(columnId)
        .collection('cards')
        .add({'text': text});
  }

  Future<void> renameColumn(
    String boardId,
    String columnId,
    String newName,
  ) async {
    await _firestore
        .collection('boards')
        .doc(boardId)
        .collection('columns')
        .doc(columnId)
        .update({'name': newName});
  }

  Future<void> renameCard(
    String boardId,
    String columnId,
    String cardId,
    String newText,
  ) async {
    await _firestore
        .collection('boards')
        .doc(boardId)
        .collection('columns')
        .doc(columnId)
        .collection('cards')
        .doc(cardId)
        .update({'text': newText});
  }

  Future<void> deleteCard(
    String boardId,
    String columnId,
    String cardId,
  ) async {
    final docRef = _firestore
        .collection('boards')
        .doc(boardId)
        .collection('columns')
        .doc(columnId)
        .collection('cards')
        .doc(cardId);

    await docRef.delete();
  }

  Future<void> deleteColumn(String boardId, String columnId) async {
    final cardsRef = _firestore
        .collection('boards')
        .doc(boardId)
        .collection('columns')
        .doc(columnId)
        .collection('cards');

    final cards = await cardsRef.get();
    //attempt to cleanup all cards in the column
    for (final doc in cards.docs) {
      await doc.reference.delete();
    }

    await _firestore
        .collection('boards')
        .doc(boardId)
        .collection('columns')
        .doc(columnId)
        .delete();
  }

  Future<void> moveCard(
    String boardId,
    String fromColId,
    String toColId,
    ca.Card card,
  ) async {
    await deleteCard(boardId, fromColId, card.id!);
    await addCard(boardId, toColId, card.text);
  }
}
