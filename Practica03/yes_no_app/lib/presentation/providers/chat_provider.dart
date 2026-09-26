import 'package:flutter/material.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
  final chatScrollController = ScrollController();
  final getYesNoAnswer = GetYesNoAnswer();

  bool _disposed = false;

  final List<Message> messageList = [
    Message(
      text: '¡Hola, Milky chance!',
      fromWho: FromWho.me,
      status: MessageStatus.read,
    ),
    Message(
      text: '¿Todo bien?',
      fromWho: FromWho.me,
      status: MessageStatus.read,
    ),
  ];

  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();

    if (cleanText.isEmpty || _disposed) return;

    final newMessage = Message(
      text: cleanText,
      fromWho: FromWho.me,
    );

    messageList.add(newMessage);
    notifyListeners();
    moveScrollToBottom();

    // Simulación: entregado después de 400 milisegundos.
    await Future<void>.delayed(
      const Duration(milliseconds: 400),
    );

    if (_disposed) return;

    newMessage.status = MessageStatus.delivered;
    notifyListeners();

    // Simulación: visto 700 milisegundos después.
    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    if (_disposed) return;

    newMessage.status = MessageStatus.read;
    notifyListeners();

    if (cleanText.endsWith('?')) {
      await herReply();
    }
  }

  Future<void> herReply() async {
    if (_disposed) return;

    final herMessage = await getYesNoAnswer.getAnswer();

    if (_disposed) return;

    messageList.add(herMessage);
    notifyListeners();
    moveScrollToBottom();
  }

  Future<void> moveScrollToBottom() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 100),
    );

    if (_disposed || !chatScrollController.hasClients) return;

    await chatScrollController.animateTo(
      chatScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    getYesNoAnswer.dispose();
    chatScrollController.dispose();
    super.dispose();
  }
}