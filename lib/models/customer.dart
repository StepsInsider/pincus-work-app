class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.companyId,
  });

  final String id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final String? companyId;

  factory Customer.fromMap(Map<String, dynamic> map) {
    final name = (map['name'] ?? map['firmenname'] ?? map['ansprechpartner'] ?? '')
        .toString()
        .trim();
    return Customer(
      id: map['id'].toString(),
      name: name.isEmpty ? 'Unbenannter Kunde' : name,
      contactPerson: (map['contact_person'] ?? map['ansprechpartner'])?.toString(),
      phone: (map['phone'] ?? map['telefon'])?.toString(),
      email: map['email']?.toString(),
      address: (map['address'] ?? map['strasse'])?.toString(),
      notes: (map['notes'] ?? map['notizen'])?.toString(),
      companyId: map['company_id']?.toString(),
    );
  }
}

class CustomerLocation {
  const CustomerLocation({
    required this.id,
    required this.customerId,
    required this.name,
    this.street,
    this.postcode,
    this.city,
    this.notes,
    this.active = true,
  });

  final String id;
  final String customerId;
  final String name;
  final String? street;
  final String? postcode;
  final String? city;
  final String? notes;
  final bool active;

  factory CustomerLocation.fromMap(Map<String, dynamic> map) {
    return CustomerLocation(
      id: map['id'].toString(),
      customerId: map['kunden_id'].toString(),
      name: map['name']?.toString() ?? 'Standort',
      street: map['strasse']?.toString(),
      postcode: map['plz']?.toString(),
      city: map['ort']?.toString(),
      notes: map['notizen']?.toString(),
      active: map['aktiv'] as bool? ?? true,
    );
  }

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
}
