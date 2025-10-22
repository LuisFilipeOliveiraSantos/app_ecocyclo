import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_colors.dart';
import '../widgets/mapa/svg_icon_container.dart';
import '../widgets/mapa/filter_chip.dart';
import '../widgets/mapa/selectable_filter_card.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

// --------------------------------------------------------------------------
// MODELO DE DADOS
// --------------------------------------------------------------------------
class DisposalPoint {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final List<String> categories;
  final String? address;
  final String? phone;
  final double? distance; // Distância em km
  final double? rating; // Avaliação (0-5)
  final String? logoPath; // Caminho para o logo da empresa

  const DisposalPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    this.categories = const [],
    this.address,
    this.phone,
    this.distance,
    this.rating,
    this.logoPath,
  });
}

class FilterDetails {
  final String description;
  final String iconPath;

  const FilterDetails({required this.description, required this.iconPath});
}

// --------------------------------------------------------------------------
// CLASSE PRINCIPAL: MAPSCREEN
// --------------------------------------------------------------------------
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isLoading = true;
  bool _isSmartRecommendationActive = true;
  final List<String> _selectedFilters = ['Reciclagem', 'MarketPlace'];
  final List<String> _availableFilters = ['Reciclagem', 'Doação', 'MarketPlace', 'Reuso'];
  final MapController mapController = MapController();

  LatLng _initialLocation = LatLng(-8.0476, -34.8770);
  final List<Marker> _markers = [];
  DisposalPoint? _selectedEnterprise;
  final PopupController _popupLayerController = PopupController();

  
  // DADOS DE EXEMPLO DAS EMPRESAS
  final List<DisposalPoint> enterprisesLocations = [
    DisposalPoint(
      id: '1',
      name: 'RecyclaByte',
      description: 'Especializada na coleta, triagem e reaproveitamento de resíduos tecnológicos, a empresa atende desde residências até grandes indústrias.',
      location: LatLng(-8.0476, -34.8770),
      categories: ['Reciclagem'],
      address: 'Rua Aurora, 123 - Boa Vista',
      phone: '(81) 3333-4444',
      distance: 3.6,
      rating: 4.98,
      logoPath: 'assets/icons/reciclagem.svg',
    ),
    DisposalPoint(
      id: '2',
      name: 'Tech Solidário',
      description: 'ONG que recebe doações de equipamentos eletrônicos para projetos educacionais',
      location: LatLng(-8.0556, -34.8810),
      categories: ['Doação'],
      address: 'Av. Conde da Boa Vista, 456',
      phone: '(81) 9999-8888',
      distance: 2.1,
      rating: 4.85,
      logoPath: 'assets/icons/doacao.svg',
    ),
    DisposalPoint(
      id: '3',
      name: 'Marketplace Tech',
      description: 'Compra e venda de eletrônicos usados com garantia',
      location: LatLng(-8.0400, -34.8900),
      categories: ['MarketPlace'],
      address: 'Shopping Recife, Loja 205',
      phone: '(81) 3555-6666',
      distance: 4.2,
      rating: 4.72,
      logoPath: 'assets/icons/marketplace.svg',
    ),
    DisposalPoint(
      id: '4',
      name: 'Renova Tech',
      description: 'Reuso e recondicionamento de equipamentos eletrônicos',
      location: LatLng(-8.0600, -34.8700),
      categories: ['Reuso'],
      address: 'Rua do Príncipe, 789',
      phone: '(81) 3777-9999',
      distance: 1.8,
      rating: 4.91,
      logoPath: 'assets/icons/reuso.svg',
    ),
  ];

  final Map<String, Color> _filterColors = {
    'Reciclagem': AppColors.secondary,
    'Doação': Colors.green.shade600,
    'MarketPlace': Colors.blue.shade600,
    'Reuso': Colors.orange.shade700,
  };

  final Map<String, FilterDetails> _filterDetails = {
    'Reciclagem': const FilterDetails(
      iconPath: 'assets/icons/reciclagem.svg',
      description: 'Empresas especializadas na coleta, desmontagem, análise e reciclagem dos resíduos eletrônicos descartados',
    ),
    'Doação': const FilterDetails(
      iconPath: 'assets/icons/doacao.svg',
      description: 'Contribua com a educação e a sustentabilidade doando seus eletrônicos a projetos sociais e educacionais.',
    ),
    'MarketPlace': const FilterDetails(
      iconPath: 'assets/icons/marketplace.svg',
      description: 'Venda seus equipamentos ainda utilizáveis com segurança e confiança.',
    ),
    'Reuso': const FilterDetails(
      iconPath: 'assets/icons/reuso.svg',
      description: 'Para quem quer doar equipamentos que ainda funcionam, mas que não tem mais utilidade pessoal.',
    ),
  };

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showServicoDesativado();
        setState(() => _isLoading = false);
        _createMarkers();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocalationNegadaError();
          setState(() => _isLoading = false);
          _createMarkers();
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _initialLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _createMarkers();
      mapController.move(_initialLocation, 14);
    } catch (e) {
      _showLocalationError('Erro ao obter localização: $e');
      setState(() => _isLoading = false);
      _createMarkers();
    }
  }

  void _createMarkers() {
    setState(() {
      _markers.clear();

      // Marcador do usuário
      _markers.add(
        Marker(
          point: _initialLocation,
          width: 60,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      );

      // Marcadores das empresas
      final filteredEnterprises = _getFilteredEnterprises();
      
      for (var enterprise in filteredEnterprises) {
        Color markerColor = AppColors.secondary;
        if (enterprise.categories.isNotEmpty) {
          markerColor = _filterColors[enterprise.categories.first] ?? AppColors.secondary;
        }

        final isSelected = _selectedEnterprise?.id == enterprise.id;

        // Criar o marker uma vez e reutilizar
        late Marker marker;
        marker = Marker(
          point: enterprise.location,
          width: isSelected ? 60 : 50,
          height: isSelected ? 60 : 50,
          child: GestureDetector(
            onTap: () {
              _popupLayerController.togglePopup(marker);
            },
            child: _buildCustomMarker(enterprise, isSelected),
          ),
        );

        _markers.add(marker);
      }
    });
  }

  Widget _buildCustomMarker(DisposalPoint enterprise, bool isSelected) {
    Color backgroundColor = AppColors.secondary;
    IconData iconData = Icons.business;
    
    if (enterprise.categories.isNotEmpty) {
      final category = enterprise.categories.first;
      backgroundColor = _filterColors[category] ?? AppColors.secondary;
      
      switch (category) {
        case 'Reciclagem':
          iconData = Icons.recycling;
          break;
        case 'Doação':
          iconData = Icons.volunteer_activism;
          break;
        case 'MarketPlace':
          iconData = Icons.shopping_cart;
          break;
        case 'Reuso':
          iconData = Icons.refresh;
          break;
        default:
          iconData = Icons.business;
      }
    }

    return Container(
      width: isSelected ? 60 : 50,
      height: isSelected ? 60 : 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: isSelected ? 8 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: isSelected ? 30 : 25,
      ),
    );
  }

  List<DisposalPoint> _getFilteredEnterprises() {
    if (_selectedFilters.isEmpty) {
      return enterprisesLocations;
    }

    return enterprisesLocations.where((enterprise) {
      return enterprise.categories.any((cat) => _selectedFilters.contains(cat));
    }).toList();
  }

  void _showServicoDesativado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Localização Desabilitada'),
        content: const Text('Por favor, habilite o serviço de localização.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocalationNegadaError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissão Negada'),
        content: const Text('Precisamos da permissão de localização para mostrar sua posição no mapa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocalationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro de Localização'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFilterChips = _selectedFilters
        .where((name) => _filterDetails.containsKey(name))
        .map((name) {
          final color = _filterColors[name] ?? AppColors.secondary;
          final details = _filterDetails[name]!;
          return FilterChipWidget(
            key: ValueKey(name),
            label: name,
            iconPath: details.iconPath,
            color: color,
            onRemove: () {
              setState(() {
                _selectedFilters.remove(name);
                _createMarkers();
              });
            },
          );
        })
        .toList();

    final selectableFilterCards = _availableFilters
        .where((name) => _filterDetails.containsKey(name))
        .map((name) {
          final details = _filterDetails[name]!;
          final color = _filterColors[name] ?? AppColors.secondary;
          final isSelected = _selectedFilters.contains(name);

          return SelectableFilterCard(
            key: ValueKey(name),
            filterName: name,
            details: details,
            color: color,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedFilters.remove(name);
                } else {
                  _selectedFilters.add(name);
                }
                _createMarkers();
              });
            },
          );
        })
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          // MAPA
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                )
              : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: _initialLocation,
                    initialZoom: 13.0,
                    minZoom: 10.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    PopupMarkerLayer(
                      options: PopupMarkerLayerOptions(
                        popupController: _popupLayerController,
                        markers: _markers,
                        markerCenterAnimation: const MarkerCenterAnimation(),
                        popupDisplayOptions: PopupDisplayOptions(
                          builder: (BuildContext context, Marker marker) {
                            final enterpriseList = enterprisesLocations.where((e) => e.location == marker.point).toList();
                            if (enterpriseList.isEmpty) return const SizedBox.shrink();
                            final DisposalPoint enterprise = enterpriseList.first;

                            Color categoryColor = AppColors.secondary;
                            if (enterprise.categories.isNotEmpty) {
                              categoryColor = _filterColors[enterprise.categories.first] ?? AppColors.secondary;
                            }

                            return Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Container(
                                width: 280,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Botão de fechar
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          _popupLayerController.hidePopupsOnlyFor([marker]);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: categoryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.recycling, size: 24, color: AppColors.secondary),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                enterprise.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Próximo a você (${enterprise.distance?.toStringAsFixed(1)} km)",
                                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  if (enterprise.rating != null)
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.star, color: Colors.amber, size: 14),
                                                        Text(
                                                          enterprise.rating!.toStringAsFixed(2),
                                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      enterprise.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () {
                                        // Navigator.push(context, 
                                        //   MaterialPageRoute(builder: 
                                        //     // (context) => EnterpriseDetailScreen(enterprise: enterprise)
                                        //   )
                                        // );
                                      },
                                      child: Text(
                                        "ver mais...",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: categoryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

          // HEADER
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Encontre empresas",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // DRAGGABLE SHEET
          DraggableScrollableSheet(
            initialChildSize: 0.15,
            minChildSize: 0.15,
            maxChildSize: 0.90,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.black26,
                      offset: Offset(0, -3),
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(top: 8.0, bottom: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Puxador
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),

                      // Campo de busca
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Digite o nome da empresa...",
                          hintStyle: const TextStyle(color: AppColors.textSecondary),
                          prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.bookmark, color: AppColors.secondary),
                            onPressed: () {},
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        "Filtros",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SvgIconContainer(
                            iconPath: 'assets/icons/home_search.svg',
                            color: AppColors.secondary,
                            size: 20,
                            padding: 8,
                            isActive: false,
                            isSmartRecIcon: false,
                            shouldApplyColorFilter: true,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Arraste para cima e selecione os filtros para que possamos te ajudar da melhor forma.",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSmartRecommendationActive = !_isSmartRecommendationActive;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgIconContainer(
                              iconPath: 'assets/icons/stars.svg',
                              color: AppColors.secondary,
                              size: 20,
                              padding: 8,
                              isActive: _isSmartRecommendationActive,
                              isSmartRecIcon: true,
                              shouldApplyColorFilter: true,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Ativar recomendação inteligente",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      if (activeFilterChips.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Selecionados",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFilters.clear();
                                  _createMarkers();
                                });
                              },
                              child: const Text(
                                "Limpar Filtros",
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: activeFilterChips,
                        ),
                      ],

                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: selectableFilterCards,
                      ),

                      const SizedBox(height: 32),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _createMarkers();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "Aplicar Filtros",
                            style: TextStyle(fontSize: 16, color: AppColors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}