import 'package:flutter/material.dart';

class BotaoEnviarSolicitacao extends StatelessWidget {
  final String nome;
  final String slogan;
  final String imagemLogo;
  final String endereco;

  const BotaoEnviarSolicitacao({
    super.key,
    required this.nome,
    required this.slogan,
    required this.imagemLogo,
    required this.endereco,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF00B894), Color(0xFF0066A2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/agendar_descarte',
            arguments: {
              'empresa': {
                'nome': nome,
                'slogan': slogan,
                'imagemLogo': imagemLogo,
                'endereco': endereco,
              },
            },
          );
        },
        child: const Center(
          child: Text(
            'Enviar solicitação',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
