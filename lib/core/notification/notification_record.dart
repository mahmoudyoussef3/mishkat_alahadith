import 'dart:convert';

class NotificationRecord {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final DateTime timestamp;
  final String type;
  final bool wasRead;

  NotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    required this.timestamp,
    required this.type,
    this.wasRead = false,
  });

  NotificationRecord copyWith({
    int? id,
    String? title,
    String? body,
    String? payload,
    DateTime? timestamp,
    String? type,
    bool? wasRead,
  }) {
    return NotificationRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      wasRead: wasRead ?? this.wasRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'wasRead': wasRead,
    };
  }

  factory NotificationRecord.fromJson(Map<String, dynamic> json) {
    return NotificationRecord(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      payload: json['payload'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
      wasRead: json['wasRead'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory NotificationRecord.fromJsonString(String jsonString) {
    return NotificationRecord.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  String toString() {
    return 'NotificationRecord(id: $id, title: $title, type: $type, wasRead: $wasRead)';
  }
}
