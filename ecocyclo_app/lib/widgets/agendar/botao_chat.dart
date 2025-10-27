import 'package:flutter/material.dart';

class BotaoChat extends StatelessWidget {
  const BotaoChat({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.black26,
      child: IconButton(
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: Color(0xFF0066A2)),
                  SizedBox(width: 8),
                  Text(
                    'Chat',
                    style: TextStyle(
                      color: Color(0xFF0066A2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Função de chat em desenvolvimento.\n'
                'Em breve você poderá conversar diretamente com a empresa.',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0066A2),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}