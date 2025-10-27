import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../widgets/mapa/svg_icon_container.dart';
import '../widgets/mapa/filter_chip.dart';
import '../widgets/mapa/selectable_filter_card.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import '../services/auth_service.dart';
// --------------------------------------------------------------------------
// MODELO DE DADOS
// --------------------------------------------------------------------------
class DisposalPoint {
  final String id;
  final String name;
  final String description;
  LatLng? location; // Agora pode ser nulo até ser geocodificado
  final List<String> categories;
  final String? address;
  final String? phone;
  double? distance; // Distância em km
  final double? rating; // Avaliação (0-5)
  final String? logoPath; // Caminho para o logo da empresa

  DisposalPoint({
    required this.id,
    required this.name,
    required this.description,
    this.location,
    this.categories = const [],
    this.address,
    this.phone,
    this.distance,
    this.rating,
    this.logoPath,
  });

  // Factory para criar a partir de JSON da API
  factory DisposalPoint.fromJson(Map<String, dynamic> json) {
  // Extrair latitude e longitude da API
  LatLng? location;
  if (json['latitude'] != null && json['longitude'] != null) {
    location = LatLng(
      json['latitude'] is String 
        ? double.parse(json['latitude']) 
        : json['latitude'].toDouble(),
      json['longitude'] is String 
        ? double.parse(json['longitude']) 
        : json['longitude'].toDouble(),
    );
  }
  
  return DisposalPoint(
    id: json['id'].toString(),
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    location: location, // Já vem preenchido da API
    categories: json['categories'] != null 
      ? List<String>.from(json['categories']) 
      : [],
    address: json['address'],
    phone: json['phone'],
    rating: json['rating']?.toDouble(),
    logoPath: json['logoPath'],
  );
}
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
  String? _token;
  final List<String> _selectedFilters = ['Reciclagem', 'MarketPlace'];
  final List<String> _availableFilters = ['Reciclagem', 'Doação', 'MarketPlace', 'Reuso'];
  final MapController mapController = MapController();

  LatLng _initialLocation = LatLng(-8.0476, -34.8770);
  final List<Marker> _markers = [];
  DisposalPoint? _selectedEnterprise;
  final PopupController _popupLayerController = PopupController();

