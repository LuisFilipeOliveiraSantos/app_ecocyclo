class ConfirmacaoService {
  
  /// Converte data e hora strings para DateTime no formato ISO
  static DateTime combinarDataHora(String data, String hora) {
    try {
      // Validar se os dados não são nulos ou vazios
      if (data.isEmpty || hora.isEmpty) {
        throw Exception('Data ou hora não fornecidas');
      }
      
      // Extrair a parte da data (YYYY-MM-DD)
      final dataPart = data.split(' ')[0];
      
      // Validar formato da hora (deve ser HH:mm)
      if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(hora)) {
        throw Exception('Formato de hora inválido. Use HH:mm');
      }
      
      // Combinar data e hora
      final dataHoraString = '${dataPart}T$hora:00.000Z';
      
      // Tentar fazer o parse
      final resultado = DateTime.parse(dataHoraString);
      
      // Validar se a data não é no passado
      if (resultado.isBefore(DateTime.now())) {
        throw Exception('Não é possível agendar para datas passadas');
      }
      
      return resultado;
      
    } catch (e) {
      print('Erro ao converter data/hora: $e');
      rethrow;
    }
  }
}