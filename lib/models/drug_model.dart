/// Model untuk data Narkotika/Drug
/// Menyimpan informasi lengkap tentang jenis narkotika
/// 
/// Properties:
/// - id: Unique identifier drug
/// - name: Nama narkotika (contoh: "Ganja", "Sabu")
/// - category: Kategori (contoh: "Golongan I", "Stimulan")
/// - description: Deskripsi lengkap tentang drug
/// - effects: Efek yang ditimbulkan
/// - dangers: Bahaya yang ditimbulkan
/// - legalStatus: Status hukum di Indonesia
/// - imageUrl: URL gambar drug (jika ada)
/// - riskLevel: Level risiko: low, medium, high, extreme

class DrugModel {
  final String id;
  final String name;
  final String otherNames; // Nama lain/alias
  final String category;
  final String description;
  final List<String> effects;
  final List<String> dangers;
  final String legalStatus;
  final String? imageUrl;
  final String riskLevel; // low, medium, high, extreme

  DrugModel({
    required this.id,
    required this.name,
    required this.otherNames,
    required this.category,
    required this.description,
    required this.effects,
    required this.dangers,
    required this.legalStatus,
    this.imageUrl,
    required this.riskLevel,
  });

  /// Convert ke Map untuk Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'other_names': otherNames,
      'category': category,
      'description': description,
      'effects': effects,
      'dangers': dangers,
      'legal_status': legalStatus,
      'image_url': imageUrl,
      'risk_level': riskLevel,
    };
  }

  /// Buat dari Map
  factory DrugModel.fromMap(Map<String, dynamic> map) {
    return DrugModel(
      id: map['id'].toString(),
      name: map['name'],
      otherNames: map['other_names'] ?? map['otherNames'] ?? '',
      category: map['category'],
      description: map['description'],
      effects: List<String>.from(map['effects'] ?? []),
      dangers: List<String>.from(map['dangers'] ?? []),
      legalStatus: map['legal_status'] ?? map['legalStatus'] ?? '',
      imageUrl: map['image_url'] ?? map['imageUrl'],
      riskLevel: map['risk_level'] ?? map['riskLevel'] ?? 'medium',
    );
  }
}
