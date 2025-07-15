import 'package:flutter/material.dart';

class Prompt extends StatelessWidget {
  final String label;
  final String initialText;
  final void Function(String) onSubmitted;

  const Prompt({
    super.key,
    required this.label,
    required this.initialText,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialText);
    final focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
      focusNode.requestFocus();
    });
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.black),
        child: Theme(
          data: ThemeData(
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: Colors.black,
              selectionHandleColor: Colors.black,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(color: Colors.white),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: EditableText(
                  controller: controller,
                  focusNode: focusNode,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  cursorColor: Colors.black,
                  backgroundCursorColor: Colors.black,
                  autofocus: true,
                  selectionColor: Colors.grey,
                  onSubmitted: onSubmitted,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => onSubmitted(controller.text),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(color: Colors.white),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
