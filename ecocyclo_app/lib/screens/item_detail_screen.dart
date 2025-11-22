import 'package:flutter/material.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007C92), Color(0xFF003E4F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Cabeçalho
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['type'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Conteúdo
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cabeçalho com notebook
                        _buildNotebookHeader(),
                        const SizedBox(height: 24),
                        
                        // Taxa de reaproveitamento
                        _buildReuseRateCard(),
                        const SizedBox(height: 20),
                        
                        // Receita estimada
                        _buildRevenueCard(),
                        const SizedBox(height: 20),
                        
                        // Classificação de risco
                        _buildRiskClassification(),
                        const SizedBox(height: 20),
                        
                        // Observações
                        _buildObservations(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotebookHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007C92), Color(0xFF003E4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007C92).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Relatório do Produto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Analisamos as condições e preparamos tudo que você precisa saber para tomar a melhor decisão de descarte ou reaproveitamento.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReuseRateCard() {
    final reuseRate = (item['recyclingRate'] ?? 70.0).toInt();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE9F9F5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F9F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.recycling,
                  color: Color(0xFF007C92),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Taxa de Reaproveitamento',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF60D39A), Color(0xFF007C92)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF60D39A).withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$reuseRate%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _getReuseRateDescription(reuseRate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    final price = (item['price'] ?? 0.0).toDouble();
    final priceRange = item['priceRange'] ?? 'R\$${price.toStringAsFixed(2)}';
    final quantity = (item['quantity'] ?? 1).toInt();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE9F9F5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F9F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Color(0xFF007C92),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Receita Estimada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF007C92),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.currency_exchange,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'R\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007C92),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Faixa por unidade: $priceRange',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (quantity > 1) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F9F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2,
                    color: const Color(0xFF007C92),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Total para $quantity unidades',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF007C92),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskClassification() {
    final riskLevel = item['risk'] ?? 'Médio';
    
    Color riskColor;
    Color backgroundColor;
    IconData riskIcon;
    String riskDescription;
    
    switch (riskLevel.toString().toLowerCase()) {
      case 'alto':
        riskColor = const Color(0xFFE75C5C);
        backgroundColor = const Color(0xFFFDECEC);
        riskIcon = Icons.warning_amber_rounded;
        riskDescription = 'Requer cuidados especiais no descarte e manipulação profissional';
        break;
      case 'médio':
        riskColor = const Color(0xFFF6C453);
        backgroundColor = const Color(0xFFFEF6E6);
        riskIcon = Icons.info_outline;
        riskDescription = 'Alguns componentes requerem atenção especial durante o descarte';
        break;
      case 'baixo':
        riskColor = const Color(0xFF60D39A);
        backgroundColor = const Color(0xFFE9F9F5);
        riskIcon = Icons.check_circle_outline;
        riskDescription = 'Baixo impacto ambiental, pode ser descartado em pontos comuns';
        break;
      default:
        riskColor = const Color(0xFFF6C453);
        backgroundColor = const Color(0xFFFEF6E6);
        riskIcon = Icons.help_outline;
        riskDescription = 'Avaliação de risco em andamento';
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: riskColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: riskColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  riskIcon,
                  color: riskColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Classificação de Risco',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: riskColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      riskIcon,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      riskLevel.toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            riskDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservations() {
    final observations = item['observations'] ?? 'Sem observações adicionais.';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE9F9F5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F9F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description,
                  color: Color(0xFF007C92),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Análise Detalhada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildObservationItem('📱 Composição', _getCompositionDescription(item['type'])),
          const SizedBox(height: 16),
          _buildObservationItem('♻️ Potencial de Recuperação', _getRecoveryPotential((item['recyclingRate'] ?? 70.0).toInt())),
          const SizedBox(height: 16),
          _buildObservationItem('💡 Recomendações', _getRecommendations(item['risk'])),
          const SizedBox(height: 16),
          _buildObservationItem('📝 Observações Técnicas', observations),
        ],
      ),
    );
  }

  Widget _buildObservationItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2, right: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF007C92).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.circle,
            color: const Color(0xFF007C92),
            size: 8,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getReuseRateDescription(int rate) {
    if (rate >= 80) {
      return 'Excelente potencial de reaproveitamento! A maioria dos componentes pode ser recuperada e reutilizada.';
    } else if (rate >= 60) {
      return 'Bom potencial de reaproveitamento. Componentes principais podem ser recuperados com valor significativo.';
    } else if (rate >= 40) {
      return 'Potencial moderado de reaproveitamento. Alguns componentes específicos têm valor recuperável.';
    } else {
      return 'Potencial limitado de reaproveitamento. Foco no descarte ambientalmente adequado dos materiais.';
    }
  }

  String _getCompositionDescription(String itemType) {
    final compositions = {
      'Laptop': 'Contém cobre, alumínio, ouro, prata, platina e outros metais nobres em placas de circuito, processadores e componentes eletrônicos.',
      'Celular': 'Baterias de lítio-ion, placas com metais preciosos (ouro, prata, paládio), tela de vidro, plásticos e metais não ferrosos.',
      'Tablet': 'Similar ao celular, com maior área de tela, bateria de maior capacidade e componentes eletrônicos diversificados.',
      'Monitor': 'Vidro da tela, metais estruturais (aço, alumínio), placas eletrônicas, cabos de cobre e componentes de iluminação LED.',
      'Teclado': 'Plástico ABS, circuitos flexíveis, membranas de silicone, pequenas quantidades de metal e componentes eletrônicos simples.',
      'Mouse': 'Plástico, sensor óptico/laser, fios de cobre, micro switches e rodinha de scroll.',
      'Headset': 'Plástico, ímãs de neodímio, drivers de áudio, cabos com fios de cobre e espuma das almofadas.',
      'CPU': 'Metais estruturais (aço, alumínio), ventilador, dissipador de calor, processador e conectores diversos.',
      'Placa-mãe': 'Alta concentração de metais preciosos (ouro, prata, paládio), cobre, estanho e outros componentes eletrônicos.',
      'Controle Remoto': 'Plástico, circuitos impressos simples, botões de borracha, LED infravermelho e bateria.',
    };
    
    return compositions[itemType] ?? 'Composição variada de metais, plásticos, componentes eletrônicos e materiais diversos.';
  }

  String _getRecoveryPotential(int recyclingRate) {
    if (recyclingRate >= 80) {
      return 'Alto valor recuperável. Componentes principais têm excelente taxa de reutilização e podem ser reinseridos na cadeia produtiva.';
    } else if (recyclingRate >= 60) {
      return 'Valor recuperável significativo. Partes essenciais podem ser reaproveitadas ou recicladas com boa eficiência.';
    } else if (recyclingRate >= 40) {
      return 'Valor recuperável moderado. Alguns componentes específicos têm aplicação secundária ou valor de reciclagem.';
    } else {
      return 'Valor recuperável limitado. Foco na reciclagem de materiais básicos e descarte ambientalmente correto.';
    }
  }

  String _getRecommendations(String risk) {
    switch (risk.toLowerCase()) {
      case 'alto':
        return 'Encaminhar obrigatoriamente para centro de reciclagem especializado. Requer manipulação profissional devido à presença de componentes perigosos. Documentação específica necessária.';
      case 'médio':
        return 'Separar componentes perigosos antes do descarte. Pode ser processado em centros autorizados. Recomenda-se triagem prévia dos materiais.';
      case 'baixo':
        return 'Pode ser descartado em pontos de coleta comuns de eletrônicos. Baixo impacto ambiental. Seguir orientações locais de descarte.';
      default:
        return 'Consultar especialista para orientação específica de descarte. Avaliação técnica recomendada para definição do procedimento adequado.';
    }
  }
}