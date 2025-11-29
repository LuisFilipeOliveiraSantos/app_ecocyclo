import 'package:flutter/material.dart';
import '../services/avaliacao_service.dart';
import '../services/company_service.dart';
import '../services/auth_service.dart';

class AvaliacaoPage extends StatefulWidget {
  final Map<String, dynamic> discard;
  final bool isEdicao; // ✅ NOVO PARÂMETRO
  
  const AvaliacaoPage({
    super.key, 
    required this.discard,
    this.isEdicao = false, // Padrão é false (nova avaliação)
  });

  @override
  State<AvaliacaoPage> createState() => _AvaliacaoPageState();
}

class _AvaliacaoPageState extends State<AvaliacaoPage> {
  int _rating = 0;
  final TextEditingController _comentarioController = TextEditingController();
  bool _isLoading = false;
  String _empresaNome = 'Carregando...';
  String? _empresaFoto;
  String? _minhaCompanyId;
  String? _avaliacaoExistenteUuid; // ✅ NOVO: UUID da avaliação existente

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Carrega o ID da minha empresa
      _minhaCompanyId = await AuthService.getCompanyId();
      
      // Carrega dados da empresa avaliada
      final empresaSolicitadaId = widget.discard['empresa_solicitada_id']?.toString();
      if (empresaSolicitadaId != null) {
        final dadosEmpresa = await CompanyService.getCompanyData(empresaSolicitadaId);
        setState(() {
          _empresaNome = dadosEmpresa['nome'] ?? 'Empresa Coletora';
          _empresaFoto = dadosEmpresa['company_photo_url']?.toString();
        });
      }

