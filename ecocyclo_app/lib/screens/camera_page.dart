import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import '../widgets/agendar/botao_voltar_padrao.dart';
import 'preview_page.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraAwesomeBuilder.awesome(
            saveConfig: SaveConfig.photo(),
            onMediaCaptureEvent: (event) async {
              if (event.status == MediaCaptureStatus.success && event.isPicture) {
                await event.captureRequest.when(
                  single: (single) async {
                    final file = single.file;
                    if (file != null) {
                      // Abre a tela de pré-visualização
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PreviewPage(imagePath: file.path),
                        ),
                      );
                    }
                  },
                );
              }
            },
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 90,
              padding: const EdgeInsets.only(top: 40, left: 12, right: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00796B), Color(0xFF0288D1)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  BotaoVoltarPadrao(onPressed: () => Navigator.pop(context)),
                  const Expanded(
                    child: Text(
                      "Realizar descarte",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Opacity(
                    opacity: 0,
                    child: Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}