import 'package:flutter/material.dart';
import 'package:yes_no_app/presentation/widgets/chat/my_message_bubble.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  leading: const Padding(
    padding: EdgeInsets.all(4),
    child: CircleAvatar(
      backgroundImage: NetworkImage(
        'https://tse3.mm.bing.net/th/id/OIP.3GwJqMnrOk8uSXwBGpd-KgHaEd?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
      ),
    ),
  ),
  title: const Text('Milky Chance'),
),
      body: const _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.builder(
          itemCount: 100,
          itemBuilder: (context, index) {
            return const MyMessageBubble();
          },
        ),
      ),
    );
  }
}