class CoreEmployee {
  const CoreEmployee({required this.id, required this.firstName, required this.lastName, this.companyId, this.role = 'employee', this.createdAt});
  final String id, firstName, lastName, role;
  final String? companyId;
  final DateTime? createdAt;
  String get displayName => '$firstName $lastName'.trim();
  factory CoreEmployee.fromMap(Map<String, dynamic> m) => CoreEmployee(id: m['id'].toString(), companyId: m['company_id']?.toString(), firstName: m['first_name']?.toString() ?? '', lastName: m['last_name']?.toString() ?? '', role: m['role']?.toString() ?? 'employee', createdAt: m['created_at'] == null ? null : DateTime.tryParse(m['created_at'].toString()));
}
