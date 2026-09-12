class CoreBaustelle {
  const CoreBaustelle({
    required this.id,
    required this.companyId,
    required this.title,
    this.clientName,
    this.address,
    this.status = 'active',
    this.budget,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.standortId,
  });

  final String id;
  final String companyId;
  final String title;
  final String? clientName;
  final String? address;
  final String status;
  final double? budget;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final String? standortId;

  factory CoreBaustelle.fromMap(Map<String, dynamic> m) => CoreBaustelle(
        id: m['id'].toString(),
        companyId: m['company_id'].toString(),
        title: (m['title'] ?? m['name'] ?? '').toString(),
        clientName: m['client_name']?.toString(),
        address: m['address']?.toString(),
        status: m['status']?.toString() ?? 'active',
        budget: _num(m['budget']),
        startDate: _date(m['start_date']),
        endDate: _date(m['end_date']),
        createdAt: _date(m['created_at']),
        standortId: m['standort_id']?.toString(),
      );

  Map<String, dynamic> toMap() => {
        'company_id': companyId,
        'title': title,
        if (clientName != null) 'client_name': clientName,
        if (address != null) 'address': address,
        'status': status,
        if (budget != null) 'budget': budget,
        if (startDate != null) 'start_date': _day(startDate!),
        if (endDate != null) 'end_date': _day(endDate!),
        if (standortId != null) 'standort_id': standortId,
      };

  static double? _num(dynamic value) =>
      value == null ? null : double.tryParse(value.toString());

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  static String _day(DateTime value) => value.toIso8601String().split('T').first;
}
