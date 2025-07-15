import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './board_painter.dart';
import './column.dart' as cl;
import './card.dart' as ca;
import './firebase_options.dart';
import './prompt.dart';
import './firestore_service.dart';
import './board.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(home: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final FirestoreService firestore = FirestoreService();
  final String boardId = "Q52pczSmq5kZdJTDGM3q";

  ca.Card? heldCard;
  Offset dragOffset = Offset.zero;
  bool interfaceEnabled = true;
  OverlayEntry? promptOverlay;

  void showTextPrompt({
    required String label,
    required String initialText,
    required void Function(String) onSubmitted,
  }) {
    final overlay = Overlay.of(context);
    interfaceEnabled = false;
    promptOverlay = OverlayEntry(
      builder:
          (context) => Material(
            color: Colors.transparent,
            child: Prompt(
              label: label,
              initialText: initialText,
              onSubmitted: (value) {
                onSubmitted(value);
                interfaceEnabled = true;
                promptOverlay?.remove();
                promptOverlay = null;
              },
            ),
          ),
    );
    overlay.insert(promptOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<cl.Column>>(
      stream: firestore.watchBoard(boardId),
      //get data from firebase and update local variables for rendering to match
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final columns = snapshot.data!;

        for (int i = 0; i < columns.length; i++) {
          final column = columns[i];
          column.isFirstColumn = (i == 0);
          column.setIsLastColumn(i == columns.length - 1);

          for (final card in column.cards) {
            card.column = column;
            card.deletable = column.getIsLastColumn();

            //restore heldCard based on its id
            if (heldCard != null && card.id == heldCard!.id) {
              card.offset = heldCard!.offset;
              card.handle = heldCard!.handle;
              card.handle.isHeld = true;
              heldCard = card;
            }
          }
        }

        final board = Board(columns);
        //basic app layout and gesture detector
        return LayoutBuilder(
          builder: (context, constraints) {
            final boardWidth = constraints.maxWidth * 0.95;
            final boardHeight = constraints.maxHeight * 0.95;

            return Center(
              child: IgnorePointer(
                ignoring: !interfaceEnabled,
                child: Listener(
                  onPointerDown:
                      (details) => onTouch(details.localPosition, board),
                  onPointerUp:
                      (details) => onRelease(details.localPosition, board),
                  onPointerMove: (details) => onMove(details.localPosition),
                  child: SizedBox(
                    width: boardWidth,
                    height: boardHeight,
                    child: CustomPaint(painter: BoardPainter(board)),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void onTouch(Offset position, Board board) {
    //check add column button
    if (board.canAddColumns() &&
        board.addColumnButton.rect.contains(position)) {
      showTextPrompt(
        label: "Add Column",
        initialText: "Step ${board.columns.length + 1}",
        onSubmitted: (value) {
          firestore.addColumn(boardId, value);
        },
      );
    }
    //check rename column button
    for (cl.Column column in board.columns) {
      if (column.namePlate.contains(position)) {
        showTextPrompt(
          label: "Rename Column",
          initialText: column.name,
          onSubmitted: (value) {
            if (column.id != null) {
              firestore.renameColumn(boardId, column.id!, value);
            }
          },
        );
      }
      //check card handles
      for (ca.Card card in column.cards) {
        if (card.handle.contains(position)) {
          setState(() {
            if (heldCard != null) heldCard!.handle.isHeld = false;
            dragOffset = card.offset - position;
            card.handle.isHeld = true;
            heldCard = card;
          });
          return;
        } else {
          //check card delete button
          if (card.deletable && card.deleteButton.contains(position)) {
            if (card.column?.id != null && card.id != null) {
              setState(() {
                firestore.deleteCard(boardId, card.column!.id!, card.id!);
              });
            }
          } else {
            //anywhere on the card except handle or delete button will rename
            Rect cardRect = (card.offset & card.size);
            if (cardRect.contains(position)) {
              showTextPrompt(
                label: "Rename Card",
                initialText: card.text,
                onSubmitted: (value) {
                  if (card.id != null && card.column?.id != null) {
                    setState(() {
                      firestore.renameCard(
                        boardId,
                        card.column!.id!,
                        card.id!,
                        value,
                      );
                    });
                  }
                },
              );
            }
          }
        }
      }

      if (column.bottomButton.contains(position)) {
        //if it is the first column, the bottom button should be an add card symbol
        if (column.isFirstColumn) {
          if (column.canAddCards()) {
            showTextPrompt(
              label: "Add Card",
              initialText: "",
              onSubmitted: (value) {
                if (column.id != null) {
                  setState(() {
                    firestore.addCard(boardId, column.id!, value);
                  });
                }
              },
            );
          }
        } else {
          //if it is not the first column whose bottom button was clicked on, delete the column.
          if (column.id != null) {
            firestore.deleteColumn(boardId, column.id!);
          }
        }
      }
    }
  }

  void onRelease(Offset position, Board board) {
    if (heldCard != null) {
      cl.Column? dropColumn = hoveredColumn(position, board);
      //if card was dropped on a valid column, move it there
      if (dropColumn != null &&
          dropColumn.id != null &&
          heldCard!.column?.id != null &&
          heldCard!.id != null &&
          dropColumn.canAddCards()) {
        final fromColId = heldCard!.column!.id!;
        final toColId = dropColumn.id!;
        final card = heldCard!;

        firestore.moveCard(boardId, fromColId, toColId, card).then((_) {
          dropHeldCard();
        });
      } else {
        //card was set nowhere, send it back to its column visually
        dropHeldCard();
      }
    }
  }

  //helper function to remove held card data
  void dropHeldCard() {
    setState(() {
      heldCard!.handle.isHeld = false;
      heldCard = null;
      dragOffset = Offset.zero;
    });
  }

  //make held card follow pointer
  void onMove(Offset position) {
    if (heldCard != null) {
      setState(() {
        heldCard!.offset = position + dragOffset;
        heldCard!.handle.offset = position;
      });
    }
  }

  //tell if a column is being hovered over
  cl.Column? hoveredColumn(Offset position, Board board) {
    for (final column in board.columns) {
      final columnRect = (column.offset & column.size);
      if (columnRect.contains(position)) {
        return column;
      }
    }
    return null;
  }
}
