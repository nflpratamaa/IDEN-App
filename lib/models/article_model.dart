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
/// - readCount: Jumlah pembaca
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
  final int? readCount;
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
    this.readCount = 0,
    required this.publishedAt,
    required this.tags,
  });

  /// Convert ke Map untuk Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'author': author,
      'category': category,
      'read_time': readTime,
      'read_count': readCount ?? 0,
      'published_at': publishedAt.toIso8601String(),
      'tags': tags,
    };
  }

  /// Buat dari Map
  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'].toString(),
      title: map['title'],
      content: map['content'],
      imageUrl: map['image_url'] ?? map['imageUrl'] ?? '',
      author: map['author'],
      category: map['category'],
      readTime: map['read_time'] ?? map['readTime'] ?? 5,
      readCount: map['read_count'] ?? map['readCount'] ?? 0,
      publishedAt: DateTime.parse(map['published_at'] ?? map['publishedAt']),
      tags: List<String>.from(map['tags'] ?? []),
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
      readCount: (readCount ?? 0) + 1,
      publishedAt: publishedAt,
      tags: tags,
    );
  }
}
