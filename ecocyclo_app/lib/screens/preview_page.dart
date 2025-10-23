import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/agendar/botao_voltar_padrao.dart';
import '../services/analyze_service.dart'; 

class PreviewPage extends StatelessWidget {
  final String imagePath;

  const PreviewPage({super.key, required this.imagePath});



  /// 👉 Nova função: envia a imagem ao backend e mostra o resultado
  Future<void> enviarImagemParaAnalise(BuildContext context) async {
    try {
      // Mostra indicador de carregamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Lê os bytes da imagem
      final bytes = await File(imagePath).readAsBytes();
      final fileName = imagePath.split('/').last;

      // Chama o service
      final result = await AnalyzeService.analyzeImage(bytes, fileName);

      // Fecha o indicador de carregamento
      Navigator.of(context).pop();

      // Mostra a resposta em um pop-up
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Resultado da Análise"),
          content: Text(result),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      // Fecha o indicador de carregamento se ainda estiver aberto
      Navigator.of(context, rootNavigator: true).pop();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Erro"),
          content: Text("Falha ao enviar imagem: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fechar"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Image.file(File(imagePath)),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Row(
                children: [
                  BotaoVoltarPadrao(onPressed: () => Navigator.pop(context)),
                  const Expanded(
                    child: Text(
                      'Pré-visualização',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  // 🔹 Troca o botão para enviar pro backend
                  onPressed: () => enviarImagemParaAnalise(context),
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
