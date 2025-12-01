import 'package:latlong2/latlong.dart';

class DisposalPoint {
  final String id;
  final String name;
  final String companyDescription;
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
  final String? bairro;
  final String? rua;
  final String? numero;

  DisposalPoint({
    required this.id,
    required this.name,
    required this.companyDescription,
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
    this.bairro,
    this.rua,
    this.numero,
  });

  factory DisposalPoint.fromJson(Map<String, dynamic> json) {
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

    List<String> categories = [];
    if (json['company_colector_tags'] != null) {
      categories = List<String>.from(json['company_colector_tags'])
          .map((tag) => _mapTagToCategory(tag))
          .toList();
    }

    String? address;
    final parts = <String>[];
    if (json['rua'] != null) parts.add(json['rua']);
    if (json['numero'] != null) parts.add(json['numero']);
    if (json['bairro'] != null) parts.add(json['bairro']);
    if (json['cidade'] != null) parts.add(json['cidade']);
    if (json['uf'] != null) parts.add(json['uf']);
    if (parts.isNotEmpty) address = parts.join(', ');

    return DisposalPoint(
      id: json['uuid']?.toString() ?? '',
      name: json['nome'] ?? '',
      companyDescription: json['company_description'] ?? '',
      location: location,
      categories: categories,
      address: address,
      phone: json['telefone'],
      rating: json['rating_average']?.toDouble(),
      totalRatings: json['total_ratings'],
      logoPath: json['company_photo_url'],
      city: json['cidade'],
      state: json['uf'],
      bairro: json['bairro'],
      rua: json['rua'],
      numero: json['numero'],
    );
  }

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
        return 'Reciclagem';
    }
  }
}
