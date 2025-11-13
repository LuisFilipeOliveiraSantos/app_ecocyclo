// models/user_model.dart
class UserModel {
  final String id;
  String name;
  String phone;
  String email;
  String companyDescription;
  List<String> companyCollectorTags;
  String cep;
  String street;
  String number;
  String neighborhood;
  String city;
  String state;
  String complement;
  String reference;
  bool isActive;
  String? companyPhotoUrl;
  DateTime createdAt;
  DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.companyDescription = '',
    List<String>? companyCollectorTags,
    this.cep = '',
    this.street = '',
    this.number = '',
    this.neighborhood = '',
    this.city = '',
    this.state = '',
    this.complement = '',
    this.reference = '',
    this.isActive = true,
    this.companyPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : companyCollectorTags = companyCollectorTags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Converter para JSON para PATCH
  Map<String, dynamic> toUpdateJson() => {
        'nome': name,
        'telefone': phone,
        'email': email,
        'company_description': companyDescription,
        'company_colector_tags': companyCollectorTags,
        'company_photo_url': companyPhotoUrl,
        'cep': cep,
        'rua': street,
        'numero': number,
        'bairro': neighborhood,
        'cidade': city,
        'uf': state,
        'complemento': complement,
        'referencia': reference,
        'is_active': isActive,
      };

  // Para atualização de senha
  Map<String, dynamic> toPasswordUpdateJson(String password, String confirmPassword) => {
        'password': password,
        'confirm_password': confirmPassword,
      };

  // Factory from API response
  factory UserModel.fromApiJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? json['uuid']?.toString() ?? '',
        name: json['nome'] as String? ?? '',
        phone: json['telefone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        companyDescription: json['company_description'] as String? ?? '',
        companyCollectorTags: (json['company_colector_tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        cep: json['cep'] as String? ?? '',
        street: json['rua'] as String? ?? '',
        number: json['numero'] as String? ?? '',
        neighborhood: json['bairro'] as String? ?? '',
        city: json['cidade'] as String? ?? '',
        state: json['uf'] as String? ?? '',
        complement: json['complemento'] as String? ?? '',
        reference: json['referencia'] as String? ?? '',
        isActive: json['is_active'] as bool? ?? true,
        companyPhotoUrl: json['company_photo_url'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? companyDescription,
    List<String>? companyCollectorTags,
    String? cep,
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? state,
    String? complement,
    String? reference,
    bool? isActive,
    String? companyPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        companyDescription: companyDescription ?? this.companyDescription,
        companyCollectorTags: companyCollectorTags ?? this.companyCollectorTags,
        cep: cep ?? this.cep,
        street: street ?? this.street,
        number: number ?? this.number,
        neighborhood: neighborhood ?? this.neighborhood,
        city: city ?? this.city,
        state: state ?? this.state,
        complement: complement ?? this.complement,
        reference: reference ?? this.reference,
        isActive: isActive ?? this.isActive,
        companyPhotoUrl: companyPhotoUrl ?? this.companyPhotoUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}