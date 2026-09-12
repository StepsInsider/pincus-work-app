class CoreBaustelle {
  const CoreBaustelle({required this.id, required this.companyId, required this.title, this.clientName, this.address, this.status = 'active', this.budget, this.startDate, this.endDate, this.createdAt, this.customerId});
  final String id, companyId, title, status;
  final String? clientName, address, customerId;
  final double? budget;
  final DateTime? startDate, endDate, createdAt;
  factory CoreBaustelle.fromMap(Map<String, dynamic> m) => CoreBaustelle(id: m['id'].toString(), companyId: m['company_id'].toString(), title: (m['title'] ?? m['name'] ?? '').toString(), clientName: m['client_name']?.toString(), address: m['address']?.toString(), status: m['status']?.toString() ?? 'active', budget: _num(m['budget']), startDate: _date(m['start_date']), endDate: _date(m['end_date']), createdAt: _date(m['created_at']), customerId: m['customer_id']?.toString());
  Map<String, dynamic> toMap() => {'company_id': companyId, 'title': title, if (clientName != null) 'client_name': clientName, if (address != null) 'address': address, 'status': status, if (budget != null) 'budget': budget, if (startDate != null) 'start_date': startDate!.toIso8601String().split('T').first, if (endDate != null) 'end_date': endDate!.toIso8601String().split('T').first};
  static double? _num(dynamic v) => v == null ? null : double.tryParse(v.toString());
  static DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
}