      // ✅ SE FOR EDIÇÃO, CARREGAR DADOS EXISTENTES
      if (widget.isEdicao) {
        await _carregarAvaliacaoExistente();
      }
    } catch (e) {
      setState(() {
        _empresaNome = 'Empresa Coletora';
      });
    }
  }

  // ✅ NOVO MÉTODO: Carregar avaliação existente
  Future<void> _carregarAvaliacaoExistente() async {
    try {
      final discardId = widget.discard['discard_id']?.toString();
      if (discardId == null) return;

      final avaliacaoExistente = await AvaliacaoService.buscarAvaliacaoPorDiscard(discardId);
      
      if (avaliacaoExistente != null) {
        setState(() {
          _avaliacaoExistenteUuid = avaliacaoExistente['uuid'];
          _rating = avaliacaoExistente['score'] ?? 0;
          _comentarioController.text = avaliacaoExistente['comment'] ?? '';
        });
      }
    } catch (e) {
      print('Erro ao carregar avaliação existente: $e');
    }
  }

  // 🔹 MÉTODO PARA DEFINIR O TEXTO DO STATUS
  String _getStatusText() {
    final status = widget.discard['status']?.toString().toLowerCase() ?? '';
    
    switch (status) {
      case 'completo':
        return 'Coleta realizada';
      case 'cancelado':
        return 'Coleta cancelada';
      default:
        return 'Coleta';
    }
  }

  // 🔹 MÉTODO PARA DEFINIR A COR DO STATUS
  Color _getStatusColor() {
    final status = widget.discard['status']?.toString().toLowerCase() ?? '';
    
    switch (status) {
      case 'completo':
        return const Color(0xFF60D39A); // Verde para realizado
      case 'cancelado':
        return const Color(0xFFE75C5C); // Vermelho para cancelado
      default:
        return const Color(0xFF007C92); // Azul padrão
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isEdicao ? 'Editar Avaliação' : 'Avaliar Coleta', // ✅ Título dinâmico
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00B894), Color(0xFF0066A2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Cabeçalho - COM STATUS DINÂMICO
                  _buildCabecalho(),
                  
                  const SizedBox(height: 32),
                  
                  // 🔹 Avaliação com estrelas
                  _buildAvaliacaoEstrelas(),
                  
                  const SizedBox(height: 32),
                  
                  // 🔹 Campo de comentário
                  _buildCampoComentario(),
                  
                  const SizedBox(height: 40),
                  
                  // 🔹 Botão enviar COM DEGRADÊ
                  _buildBotaoEnviar(),
                ],
              ),
            ),
    );
  }

  Widget _buildCabecalho() {
    final statusText = _getStatusText();
    final statusColor = _getStatusColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          if (_empresaFoto != null)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: NetworkImage(_empresaFoto!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF007C92),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.business, color: Colors.white, size: 24),
            ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Nome da empresa como destaque
                Text(
                  _empresaNome,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007C92),
                  ),
                ),
                const SizedBox(height: 8),
                
                // 🔹 STATUS DINÂMICO - "Coleta realizada" ou "Coleta cancelada"
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Data e hora
                Text(
                  _formatDate(widget.discard['data_descarte'] ?? ''),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 MÉTODO PARA DEFINIR O ÍCONE DO STATUS
  IconData _getStatusIcon() {
    final status = widget.discard['status']?.toString().toLowerCase() ?? '';
    
    switch (status) {
      case 'completo':
        return Icons.check_circle; // ✅ para realizado
      case 'cancelado':
        return Icons.cancel; // ❌ para cancelado
      default:
        return Icons.inventory_2; // 📦 padrão
    }
  }

  Widget _buildAvaliacaoEstrelas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Como foi sua experiência?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: const Color(0xFFD4AF37),
                  size: 40,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _rating == 0 ? 'Toque para avaliar' : '$_rating de 5 estrelas',
            style: TextStyle(
              fontSize: 14,
              color: _rating == 0 ? Colors.grey : const Color(0xFFD4AF37),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampoComentario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentário (Opcional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDEE2E6)),
          ),
          child: TextField(
            controller: _comentarioController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Boa coleta! Empresa solicita e que entrega no horario combinado. Recomendo.',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoEnviar() {
    final buttonText = widget.isEdicao ? 'Atualizar avaliação' : 'Enviar avaliação';
    
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00B894), Color(0xFF0066A2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0066A2).withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _rating > 0 ? _enviarAvaliacao : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _enviarAvaliacao() async {
    if (_minhaCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Não foi possível identificar sua empresa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final empresaAvaliadaId = widget.discard['empresa_solicitada_id']?.toString();
      final discardId = widget.discard['discard_id']?.toString();

      // 🔍 DEBUG: Verificar dados antes de enviar
      print('🔍 DEBUG AVALIAÇÃO PAGE:');
      print('   empresaAvaliadaId: $empresaAvaliadaId');
      print('   discardId: $discardId');
      print('   _minhaCompanyId: $_minhaCompanyId');
      print('   _rating: $_rating');
      print('   comment: ${_comentarioController.text}');
      print('   isEdicao: ${widget.isEdicao}');
      print('   avaliacaoExistenteUuid: $_avaliacaoExistenteUuid');

      if (empresaAvaliadaId == null || discardId == null) {
        throw Exception('Dados incompletos para avaliação: empresa=$empresaAvaliadaId, discard=$discardId');
      }

      // 🔍 Verificar se os UUIDs estão no formato correto
      if (!_isValidUuid(empresaAvaliadaId)) {
        throw Exception('UUID da empresa avaliada inválido: $empresaAvaliadaId');
      }
      if (!_isValidUuid(_minhaCompanyId!)) {
        throw Exception('UUID da minha empresa inválido: $_minhaCompanyId');
      }
      if (!_isValidUuid(discardId)) {
        throw Exception('UUID do descarte inválido: $discardId');
      }

      // ✅ VERIFICAR SE É EDIÇÃO OU CRIAÇÃO
      if (widget.isEdicao && _avaliacaoExistenteUuid != null) {
        // 🔄 MODO EDIÇÃO: Fazer UPDATE
        await AvaliacaoService.atualizarAvaliacao(
          ratingUuid: _avaliacaoExistenteUuid!,
          score: _rating,
          comment: _comentarioController.text,
        );
      } else {
        // ➕ MODO CRIAÇÃO: Fazer CREATE
        await AvaliacaoService.criarAvaliacao(
          companyUuid: empresaAvaliadaId,
          companyAvaliadoraUuid: _minhaCompanyId!,
          discardUuid: discardId,
          score: _rating,
          comment: _comentarioController.text,
        );
      }

      if (mounted) {
        final mensagem = widget.isEdicao 
            ? 'Avaliação atualizada com sucesso!' 
            : 'Avaliação enviada com sucesso!';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagem),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao ${widget.isEdicao ? 'atualizar' : 'enviar'} avaliação: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 🔍 MÉTODO AUXILIAR: Validar formato UUID
  bool _isValidUuid(String uuid) {
    // Formato UUID v4: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$', caseSensitive: false);
    return uuidRegex.hasMatch(uuid);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final month = _getMonthName(date.month);
      final year = date.year;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day de $month $year - ${hour}h${minute}';
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
}