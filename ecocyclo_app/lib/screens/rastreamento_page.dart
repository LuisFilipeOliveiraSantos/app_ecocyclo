import 'package:flutter/material.dart';
import '../services/tracking_service.dart';
import '../services/company_service.dart';
import '../services/avaliacao_service.dart';
import 'avaliacao_page.dart'; 

class RastreamentoPage extends StatefulWidget {
  const RastreamentoPage({super.key});

  @override
  State<RastreamentoPage> createState() => _RastreamentoPageState();
}

class _RastreamentoPageState extends State<RastreamentoPage> {
  List<dynamic> _discards = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedTab = 0; // 0 = Em andamento, 1 = Finalizadas
  final Map<String, String> _companyNames = {}; // Cache local de nomes

  @override
  void initState() {
    super.initState();
    _loadDiscards();
  }

  Future<void> _loadDiscards() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final discards = await TrackingService.getDiscardsByCompany();
      
      // Buscar nomes das empresas em paralelo
      await _loadCompanyNames(discards);
      
      setState(() {
        _discards = discards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar descartes: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCompanyNames(List<dynamic> discards) async {
    print('🔄 INICIANDO BUSCA DE NOMES DE EMPRESAS');
    final uniqueCompanyIds = <String>{};
    
    // Coletar IDs únicos de empresas
    for (var discard in discards) {
      final solicitadaId = discard['empresa_solicitada_id']?.toString();
      final solicitanteId = discard['empresa_solicitante_id']?.toString();
      
      print('   Discard ${discard['discard_id']}: solicitada=$solicitadaId, solicitante=$solicitanteId');
      
      if (solicitadaId != null && solicitadaId.isNotEmpty) {
        uniqueCompanyIds.add(solicitadaId);
      }
      if (solicitanteId != null && solicitanteId.isNotEmpty) {
        uniqueCompanyIds.add(solicitanteId);
      }
    }

    print('📋 IDs únicos para buscar: $uniqueCompanyIds');

    // Buscar nomes em paralelo
    await Future.wait(
      uniqueCompanyIds.map((uuid) async {
        try {
          print('🔍 Buscando empresa ID: $uuid');
          final name = await CompanyService.getCompanyName(uuid);
          print('✅ Empresa $uuid: $name');
          _companyNames[uuid] = name;
        } catch (e) {
          print('❌ Erro ao buscar nome da empresa $uuid: $e');
          _companyNames[uuid] = 'Empresa Coletora';
        }
      })
    );
    
    print('🏁 Busca de nomes finalizada. Cache: $_companyNames');
  }

  // Funções auxiliares diretas na classe
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final month = _getMonthName(date.month);
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day de $month - $hour:$minute';
    } catch (e) {
      return 'Data inválida';
    }
  }

