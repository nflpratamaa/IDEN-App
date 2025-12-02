/// Model untuk data User/Pengguna
/// Digunakan untuk menyimpan informasi akun user di database Hive
/// 
/// Properties:
/// - id: Unique identifier user
/// - name: Nama lengkap user
/// - email: Email user untuk login
/// - password: Password ter-hash untuk authentication
/// - quizzesTaken: Jumlah quiz yang sudah dikerjakan
/// - articlesRead: Jumlah artikel yang sudah dibaca
/// - savedItems: Jumlah item yang disimpan (bookmark)
/// - createdAt: Waktu pembuatan akun

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final int quizzesTaken;
  final int articlesRead;
  final int savedItems;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.quizzesTaken = 0,
    this.articlesRead = 0,
    this.savedItems = 0,
    required this.createdAt,
  });

  /// Convert object ke Map untuk disimpan ke Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'quizzesTaken': quizzesTaken,
      'articlesRead': articlesRead,
      'savedItems': savedItems,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Buat object dari Map yang diambil dari Hive
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      quizzesTaken: map['quizzesTaken'] ?? 0,
      articlesRead: map['articlesRead'] ?? 0,
      savedItems: map['savedItems'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  /// Copy object dengan beberapa nilai yang diubah
  UserModel copyWith({
    String? name,
    String? email,
    int? quizzesTaken,
    int? articlesRead,
    int? savedItems,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password,
      quizzesTaken: quizzesTaken ?? this.quizzesTaken,
      articlesRead: articlesRead ?? this.articlesRead,
      savedItems: savedItems ?? this.savedItems,
      createdAt: createdAt,
    );
  }
}
