/// Model untuk data Notification
/// Digunakan untuk menyimpan informasi notifikasi in-app
/// 
/// Properties:
/// - id: Unique identifier notifikasi
/// - userId: ID user penerima notifikasi
/// - title: Judul notifikasi
/// - message: Isi pesan notifikasi
/// - type: Tipe notifikasi (article, quiz, system, etc)
/// - isRead: Status sudah dibaca atau belum
/// - createdAt: Waktu notifikasi dibuat
/// - relatedId: ID terkait (article id, quiz id, etc) - optional

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'article', 'quiz', 'system', 'admin'
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.relatedId,
  });

  /// Convert object ke Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'related_id': relatedId,
    };
  }

  /// Buat object dari Map yang diambil dari database
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'system',
      isRead: map['is_read'] ?? false,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      relatedId: map['related_id'],
    );
  }

  /// Copy object dengan beberapa nilai yang diubah
  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      relatedId: relatedId,
    );
  }
}
