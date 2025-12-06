/// Model untuk Emergency Contact (Kontak Darurat)
/// Menyimpan informasi kontak darurat di database
/// 
/// Properties:
/// - id: Unique identifier kontak
/// - name: Nama organisasi/kontak
/// - phone: Nomor telepon yang dapat dihubungi
/// - type: Tipe kontak (Hotline, Rumah Sakit, Konseling, Kepolisian, dll)
/// - description: Deskripsi layanan (opsional)
/// - createdAt: Waktu pembuatan data

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String type;
  final String description;
  final DateTime createdAt;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    this.description = '',
    required this.createdAt,
  });

  /// Convert object ke Map untuk disimpan ke Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'type': type,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Buat object dari Map yang diambil dari Supabase
  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? map['available'] ?? '', // fallback ke available jika ada
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
    );
  }

  /// Copy object dengan beberapa nilai yang diubah
  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? type,
    String? description,
    DateTime? createdAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
