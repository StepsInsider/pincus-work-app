class Lead {
  const Lead({
    required this.id,
    required this.status,
    required this.service,
    required this.contactName,
    this.city,
    this.postcode,
    this.address,
    this.projectSize,
    this.desiredPeriod,
    this.description,
    this.photoUrls = const [],
    this.phone,
    this.email,
    this.source,
    this.landingPage,
    this.campaign,
    this.keyword,
    this.leadScore = 0,
    this.createdAt,
  });

  final String id;
  final String status;
  final String service;
  final String contactName;
  final String? city;
  final String? postcode;
  final String? address;
  final String? projectSize;
  final String? desiredPeriod;
  final String? description;
  final List<String> photoUrls;
  final String? phone;
  final String? email;
  final String? source;
  final String? landingPage;
  final String? campaign;
  final String? keyword;
  final int leadScore;
  final DateTime? createdAt;

  factory Lead.fromMap(Map<String, dynamic> map) {
    return Lead(
      id: map['id'].toString(),
      status: map['status']?.toString() ?? 'neu',
      service: map['service']?.toString() ?? '',
      contactName: map['contact_name']?.toString() ?? '',
      city: map['city']?.toString(),
      postcode: map['postcode']?.toString(),
      address: map['address']?.toString(),
      projectSize: map['project_size']?.toString(),
      desiredPeriod: map['desired_period']?.toString(),
      description: map['description']?.toString(),
      photoUrls: ((map['photo_urls'] as List?) ?? const []).map((e) => e.toString()).toList(growable: false),
      phone: map['phone']?.toString(),
      email: map['email']?.toString(),
      source: map['source']?.toString(),
      landingPage: map['landing_page']?.toString(),
      campaign: map['campaign']?.toString(),
      keyword: map['keyword']?.toString(),
      leadScore: (map['lead_score'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] == null ? null : DateTime.tryParse(map['created_at'].toString()),
    );
  }
}
