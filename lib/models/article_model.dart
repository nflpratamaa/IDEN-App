/// Model untuk Article/Artikel edukasi
/// Menyimpan konten artikel tentang narkotika dan bahayanya
/// 
/// Properties:
/// - id: Unique identifier artikel
/// - title: Judul artikel
/// - content: Isi konten artikel (bisa HTML atau plain text)
/// - imageUrl: URL gambar thumbnail
/// - author: Nama penulis artikel
/// - category: Kategori artikel (Edukasi, Berita, Tips, dll)
/// - readTime: Estimasi waktu baca (dalam menit)
/// - views: Jumlah pembaca
/// - publishedAt: Tanggal publikasi
/// - tags: List tag untuk filtering

class ArticleModel {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String author;
  final String category;
  final int readTime; // dalam menit
  final int views;
  final DateTime publishedAt;
  final List<String> tags;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.category,
    required this.readTime,
    this.views = 0,
    required this.publishedAt,
    required this.tags,
  });

  /// Convert ke Map untuk Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'author': author,
      'category': category,
      'readTime': readTime,
      'views': views,
      'publishedAt': publishedAt.toIso8601String(),
      'tags': tags,
    };
  }

  /// Buat dari Map
  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      imageUrl: map['imageUrl'],
      author: map['author'],
      category: map['category'],
      readTime: map['readTime'],
      views: map['views'] ?? 0,
      publishedAt: DateTime.parse(map['publishedAt']),
      tags: List<String>.from(map['tags']),
    );
  }

  /// Increment view count
  ArticleModel incrementViews() {
    return ArticleModel(
      id: id,
      title: title,
      content: content,
      imageUrl: imageUrl,
      author: author,
      category: category,
      readTime: readTime,
      views: views + 1,
      publishedAt: publishedAt,
      tags: tags,
    );
  }
}