  String _getMonthName(int month) {
    final months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return months[month - 1];
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return 'Aguardando match';
      case 'confirmado':
        return 'Aguardando coleta';
      case 'em andamento':
        return 'Em andamento';
      case 'completo':
        return 'Finalizada';
      case 'cancelado':
        return 'Cancelada';
      default:
        return status;
    }
  }

  bool _isInProgress(String status) {
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'pendente' || 
           lowerStatus == 'confirmado' || 
           lowerStatus == 'em andamento';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'confirmado':
        return Colors.blue;
      case 'em andamento':
        return Colors.green;
      case 'completo':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 🔥 MÉTODO ATUALIZADO COM DEBUG: Buscar nome da empresa pelo ID
  String _getEmpresaNome(Map<String, dynamic> discard) {
    // DEBUG: Verificar estrutura do discard
    print('🔍 BUSCANDO NOME DA EMPRESA PARA DESCARTE:');
    print('   discard_id: ${discard['discard_id']}');
    print('   empresa_solicitada_id: ${discard['empresa_solicitada_id']}');
    print('   empresa_solicitante_id: ${discard['empresa_solicitante_id']}');
    print('   _companyNames cache: ${_companyNames.keys}');

    // Tenta pegar o ID da empresa solicitada (coletora)
    final empresaSolicitadaId = discard['empresa_solicitada_id']?.toString();
    
    if (empresaSolicitadaId != null && _companyNames.containsKey(empresaSolicitadaId)) {
      final nome = _companyNames[empresaSolicitadaId]!;
      print('✅ Nome encontrado no cache: $nome');
      return nome;
    }
    
    // Fallback: tenta empresa solicitante
    final empresaSolicitanteId = discard['empresa_solicitante_id']?.toString();
    if (empresaSolicitanteId != null && _companyNames.containsKey(empresaSolicitanteId)) {
      final nome = _companyNames[empresaSolicitanteId]!;
      print('✅ Nome encontrado no cache (solicitante): $nome');
      return nome;
    }
    
    // Se não encontrou no cache, busca imediatamente
    if (empresaSolicitadaId != null) {
      print('🔄 Buscando nome da empresa $empresaSolicitadaId...');
      _loadSingleCompanyName(empresaSolicitadaId);
    } else {
      print('❌ Nenhum ID de empresa encontrado no discard');
    }
    
    return 'Carregando...';
  }

  void _loadSingleCompanyName(String companyId) {
    CompanyService.getCompanyName(companyId).then((name) {
      if (mounted) {
        setState(() {
          _companyNames[companyId] = name;
        });
      }
    });
  }

  List<dynamic> get _inProgressDiscards {
    return _discards.where((discard) => 
      _isInProgress(discard['status'])
    ).toList();
  }

  List<dynamic> get _completedDiscards {
    return _discards.where((discard) => 
      discard['status'].toLowerCase() == 'completo' || 
      discard['status'].toLowerCase() == 'cancelado'
    ).toList();
  }

  Future<void> _cancelDiscard(String discardId) async {
    try {
      await TrackingService.cancelDiscard(discardId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descarte cancelado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDiscards();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cancelar descarte: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDiscard(String discardId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await TrackingService.confirmDiscard(discardId);
      
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coleta finalizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Recarregar a lista para atualizar os status
      _loadDiscards();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao finalizar coleta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCancelDialog(String discardId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Ícone de alerta
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFE75C5C),
                  size: 32,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 🔹 Título com cor escura
              const Text(
                'Cancelar Descarte',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Cor escura para melhor contraste
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // 🔹 Mensagem com cor escura
              const Text(
                'Tem certeza que deseja cancelar este descarte?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54, // Cor mais escura para melhor legibilidade
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // 🔹 Botões de ação
              Row(
                children: [
                  // Botão Não
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF007C92)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Não',
                        style: TextStyle(
                          color: Color(0xFF007C92),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Botão Sim
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE75C5C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _cancelDiscard(discardId);
                      },
                      child: const Text(
                        'Sim, cancelar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(String discardId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone de confirmação
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF4CAF50),
                  size: 32,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Título
              const Text(
                'Finalizar Coleta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Mensagem
              const Text(
                'Tem certeza que deseja finalizar esta coleta?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Botões de ação
              Row(
                children: [
                  // Botão Não
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF007C92)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Não',
                        style: TextStyle(
                          color: Color(0xFF007C92),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Botão Sim
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDiscard(discardId);
                      },
                      child: const Text(
                        'Sim, finalizar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 MÉTODO ATUALIZADO: Agora verifica se já existe avaliação antes de navegar
  void _showRatingDialog(Map<String, dynamic> discard) async {
    try {
      final discardId = discard['discard_id']?.toString();
      if (discardId == null) return;

      setState(() {
        _isLoading = true;
      });

      // Verificar se já existe avaliação para este descarte
      final bool jaAvaliada = await AvaliacaoService.verificarAvaliacaoExistente(discardId);
      
      setState(() {
        _isLoading = false;
      });

      if (jaAvaliada) {
        // ✅ MOSTRAR POPUP DE CONFIRMAÇÃO
        _showAvaliacaoExistenteDialog(discard);
      } else {
        // ✅ Navegar diretamente para criar nova avaliação
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AvaliacaoPage(
              discard: discard,
              isEdicao: false, // Nova avaliação
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao verificar avaliação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ NOVO MÉTODO: Popup para avaliação existente
  void _showAvaliacaoExistenteDialog(Map<String, dynamic> discard) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Ícone de informação
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF1976D2),
                  size: 32,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 🔹 Título
              const Text(
                'Empresa já avaliada',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // 🔹 Mensagem
              const Text(
                'Você já avaliou esta empresa para este descarte. Deseja editar sua avaliação?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // 🔹 Botões de ação
              Row(
                children: [
                  // Botão Não
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFF007C92)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Não',
                        style: TextStyle(
                          color: Color(0xFF007C92),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Botão Sim
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007C92),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        // Navegar para edição da avaliação
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AvaliacaoPage(
                              discard: discard,
                              isEdicao: true, // Modo edição
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Sim, editar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Cabeçalho com gradiente
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00B894), Color(0xFF0066A2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: IconButton(
                      onPressed: () {
                        // Navega para a home (substituindo a pilha de navegação)
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          '/home', // ou a rota da sua home
                          (route) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                  const Text(
                    'Rastreamento',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Tabs Em andamento / Finalizadas - SEGMENT CONTROL COM DEGRADÊ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Tab Em andamento
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = 0;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            gradient: _selectedTab == 0
                                ? const LinearGradient(
                                    colors: [Color(0xFF00B894), Color(0xFF0066A2)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                            color: _selectedTab == 0 ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedTab == 0
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF0066A2).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Em andamento',
                              style: TextStyle(
                                color: _selectedTab == 0 
                                    ? Colors.white 
                                    : Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Tab Finalizadas
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = 1;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            gradient: _selectedTab == 1
                                ? const LinearGradient(
                                    colors: [Color(0xFF00B894), Color(0xFF0066A2)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                            color: _selectedTab == 1 ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedTab == 1
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF0066A2).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Finalizadas',
                              style: TextStyle(
                                color: _selectedTab == 1 
                                    ? Colors.white 
                                    : Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadDiscards,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        )
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final currentDiscards = _selectedTab == 0 ? _inProgressDiscards : _completedDiscards;
    final emptyMessage = _selectedTab == 0 
        ? 'Nenhum descarte em andamento' 
        : 'Nenhum descarte finalizado';

    return currentDiscards.isEmpty
        ? _buildEmptyState(emptyMessage)
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              ...currentDiscards.map((discard) => _buildDiscardCard(discard)),
            ],
          );
  }

  Widget _buildDiscardCard(Map<String, dynamic> discard) {
    final discardId = discard['discard_id'] ?? '';
    final status = discard['status'] ?? '';
    final dataDescarte = discard['data_descarte'] ?? '';
    final localColeta = discard['local_coleta'] ?? '';
    final itensDescarte = discard['itens_descarte'] ?? {};
    final isCompleted = status.toLowerCase() == 'completo';
    final isCanceled = status.toLowerCase() == 'cancelado';
    final isFinished = isCompleted || isCanceled;

    // 🔥 AGORA FUNCIONANDO: Busca o nome real da empresa
    final empresaNome = _getEmpresaNome(discard);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Cabeçalho do card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                empresaNome,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007C92),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 🔹 Data e local
          Text(
            _formatDate(dataDescarte),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            localColeta,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Botões de ação
          Row(
            children: [
              // Botão condicional: Finalizar para coletas "em andamento", Visualizar itens para outras
              if (_isInProgress(status) && status.toLowerCase() != 'em andamento')
                // Botão Finalizar (apenas para coletas com status "em andamento")
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Verde para finalizar
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () {
                      _showConfirmDialog(discardId);
                    },
                    icon: const Icon(Icons.check_circle, color: Colors.white, size: 16),
                    label: const Text(
                      'Finalizar',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                )
              else
                // Botão Visualizar Itens (para outros status)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D61),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () {
                      _showItemsDialog(itensDescarte, discardId);
                    },
                    icon: const Icon(Icons.visibility, color: Colors.white, size: 16),
                    label: const Text(
                      'Visualizar itens',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              
              const SizedBox(width: 8),
              
              // Botões condicionais do lado direito
              if (_isInProgress(status) && status.toLowerCase() != 'em andamento')
                // Botão Cancelar (apenas para coletas em andamento que NÃO estão "em andamento")
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: () {
                      _showCancelDialog(discardId);
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                )
              else if (isFinished)
                // Botão Avaliar (apenas para coletas finalizadas)
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: Color(0xFFD4AF37)), // Dourado
                    ),
                    onPressed: () {
                      _showRatingDialog(discard);
                    },
                    icon: const Icon(Icons.star, color: Color(0xFFD4AF37), size: 16),
                    label: const Text(
                      'Avaliar',
                      style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showItemsDialog(Map<String, dynamic> itensDescarte, String discardId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Itens do Descarte',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF007C92),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              const Divider(color: Colors.grey, height: 1),
              const SizedBox(height: 16),

              // 🔹 Lista de itens
              if (itensDescarte.isEmpty)
                const Center(
                  child: Text(
                    'Nenhum item encontrado',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: itensDescarte.entries.length,
                    itemBuilder: (context, index) {
                      final entry = itensDescarte.entries.elementAt(index);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE9F9F5),
                            radius: 22,
                            child: _getItemIcon(entry.key),
                          ),
                          title: Text(
                            (entry.key),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  size: 14,
                                  color: const Color(0xFF007C92),
                                ),
                                const SizedBox(width: 4),
                              ],
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007C92).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'x${entry.value}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color:  Color(0xFF007C92),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              // 🔹 Botão Fechar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D61),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  // 🔥 MÉTODO AUXILIAR: Obter ícone baseado no tipo de item
  Widget _getItemIcon(String itemName) {
    final lowerName = itemName.toLowerCase();
    
    if (lowerName.contains('laptop') || lowerName.contains('notebook')) {
      return const Icon(Icons.laptop, color: Color(0xFF0066A2));
    } else if (lowerName.contains('celular') || lowerName.contains('phone')) {
      return const Icon(Icons.phone_iphone, color: Color(0xFF0066A2));
    } else if (lowerName.contains('tablet')) {
      return const Icon(Icons.tablet, color: Color(0xFF0066A2));
    } else if (lowerName.contains('monitor')) {
      return const Icon(Icons.monitor, color: Color(0xFF0066A2));
    } else if (lowerName.contains('teclado')) {
      return const Icon(Icons.keyboard, color: Color(0xFF0066A2));
    } else if (lowerName.contains('mouse')) {
      return const Icon(Icons.mouse, color: Color(0xFF0066A2));
    } else if (lowerName.contains('headset')) {
      return const Icon(Icons.headset, color: Color(0xFF0066A2));
    } else if (lowerName.contains('cpu')) {
      return const Icon(Icons.computer, color: Color(0xFF0066A2));
    } else if (lowerName.contains('placa') || lowerName.contains('motherboard')) {
      return const Icon(Icons.memory, color: Color(0xFF0066A2));
    } else if (lowerName.contains('controle') || lowerName.contains('remote')) {
      return const Icon(Icons.gamepad, color: Color(0xFF0066A2));
    } else {
      return const Icon(Icons.devices_other, color: Color(0xFF0066A2));
    }
  }
}