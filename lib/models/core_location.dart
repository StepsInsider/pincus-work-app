class CoreLocation {
  const CoreLocation({
    required this.id,
    required this.companyId,
    required this.customerId,
    required this.name,
    this.street,
    this.postcode,
    this.city,
    this.notes,
    this.active = true,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String customerId;
  final String name;
  final String? street;
  final String? postcode;
  final String? city;
  final String? notes;
  final bool active;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get addressLine {
    final parts = <String>[];
    if ((street ?? '').trim().isNotEmpty) parts.add(street!.trim());
    final cityLine = [
      if ((postcode ?? '').trim().isNotEmpty) postcode!.trim(),
      if ((city ?? '').trim().isNotEmpty) city!.trim(),
    ].join(' ');
    if (cityLine.isNotEmpty) parts.add(cityLine);
    return parts.join(', ');
  }

  factory CoreLocation.fromMap(Map<String, dynamic> m) => CoreLocation(
        id: m['id'].toString(),
        companyId: m['company_id'].toString(),
        customerId: m['kunden_id'].toString(),
        name: (m['name'] ?? 'Standort').toString(),
        street: m['strasse']?.toString(),
        postcode: m['plz']?.toString(),
        city: m['ort']?.toString(),
        notes: m['notizen']?.toString(),
        active: m['aktiv'] as bool? ?? true,
        latitude: _num(m['latitude']),
        longitude: _num(m['longitude']),
        createdAt: _date(m['created_at']),
        updatedAt: _date(m['updated_at']),
      );

  Map<String, dynamic> toMap() => {
        'company_id': companyId,
        'kunden_id': customerId,
        'name': name,
        if (street != null) 'strasse': street,
        if (postcode != null) 'plz': postcode,
        if (city != null) 'ort': city,
        if (notes != null) 'notizen': notes,
        'aktiv': active,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

  static double? _num(dynamic value) =>
      value == null ? null : double.tryParse(value.toString());

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
