import 'package:flutter/material.dart';

class MessageFieldBox extends StatefulWidget {
  final ValueChanged<String> onValue;

  const MessageFieldBox({
    super.key,
    required this.onValue,
  });

  @override
  State<MessageFieldBox> createState() => _MessageFieldBoxState();
}

class _MessageFieldBoxState extends State<MessageFieldBox> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  void _sendMessage() {
    final text = _textController.text.trim();

    if (text.isEmpty) return;

    _textController.clear();
    _focusNode.requestFocus();
    widget.onValue(text);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(40),
    );

    return TextFormField(
      controller: _textController,
      focusNode: _focusNode,
      textInputAction: TextInputAction.send,
      onTapOutside: (_) => _focusNode.unfocus(),
      onFieldSubmitted: (_) => _sendMessage(),
      decoration: InputDecoration(
        hintText: 'Termina tu pregunta con "?"',
        enabledBorder: border,
        focusedBorder: border,
        filled: true,
        suffixIcon: IconButton(
          onPressed: _sendMessage,
          icon: const Icon(Icons.send_outlined),
        ),
      ),
    );
  }
}