import 'package:ecocyclo_app/screens/empresas_mock_page.dart';
import 'package:ecocyclo_app/screens/perfil_empresa_coleta.dart';
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
// CONSTANTES DA API (NOVO)
// --------------------------------------------------------------------------
class ApiConstants {
  static const String baseUrl = 'https://ecocyclo-back.onrender.com/api/v1';
  static const String companyMe = '$baseUrl/company/me';
  static const String mapCollectors = '$baseUrl/company/map/coletoras';
}

// --------------------------------------------------------------------------
// MODELO DE DADOS (Sem alterações)
// --------------------------------------------------------------------------
class DisposalPoint {
  final String id;
  final String name;
  final String company_description;
  LatLng? location;
  final List<String> categories;
  final String? address;
  final String? phone;
  double? distance;
  final double? rating;
  final int? totalRatings;
  final String? logoPath;
  final String? city;
  final String? state;

  DisposalPoint({
    required this.id,
    required this.name,
    required this.company_description,
    this.location,
    this.categories = const [],
    this.address,
    this.phone,
    this.distance,
    this.rating,
    this.totalRatings,
    this.logoPath,
    this.city,
    this.state,
  });

  // Factory para criar a partir de JSON da API /map/coletoras
  factory DisposalPoint.fromJson(Map<String, dynamic> json) {
    // Extrair latitude e longitude
    LatLng? location;
    if (json['latitude'] != null && json['longitude'] != null) {
      location = LatLng(
        json['latitude'] is String
            ? double.parse(json['latitude'])
            : (json['latitude'] as num).toDouble(),
        json['longitude'] is String
            ? double.parse(json['longitude'])
            : (json['longitude'] as num).toDouble(),
      );
    }

    // Mapear company_colector_tags para categories
    List<String> categories = [];
    if (json['company_colector_tags'] != null) {
      final tags = List<String>.from(json['company_colector_tags']);
      categories = tags.map((tag) => _mapTagToCategory(tag)).toList();
    }

    // Construir endereço a partir de cidade e UF
    String? address;
    if (json['cidade'] != null && json['uf'] != null) {
      address = '${json['cidade']}, ${json['uf']}';
    }

    return DisposalPoint(
      id: json['uuid']?.toString() ?? '',
      name: json['nome'] ?? '',
      company_description: json['company_description'] ?? '',
      location: location,
      categories: categories,
      address: address,
      phone: null,
      rating: json['rating_average']?.toDouble(),
      totalRatings: json['total_ratings'],
      logoPath: null,
      city: json['cidade'],
      state: json['uf'],
    );
  }

  // Mapear tags da API para categorias do app
  static String _mapTagToCategory(String tag) {
    switch (tag.toLowerCase()) {
      case 'venda':
        return 'MarketPlace';
      case 'reciclagem':
        return 'Reciclagem';
      case 'doacao':
      case 'doação':
        return 'Doação';
      case 'reuso':
        return 'Reuso';
      default:
        return 'Reciclagem'; // Categoria padrão
    }
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
  final List<String> _availableFilters = [
    'Reciclagem',
    'Doação',
    'MarketPlace',
    'Reuso'
  ];
  final MapController mapController = MapController();

  LatLng _initialLocation = LatLng(-8.0476, -34.8770);
  List<Marker> _markers = [];
  DisposalPoint? _selectedEnterprise;
  final PopupController _popupLayerController = PopupController();

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
      description:
          'Empresas especializadas na coleta, desmontagem, análise e reciclagem dos resíduos eletrônicos descartados',
    ),
    'Doação': const FilterDetails(
      iconPath: 'assets/icons/doacao.svg',
      description:
          'Contribua com a educação e a sustentabilidade doando seus eletrônicos a projetos sociais e educacionais.',
    ),
    'MarketPlace': const FilterDetails(
      iconPath: 'assets/icons/marketplace.svg',
      description:
          'Venda seus equipamentos ainda utilizáveis com segurança e confiança.',
    ),
    'Reuso': const FilterDetails(
      iconPath: 'assets/icons/reuso.svg',
      description:
          'Para quem quer doar equipamentos que ainda funcionam, mas que não tem mais utilidade pessoal.',
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final token = await AuthService.getToken();
      if (!mounted) return;
      setState(() {
        _token = token;
      });
      print('Token: $token'); 

      await _initializeMap();
    } catch (e) {
      if (!mounted) return;
      _showError('Erro ao carregar dados iniciais: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onMapReady() {
    print('Mapa pronto! Movendo para a localização inicial.');
    mapController.move(_initialLocation, 13);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Reciclagem':
        return Icons.recycling;
      case 'Doação':
        return Icons.volunteer_activism;
      case 'MarketPlace':
        return Icons.shopping_cart;
      case 'Reuso':
        return Icons.refresh;
      default:
        return Icons.business;
    }
  }

