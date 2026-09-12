class CoreOrder {
  const CoreOrder({required this.id, required this.companyId, required this.customerId, required this.title, this.offerId, this.orderNumber, this.description, this.status = 'offen', this.startDate, this.endDate, this.budget, this.siteId, this.createdBy, this.createdAt, this.updatedAt});
  final String id, companyId, customerId, title, status;
  final String? offerId, orderNumber, description, siteId, createdBy;
  final DateTime? startDate, endDate, createdAt, updatedAt;
  final double? budget;
  factory CoreOrder.fromMap(Map<String, dynamic> m) => CoreOrder(id: m['id'].toString(), companyId: m['company_id'].toString(), customerId: m['kunden_id'].toString(), title: m['titel']?.toString() ?? '', offerId: m['angebot_id']?.toString(), orderNumber: m['auftragsnummer']?.toString(), description: m['beschreibung']?.toString(), status: m['status']?.toString() ?? 'offen', startDate: _date(m['startdatum']), endDate: _date(m['enddatum']), budget: _num(m['budget']), siteId: m['baustelle_id']?.toString(), createdBy: m['erstellt_von']?.toString(), createdAt: _date(m['created_at']), updatedAt: _date(m['updated_at']));
  Map<String, dynamic> toMap() => {'company_id': companyId, 'kunden_id': customerId, if (offerId != null) 'angebot_id': offerId, if (orderNumber != null) 'auftragsnummer': orderNumber, 'titel': title, if (description != null) 'beschreibung': description, 'status': status, if (startDate != null) 'startdatum': _day(startDate!), if (endDate != null) 'enddatum': _day(endDate!), if (budget != null) 'budget': budget, if (siteId != null) 'baustelle_id': siteId, if (createdBy != null) 'erstellt_von': createdBy};
  static double? _num(dynamic v) => v == null ? null : double.tryParse(v.toString());
  static DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
  static String _day(DateTime v) => v.toIso8601String().split('T').first;
}