  // Lista de empresas (será preenchida pela API)
  List<DisposalPoint> enterprisesLocations = [];

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
    _initializeMap();
    _getToken();
  }

  Future<void> _getToken() async {
   final token = await AuthService.getToken();
    setState(() {
          _token = token;
        });   
        print('Token: $token'); // Para debug
 
  }

  // Inicializa o mapa obtendo a localização do usuário e empresas
  Future<void> _initializeMap() async {
  setState(() => _isLoading = true);
  
  try {
    // 1. Obter localização da empresa do usuário (usa geocoding do endereço)
    await _getUserCompanyLocation();
    
    // 2. Buscar empresas da API (já vem com lat/lng)
    await _getCompaniesFromAPI();
    
    // 3. Calcular distâncias
    _calculateDistances();
    
    // 4. Criar marcadores
    _createMarkers();
    
    // 5. Mover mapa para localização do usuário
    mapController.move(_initialLocation, 13);
  } catch (e) {
    _showError('Erro ao inicializar mapa: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}

  // Obter endereço da empresa do usuário a partir das informações de autenticação
  Future<void> _getUserCompanyLocation() async {
    try {
      // SUBSTITUA ESTE ENDPOINT pela sua API de autenticação
      // Este é um exemplo de como obter as informações
      final response = await http.get(
        Uri.parse('https://https://ecocyclo-back.onrender.com/api/v1/company/me'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String companyAddress = data['company']['address']; // Ajuste conforme sua API
        print(response);
        
        // Converter endereço em coordenadas
        final location = await _getLatLngFromAddress(companyAddress);
        
        if (location != null) {
          setState(() {
            _initialLocation = location;
          });
        }
      } else {
        throw Exception('Erro ao buscar informações do usuário');
      }
    } catch (e) {
      print('Erro ao obter localização da empresa do usuário: $e');
      // Manter localização padrão em caso de erro
    }
  }

  // Buscar empresas da API
  Future<void> _getCompaniesFromAPI() async {
    try {
      // SUBSTITUA ESTE ENDPOINT pela sua API real
      final response = await http.get(
        Uri.parse('https://https://ecocyclo-back.onrender.com/api/v1/company/map/coletoras'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        setState(() {
          enterprisesLocations = data
            .map((item) => DisposalPoint.fromJson(item))
            .toList();
        });
      } else {
        throw Exception('Erro ao carregar empresas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar empresas da API: $e');
      // Usar dados de exemplo em caso de erro (opcional)
      _loadFallbackData();
    }
  }

  // Converter endereço em coordenadas
  Future<LatLng?> _getLatLngFromAddress(String address) async {
    if (address.isEmpty) return null;
    
    try {
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        Location location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
    } catch (e) {
      print("Erro ao converter endereço '$address': $e");
    }
    
    return null;
  }

  

  // Calcular distâncias entre usuário e empresas
  void _calculateDistances() {
    for (var enterprise in enterprisesLocations) {
      if (enterprise.location != null) {
        final distanceInMeters = Geolocator.distanceBetween(
          _initialLocation.latitude,
          _initialLocation.longitude,
          enterprise.location!.latitude,
          enterprise.location!.longitude,
        );
        
        enterprise.distance = distanceInMeters / 1000; // Converter para km
      }
    }
    
    // Ordenar empresas por distância (opcional)
    enterprisesLocations.sort((a, b) {
      if (a.distance == null) return 1;
      if (b.distance == null) return -1;
      return a.distance!.compareTo(b.distance!);
    });
  }

  // Dados de fallback em caso de erro na API
  void _loadFallbackData() {
    enterprisesLocations = [
      DisposalPoint(
        id: '1',
        name: 'RecyclaByte',
        description: 'Especializada na coleta, triagem e reaproveitamento de resíduos tecnológicos.',
        location: LatLng(-8.0476, -34.8770),
        categories: ['Reciclagem'],
        address: 'Rua Aurora, 123 - Boa Vista',
        phone: '(81) 3333-4444',
        rating: 4.98,
        logoPath: 'assets/icons/reciclagem.svg',
      ),
      DisposalPoint(
        id: '2',
        name: 'Tech Solidário',
        description: 'ONG que recebe doações de equipamentos eletrônicos.',
        location: LatLng(-8.0556, -34.8810),
        categories: ['Doação'],
        address: 'Av. Conde da Boa Vista, 456',
        phone: '(81) 9999-8888',
        rating: 4.85,
        logoPath: 'assets/icons/doacao.svg',
      ),
    ];
  }

  void _createMarkers() {
    setState(() {
      _markers.clear();

      // Marcador do usuário (empresa)
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
              Icons.business,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      );

      // Marcadores das empresas (apenas as que têm localização)
      final filteredEnterprises = _getFilteredEnterprises()
        .where((e) => e.location != null)
        .toList();
      
      for (var enterprise in filteredEnterprises) {
        Color markerColor = AppColors.secondary;
        if (enterprise.categories.isNotEmpty) {
          markerColor = _filterColors[enterprise.categories.first] ?? AppColors.secondary;
        }

        final isSelected = _selectedEnterprise?.id == enterprise.id;

        late Marker marker;
        marker = Marker(
          point: enterprise.location!,
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

  void _showError(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
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
                            final enterpriseList = enterprisesLocations
                              .where((e) => e.location == marker.point)
                              .toList();
                            
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
                                          child: Icon(
                                            Icons.recycling, 
                                            size: 24, 
                                            color: categoryColor
                                          ),
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
                                                  if (enterprise.distance != null)
                                                    Text(
                                                      "${enterprise.distance!.toStringAsFixed(1)} km",
                                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                    ),
                                                  if (enterprise.distance != null && enterprise.rating != null)
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
                                        // Navegação para detalhes
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

          // DRAGGABLE SHEET (mantido igual)
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