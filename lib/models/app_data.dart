class Project {
  final String id;
  final String title;
  final String client;
  final String serviceType;
  final String address;

  Project({
    required this.id,
    required this.title,
    required this.client,
    required this.serviceType,
    required this.address,
  });
}

class TimeEntry {
  final String id;
  final String employeeName;
  final String projectId;
  final DateTime startTime;
  final DateTime endTime;
  final String notes;

  TimeEntry({
    required this.id,
    required this.employeeName,
    required this.projectId,
    required this.startTime,
    required this.endTime,
    required this.notes,
  });

  Duration get duration => endTime.difference(startTime);
}

class SitePhoto {
  final String id;
  final String projectId;
  final String employeeName;
  final String imageUrl;
  final DateTime timestamp;
  final String category;

  SitePhoto({
    required this.id,
    required this.projectId,
    required this.employeeName,
    required this.imageUrl,
    required this.timestamp,
    required this.category,
  });
}
