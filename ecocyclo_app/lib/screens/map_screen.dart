import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';

// Imports do Projeto (Ajuste os caminhos conforme sua estrutura de pastas)
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../models/disposal_point.dart';
import '../services/map_service.dart';

// Imports dos Widgets Refatorados
import '../widgets/mapa/map_header.dart';
import '../widgets/mapa/map_filter.dart';
import '../widgets/mapa/company_popup.dart'; // Onde está o CompanyPopupCard

// Import da tela de detalhes
import 'perfil_empresa_coleta.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ---------------------------------------------------------------------------
  // ESTADO DA TELA
  // ---------------------------------------------------------------------------
  bool _isLoading = true;
  LatLng _initialLocation = LatLng(-8.0476, -34.8770); // Default: Recife
  
  // Dados
  List<DisposalPoint> _allCompanies = [];
  List<DisposalPoint> _filteredCompanies = [];
  
  // Filtros
  final List<String> _availableFilters = ['Reciclagem', 'Doação', 'MarketPlace', 'Reuso'];
  final List<String> _selectedFilters = ['Reciclagem', 'MarketPlace'];
  
  // Controllers do Mapa
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  // Configuração de Cores por Categoria
  final Map<String, Color> _categoryColors = {
    'Reciclagem': AppColors.secondary,
    'Doação': Colors.green.shade600,
    'MarketPlace': Colors.blue.shade600,
    'Reuso': Colors.orange.shade700,
  };

  // ---------------------------------------------------------------------------
  // CICLO DE VIDA
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // ---------------------------------------------------------------------------
  // LÓGICA DE NEGÓCIO (Carregamento e Filtros)
  // ---------------------------------------------------------------------------
  Future<void> _initializeData() async {
    try {
      final token = await AuthService.getToken();
      final repository = MapService(token);

      // 1. Obter localização do usuário
      final userLocation = await repository.getUserCompanyLocation();

      // 2. Buscar empresas na API
      final companies = await repository.fetchCompanies(userLocation);

      if (mounted) {
        setState(() {
          _initialLocation = userLocation;
          _allCompanies = companies;
          _updateFilteredList(); // Aplica o filtro inicial
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erro ao inicializar mapa: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateFilteredList() {
    if (_selectedFilters.isEmpty) {
      _filteredCompanies = List.from(_allCompanies);
    } else {
      _filteredCompanies = _allCompanies.where((enterprise) {
        // Verifica se a empresa tem alguma das categorias selecionadas
        return enterprise.categories.any((cat) => _selectedFilters.contains(cat));
      }).toList();
    }
  }

  void _onToggleFilter(String filterName) {
    setState(() {
      if (_selectedFilters.contains(filterName)) {
        _selectedFilters.remove(filterName);
      } else {
        _selectedFilters.add(filterName);
      }
      // Opcional: Atualizar a lista imediatamente ou esperar o botão "Aplicar"
      // _updateFilteredList(); 
    });
  }

  void _onApplyFilters() {
    setState(() {
      _updateFilteredList();
      _popupController.hideAllPopups(); // Fecha popups abertos para evitar erros
    });
    FocusScope.of(context).unfocus(); // Fecha o teclado se estiver aberto
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Reciclagem': return Icons.recycling;
      case 'Doação': return Icons.volunteer_activism;
      case 'MarketPlace': return Icons.shopping_cart;
      case 'Reuso': return Icons.refresh;
      default: return Icons.business;
    }
  }

  void _navigateToDetails(DisposalPoint enterprise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerfilEmpresaColeta(
          // Passando dados limpos do objeto refatorado
          nome: enterprise.name,
          id_solicitada: enterprise.id,
          avaliacao: enterprise.rating ?? 0.0,
          descricao: enterprise.company_description,
          imagemLogo: enterprise.logoPath ?? '',
          endereco: enterprise.address ?? '',
          contato: enterprise.phone ?? '',
          geminiItens: const {}, // Ajuste conforme sua lógica original
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONSTRUÇÃO DA UI (BUILD)
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Evita que o mapa suba com o teclado
      body: Stack(
        children: [
          // 1. CAMADA DO MAPA
          _buildMapLayer(),

          // 2. HEADER (Topo Esquerdo)
          MapHeader(
            title: "Encontre empresas",
            onBackPressed: () => Navigator.pop(context),
          ),

          // 3. BOTTOM SHEET (Filtros e Busca)
          DraggableScrollableSheet(
            initialChildSize: 0.15,
            minChildSize: 0.15,
            maxChildSize: 0.90,
            builder: (context, scrollController) {
              return MapFilterSheet(
                scrollController: scrollController,
                availableFilters: _availableFilters,
                selectedFilters: _selectedFilters,
                filterColors: _categoryColors,
                onToggleFilter: _onToggleFilter,
                onClearFilters: () {
                  setState(() {
                    _selectedFilters.clear();
                    _updateFilteredList();
                  });
                },
                onApply: _onApplyFilters,
              );
            },
          ),

          // 4. INDICADOR DE CARREGAMENTO
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              ),
            ),
        ],
      ),
    );
  }

  // Helper para construir o Widget do Mapa
  Widget _buildMapLayer() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _initialLocation,
        initialZoom: 13.0,
        minZoom: 10.0,
        maxZoom: 18.0,
        onMapReady: () {
          // Move o mapa apenas quando estiver pronto e carregado
          if (!_isLoading) _mapController.move(_initialLocation, 13);
        },
        // Fecha popups ao tocar no mapa vazio
        onTap: (_, __) => _popupController.hideAllPopups(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=asLR5YMH8ynyVq879bVR',
          userAgentPackageName: 'com.ecocyclo.app',
        ),
        PopupMarkerLayer(
          options: PopupMarkerLayerOptions(
            popupController: _popupController,
            markers: _buildMarkers(),
            popupDisplayOptions: PopupDisplayOptions(
              builder: (BuildContext context, Marker marker) {
                // Encontrar a empresa correspondente ao marcador
                // Usamos firstWhere com segurança
                final enterprise = _filteredCompanies.firstWhere(
                  (e) => e.location == marker.point,
                  orElse: () => _allCompanies.first, 
                );

                final category = enterprise.categories.isNotEmpty 
                    ? enterprise.categories.first 
                    : 'Reciclagem';

                return CompanyPopupCard(
                  enterprise: enterprise,
                  categoryColor: _categoryColors[category] ?? AppColors.secondary,
                  categoryIcon: _getCategoryIcon(category),
                  onClose: () => _popupController.hidePopupsOnlyFor([marker]),
                  onDetails: () => _navigateToDetails(enterprise),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Helper para construir a lista de Marcadores
  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // 1. Marcador do Usuário (Sua empresa)
    markers.add(
      Marker(
        point: _initialLocation,
        width: 60,
        height: 60,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: const Icon(Icons.my_location, color: Colors.white, size: 30),
        ),
      ),
    );

    // 2. Marcadores das Empresas Filtradas
    for (var enterprise in _filteredCompanies) {
      if (enterprise.location == null) continue;

      final category = enterprise.categories.isNotEmpty ? enterprise.categories.first : 'Reciclagem';
      final color = _categoryColors[category] ?? AppColors.secondary;

      markers.add(
        Marker(
          point: enterprise.location!,
          width: 50,
          height: 50,
          child: GestureDetector(
            // O PopupMarkerLayer lida com o Tap automaticamente se configurado,
            // mas podemos forçar lógica extra aqui se necessário.
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))
                ],
              ),
              child: Icon(
                _getCategoryIcon(category),
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }
}