class CoreTimeEntry {
  const CoreTimeEntry({required this.id, required this.companyId, required this.employeeId, this.siteId, required this.startedAt, this.endedAt, this.breakMinutes = 0, this.totalHours, this.startLat, this.startLng, this.endLat, this.endLng, this.note, this.createdAt, this.updatedAt});
  final String id, companyId, employeeId;
  final String? siteId, note;
  final DateTime startedAt;
  final DateTime? endedAt, createdAt, updatedAt;
  final int breakMinutes;
  final double? totalHours, startLat, startLng, endLat, endLng;
  factory CoreTimeEntry.fromMap(Map<String, dynamic> m) => CoreTimeEntry(id: m['id'].toString(), companyId: m['company_id'].toString(), employeeId: m['mitarbeiter_id'].toString(), siteId: m['baustelle_id']?.toString(), startedAt: DateTime.parse(m['arbeitsbeginn'].toString()), endedAt: m['arbeitsende'] == null ? null : DateTime.tryParse(m['arbeitsende'].toString()), breakMinutes: (m['pause_minuten'] as num?)?.toInt() ?? 0, totalHours: _num(m['gesamtstunden']), startLat: _num(m['gps_start_lat']), startLng: _num(m['gps_start_lng']), endLat: _num(m['gps_end_lat']), endLng: _num(m['gps_end_lng']), note: m['notiz']?.toString(), createdAt: _date(m['created_at']), updatedAt: _date(m['updated_at']));
  Map<String, dynamic> toMap() => {'company_id': companyId, 'mitarbeiter_id': employeeId, if (siteId != null) 'baustelle_id': siteId, 'arbeitsbeginn': startedAt.toIso8601String(), if (endedAt != null) 'arbeitsende': endedAt!.toIso8601String(), 'pause_minuten': breakMinutes, if (totalHours != null) 'gesamtstunden': totalHours, if (startLat != null) 'gps_start_lat': startLat, if (startLng != null) 'gps_start_lng': startLng, if (endLat != null) 'gps_end_lat': endLat, if (endLng != null) 'gps_end_lng': endLng, if (note != null) 'notiz': note};
  static double? _num(dynamic v) => v == null ? null : double.tryParse(v.toString());
  static DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
}
