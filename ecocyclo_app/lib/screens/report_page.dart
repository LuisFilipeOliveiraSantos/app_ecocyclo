import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/discard_report_service.dart';
import '../services/auth_service.dart';

class ReportPageStyled extends StatefulWidget {
  const ReportPageStyled({super.key});

  @override
  State<ReportPageStyled> createState() => _ReportPageStyledState();
}

class _ReportPageStyledState extends State<ReportPageStyled> {
  List<Map<String, dynamic>> _items = [];
  Map<String, int> _monthlyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiscardsData();
  }

  Future<void> _loadDiscardsData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // BUSCAR O ID DA EMPRESA - você precisa implementar isso
      final companyId = await _getCompanyId();
      
      print('🏢 Buscando dados da empresa: $companyId');
      
      // BUSCAR DADOS REAIS DO BACKEND
      final discards = await DiscardReportService.getCompanyDiscards(companyId);
      final processedItems = DiscardReportService.processDiscardsData(discards);
      final monthlyData = DiscardReportService.getLastSixMonthsData(discards);
      
      setState(() {
        _items = processedItems;
        _monthlyData = monthlyData;
        _isLoading = false;
      });
      
      print('✅ Dados carregados: ${_items.length} itens');
      
    } catch (e) {
      print('❌ Erro ao carregar descartes: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Mostrar erro para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar relatórios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

    // ---- MÉTODO PARA PEGAR O COMPANY_ID ----
  Future<String> _getCompanyId() async {
    try {
      final companyId = await AuthService.getCompanyId();
      
      if (companyId.isEmpty) {
        throw Exception('ID da empresa não encontrado. Faça login novamente.');
      }
      
      print('🏢 Company ID encontrado: $companyId');
      return companyId;
      
    } catch (e) {
      print('❌ Erro ao buscar companyId: $e');
      throw Exception('Erro ao carregar dados da empresa: $e');
    }
  }

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
              // ---- TOPO COM TÍTULO ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Relatórios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _loadDiscardsData,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // ---- CONTEÚDO ----
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
                  child: _isLoading
                      ? _buildLoadingIndicator()
                      : _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007C92)),
          ),
          SizedBox(height: 16),
          Text(
            'Carregando relatórios...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF007C92),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum descarte encontrado',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Os descartes aparecerão aqui quando forem realizados',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Itens Descartados",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ..._items.map((e) => _buildItemCard(e)),
          const SizedBox(height: 25),
          _buildBarChartSection(),
          const SizedBox(height: 25),
          _buildPieChartSection(_items),
        ],
      ),
    );
  }

  // ---- CARD DO ITEM ----
  Widget _buildItemCard(Map<String, dynamic> e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: _getRiskBackgroundColor(e['risk']),
          child: Icon(
            e['icon'] ?? Icons.devices_other,
            color: _getRiskIconColor(e['risk']),
          ),
        ),
        title: Text(
          '${e['type']} x${e['quantity']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reciclagem: ${e['recyclingRate']}%',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              e['priceRange'] ?? 'R\$${e['price'].toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: getRiskColor(e['risk']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: getRiskColor(e['risk'])),
              ),
              child: Text(
                e['risk'],
                style: TextStyle(
                  color: getRiskColor(e['risk']),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'R\$${e['price'].toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          _showItemDetails(context, e);
        },
      ),
    );
  }

  // ---- GRÁFICO DE BARRAS ----
  Widget _buildBarChartSection() {
    final monthlyValues = _monthlyData.values.toList();
    
    return Column(
      children: [
        const Text(
          'Descartes do último semestre',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final months = _monthlyData.keys.toList();
                      if (value.toInt() < months.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            _formatMonthLabel(months[value.toInt()]),
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: monthlyValues.asMap().entries.map((entry) {
                return _barGroup(entry.key, entry.value.toDouble());
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ---- GRÁFICO DE PIZZA ----
  Widget _buildPieChartSection(List<Map<String, dynamic>> items) {
    final Map<String, int> counts = {};
    for (var item in items) {
      counts[item['type']] = (counts[item['type']] ?? 0) + (item['quantity'] as int);
    }

    final colors = [
      const Color(0xFF60D39A),
      const Color(0xFF007C92),
      const Color(0xFF004F66),
      const Color(0xFF6FD6E4),
      const Color(0xFFB9E9EF),
    ];

    final total = counts.values.fold<int>(0, (a, b) => a + b);
    
    if (total == 0) {
      return const SizedBox();
    }

    final sections = counts.entries.toList().asMap().entries.map((indexed) {
      final index = indexed.key;
      final entry = indexed.value;
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value.toDouble(),
        title: '${((entry.value / total) * 100).toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 55,
      );
    }).toList();

    return Column(
      children: [
        const Text(
          'Tipos de itens',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 45,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 6,
          children: counts.entries.toList().asMap().entries.map((indexed) {
            final index = indexed.key;
            final entry = indexed.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text('${entry.key} (${entry.value})'),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---- MÉTODOS AUXILIARES ----
  
  void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(item['icon'] ?? Icons.devices_other, color: getRiskColor(item['risk'])),
            const SizedBox(width: 8),
            Text(item['type']),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantidade: ${item['quantity']}'),
            const SizedBox(height: 8),
            Text('Taxa de Reciclagem: ${item['recyclingRate']}%'),
            const SizedBox(height: 8),
            Text('Faixa de Valor: ${item['priceRange']}'),
            const SizedBox(height: 8),
            Text('Nível de Risco: ${item['risk']}'),
            const SizedBox(height: 12),
            Text(
              'Observações:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            Text(
              item['observations'] ?? 'Sem observações adicionais.',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _formatMonthLabel(String monthKey) {
    final parts = monthKey.split('/');
    final month = int.parse(parts[0]);
    const monthAbbr = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return monthAbbr[month - 1];
  }

  BarChartGroupData _barGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF007C92),
          borderRadius: BorderRadius.circular(4),
          width: 16,
        )
      ]
    );
  }

  Color getRiskColor(String risk) {
    switch (risk) {
      case 'Baixo':
        return const Color(0xFF60D39A);
      case 'Médio':
        return const Color(0xFFF6C453);
      case 'Alto':
        return const Color(0xFFE75C5C);
      default:
        return Colors.grey;
    }
  }

  Color _getRiskBackgroundColor(String risk) {
    switch (risk) {
      case 'Alto':
        return const Color(0xFFFFE5E5);
      case 'Médio':
        return const Color(0xFFFFF4E5);
      case 'Baixo':
        return const Color(0xFFE5F7EE);
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getRiskIconColor(String risk) {
    switch (risk) {
      case 'Alto':
        return const Color(0xFFE75C5C);
      case 'Médio':
        return const Color(0xFFF6C453);
      case 'Baixo':
        return const Color(0xFF60D39A);
      default:
        return Colors.grey;
    }
  }
}