  // 4. ATUALIZADO: Foca na orquestração e um único setState
  Future<void> _initializeMap() async {
    // Não precisa mais do `finally` aqui, pois o setState final fará o trabalho
    setState(() => _isLoading = true);
    
    try {
      // 1. Obter localização da empresa (AGORA RETORNA LatLng)
      final userLocation = await _getUserCompanyLocation();

      final companies = await _getCompaniesFromAPI();

      final calculatedCompanies = _calculateDistances(userLocation, companies);

      setState(() {
        _initialLocation = userLocation;
        enterprisesLocations = calculatedCompanies;
        _isLoading = false; 
      });

      _createMarkers();

      

    } catch (e) {
      _showError('Erro ao inicializar mapa: $e');
      if(mounted) {
        setState(() => _isLoading = false); // Garante que o loading saia em caso de erro
      }
    }
  }

  // 5. ATUALIZADO: Agora retorna Future<LatLng> e não usa setState
  Future<LatLng> _getUserCompanyLocation() async {
    LatLng fallbackLocation = LatLng(-8.0476, -34.8770); 

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.companyMe), // USA CONSTANTE
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['latitude'] != null && data['longitude'] != null) {
          final double lat = (data['latitude'] is String)
              ? double.parse(data['latitude'])
              : (data['latitude'] as num).toDouble();
          final double lng = (data['longitude'] is String)
              ? double.parse(data['longitude'])
              : (data['longitude'] as num).toDouble();

          print('Localização da empresa obtida da API: $lat, $lng');
          return LatLng(lat, lng); // RETORNA O VALOR
        } else {
          final address = _buildAddressFromCompanyData(data);
          if (address.isNotEmpty) {
            final location = await _getLatLngFromAddress(address);
            if (location != null) {
              print('Localização obtida via geocoding: $location');
              return location; // RETORNA O VALOR
            }
          }
        }
      } else {
        throw Exception(
            'Erro ao buscar informações da empresa (status ${response.statusCode})');
      }
    } catch (e) {
      print('❌ Erro ao obter localização da empresa do usuário: $e');
    }
    return fallbackLocation; 
  }

  // Método auxiliar (Sem alterações)
  String _buildAddressFromCompanyData(Map<String, dynamic> data) {
    final parts = <String>[];
    if (data['rua'] != null) parts.add(data['rua']);
    if (data['numero'] != null) parts.add(data['numero']);
    if (data['bairro'] != null) parts.add(data['bairro']);
    if (data['cidade'] != null) parts.add(data['cidade']);
    if (data['uf'] != null) parts.add(data['uf']);
    if (data['cep'] != null) parts.add(data['cep']);
    return parts.join(', ');
  }

  // 6. ATUALIZADO: Agora retorna Future<List<DisposalPoint>> e não usa setState
  Future<List<DisposalPoint>> _getCompaniesFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.mapCollectors), // USA CONSTANTE
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => DisposalPoint.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao carregar empresas: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Erro ao buscar empresas da API: $e');
      return _loadFallbackData(); 
    }
  }

  // Converter endereço em coordenadas (Sem alterações)
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

  // 7. ATUALIZADO: Recebe parâmetros e retorna a lista processada
  List<DisposalPoint> _calculateDistances(
      LatLng userLocation, List<DisposalPoint> companies) {
    for (var enterprise in companies) {
      if (enterprise.location != null) {
        final distanceInMeters = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          enterprise.location!.latitude,
          enterprise.location!.longitude,
        );
        enterprise.distance = distanceInMeters / 1000;
      }
    }
    companies.sort((a, b) {
      if (a.distance == null) return 1;
      if (b.distance == null) return -1;
      return a.distance!.compareTo(b.distance!);
    });
    return companies; 
  }

  // 8. ATUALIZADO: Apenas retorna a lista de fallback
  List<DisposalPoint> _loadFallbackData() {
    return [
      DisposalPoint(
        id: '1',
        name: 'RecyclaByte',
        company_description:
            'Especializada na coleta, triagem e reaproveitamento de resíduos tecnológicos.',
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
        company_description:
            'ONG que recebe doações de equipamentos eletrônicos.',
        location: LatLng(-8.0556, -34.8810),
        categories: ['Doação'],
        address: 'Av. Conde da Boa Vista, 456',
        phone: '(81) 9999-8888',
        rating: 4.85,
        logoPath: 'assets/icons/doacao.svg',
      ),
    ];
  }

  // _createMarkers (Sem alterações)
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

      // Marcadores das empresas
      final filteredEnterprises =
          _getFilteredEnterprises().where((e) => e.location != null).toList();

      for (var enterprise in filteredEnterprises) {
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

  // 9. ATUALIZADO: Lógica de ícone simplificada para reusar _getCategoryIcon
  Widget _buildCustomMarker(DisposalPoint enterprise, bool isSelected) {
    Color backgroundColor = AppColors.secondary;
    IconData iconData = Icons.business; // Padrão

    if (enterprise.categories.isNotEmpty) {
      final category = enterprise.categories.first;
      backgroundColor = _filterColors[category] ?? AppColors.secondary;
      
      // REUTILIZA O MÉTODO JÁ EXISTENTE
      iconData = _getCategoryIcon(category);
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

  // _getFilteredEnterprises (Sem alterações)
  List<DisposalPoint> _getFilteredEnterprises() {
    if (_selectedFilters.isEmpty) {
      return enterprisesLocations;
    }
    return enterprisesLocations.where((enterprise) {
      return enterprise.categories.any((cat) => _selectedFilters.contains(cat));
    }).toList();
  }

  // _showError (Sem alterações)
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

  // 10. ATUALIZADO: build() agora inclui o onMapReady
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
    }).toList();

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
    }).toList();

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
                    onMapReady: _onMapReady, // <-- CORREÇÃO PRINCIPAL DO ERRO
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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

                            if (enterpriseList.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            final DisposalPoint enterprise =
                                enterpriseList.first;

                            Color categoryColor = AppColors.secondary;
                            if (enterprise.categories.isNotEmpty) {
                              categoryColor =
                                  _filterColors[enterprise.categories.first] ??
                                      AppColors.secondary;
                            }

                            return Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              margin: const EdgeInsets.all(8),
                              child: Container(
                                width: 320,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Header com botão fechar
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            enterprise.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _popupLayerController
                                                .hidePopupsOnlyFor([marker]);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Informações principais
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Ícone da categoria
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color:
                                                categoryColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: categoryColor
                                                    .withOpacity(0.3)),
                                          ),
                                          child: Icon(
                                            _getCategoryIcon(enterprise
                                                    .categories.isNotEmpty
                                                ? enterprise.categories.first
                                                : ''),
                                            size: 28,
                                            color: categoryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Detalhes da empresa
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Localização
                                              if (enterprise.city != null &&
                                                  enterprise.state != null)
                                                Row(
                                                  children: [
                                                    Icon(Icons.location_on,
                                                        size: 16,
                                                        color: Colors.grey[600]),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        "${enterprise.city}, ${enterprise.state}",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                        maxLines: 2,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                              const SizedBox(height: 6),

                                              // Distância e avaliação
                                              Row(
                                                children: [
                                                  if (enterprise.distance !=
                                                      null)
                                                    Row(
                                                      children: [
                                                        Icon(Icons.directions,
                                                            size: 14,
                                                            color: Colors
                                                                .grey[600]),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          "${enterprise.distance!.toStringAsFixed(1)} km",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[700],
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  if (enterprise.distance !=
                                                          null &&
                                                      enterprise.rating != null)
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      width: 1,
                                                      height: 12,
                                                      color: Colors.grey[300],
                                                    ),
                                                  if (enterprise.rating != null)
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.star,
                                                            color: Colors.amber,
                                                            size: 14),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          enterprise.rating!
                                                              .toStringAsFixed(
                                                                  1),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .grey[800],
                                                          ),
                                                        ),
                                                        if (enterprise
                                                                .totalRatings !=
                                                            null)
                                                          Text(
                                                            " (${enterprise.totalRatings})",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                                  Colors.grey,
                                                            ),
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

                                    // Descrição da empresa
                                    if (enterprise
                                        .company_description.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          enterprise.company_description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                            height: 1.4,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],

                                    // Categorias
                                    if (enterprise.categories.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: enterprise.categories
                                            .map((category) {
                                          final color =
                                              _filterColors[category] ??
                                                  AppColors.secondary;
                                          return Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color:
                                                      color.withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              category,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: color,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],

                                    // Botão ver mais
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PerfilEmpresaColeta(
                                              empresaId: enterprise.id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: categoryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Ver detalhes completos",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: categoryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Icon(
                                              Icons.arrow_forward,
                                              size: 16,
                                              color: categoryColor,
                                            ),
                                          ],
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
                padding:
                    const EdgeInsets.only(top: 8.0, left: 8.0, right: 16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
            builder:
                (BuildContext context, ScrollController scrollController) {
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
                          hintStyle:
                              const TextStyle(color: AppColors.textSecondary),
                          prefixIcon:
                              const Icon(Icons.search, color: AppColors.secondary),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.bookmark,
                                color: AppColors.secondary),
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
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                            _isSmartRecommendationActive =
                                !_isSmartRecommendationActive;
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "Aplicar Filtros",
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.white,
                                fontWeight: FontWeight.bold),
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