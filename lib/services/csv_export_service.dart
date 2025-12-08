/// CSV Export Service - Export data to CSV format
/// Features: Export users, quiz results, articles stats
/// Supports: Mobile (Android/iOS), Desktop, and Web platforms
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_io/io.dart';

// Import for web
import 'dart:html' as html show AnchorElement, Blob, Url;

class CsvExportService {
  /// Export all data to CSV (combined)
  static Future<String> exportAllData({
    required List<Map<String, dynamic>> usersData,
    required List<Map<String, dynamic>> quizResults,
  }) async {
    final buffer = StringBuffer();
    final now = DateTime.now();
    
    // Add header
    buffer.writeln('LAPORAN DATA IDEN - ${DateFormat('dd/MM/yyyy HH:mm').format(now)}');
    buffer.writeln('');
    
    // Users section
    buffer.writeln('=== DATA PENGGUNA ===');
    buffer.writeln('No,Nama,Email,Artikel Dibaca,Tanggal Registrasi');
    
    for (var i = 0; i < usersData.length; i++) {
      final user = usersData[i];
      final name = _escapeCsv(user['name']?.toString() ?? 'N/A');
      final email = _escapeCsv(user['email']?.toString() ?? 'N/A');
      final articlesRead = user['articlesRead'] ?? 0;
      final createdAt = user['created_at'] != null
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(user['created_at']))
          : 'N/A';
      
      buffer.writeln('${i + 1},$name,$email,$articlesRead,$createdAt');
    }
    
    buffer.writeln('');
    buffer.writeln('=== HASIL QUIZ ===');
    buffer.writeln('No,User ID,Quiz ID,Score,Tanggal');
    
    for (var i = 0; i < quizResults.length; i++) {
      final result = quizResults[i];
      final userId = result['user_id']?.toString().substring(0, 8) ?? 'N/A';
      final quizId = result['quiz_id']?.toString().substring(0, 8) ?? 'N/A';
      final score = result['score'] ?? 0;
      final createdAt = result['created_at'] != null
          ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(result['created_at']))
          : 'N/A';
      
      buffer.writeln('${i + 1},$userId,$quizId,$score,$createdAt');
    }
    
    // Save or download based on platform
    final fileName = 'Laporan_Data_${DateFormat('yyyyMMdd_HHmmss').format(now)}.csv';
    final content = buffer.toString();
    
    if (kIsWeb) {
      return _downloadCsvWeb(content, fileName);
    } else {
      return _saveCsvMobile(content, fileName);
    }
  }
  
  /// Download CSV for web platform
  static String _downloadCsvWeb(String content, String fileName) {
    final bytes = content.codeUnits;
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
    
    return 'Downloaded: $fileName';
  }
  
  /// Save CSV for mobile/desktop platforms
  static Future<String> _saveCsvMobile(String content, String fileName) async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }
    } catch (e) {
      directory = await getTemporaryDirectory();
    }
    
    final file = File('${directory?.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }
  
  /// Export users data only
  static Future<String> exportUsersData(List<Map<String, dynamic>> users) async {
    final buffer = StringBuffer();
    final now = DateTime.now();
    
    // Header
    buffer.writeln('DATA PENGGUNA IDEN - ${DateFormat('dd/MM/yyyy HH:mm').format(now)}');
    buffer.writeln('');
    buffer.writeln('No,Nama,Email,Artikel Dibaca,Quiz Diselesaikan,Tanggal Registrasi');
    
    // Data
    for (var i = 0; i < users.length; i++) {
      final user = users[i];
      final name = _escapeCsv(user['name']?.toString() ?? 'N/A');
      final email = _escapeCsv(user['email']?.toString() ?? 'N/A');
      final articlesRead = user['articlesRead'] ?? 0;
      final quizzesCompleted = user['quizzesCompleted'] ?? 0;
      final createdAt = user['created_at'] != null
          ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(user['created_at']))
          : 'N/A';
      
      buffer.writeln('${i + 1},$name,$email,$articlesRead,$quizzesCompleted,$createdAt');
    }
    
    final fileName = 'Users_Data_${DateFormat('yyyyMMdd_HHmmss').format(now)}.csv';
    final content = buffer.toString();
    
    if (kIsWeb) {
      return _downloadCsvWeb(content, fileName);
    } else {
      return _saveCsvMobile(content, fileName);
    }
  }
  
  /// Export quiz results only
  static Future<String> exportQuizResults(List<Map<String, dynamic>> results) async {
    final buffer = StringBuffer();
    final now = DateTime.now();
    
    // Header
    buffer.writeln('HASIL QUIZ IDEN - ${DateFormat('dd/MM/yyyy HH:mm').format(now)}');
    buffer.writeln('');
    buffer.writeln('No,User ID,Quiz ID,Score,Tanggal Pengerjaan');
    
    // Data
    for (var i = 0; i < results.length; i++) {
      final result = results[i];
      final userId = result['user_id']?.toString() ?? 'N/A';
      final quizId = result['quiz_id']?.toString() ?? 'N/A';
      final score = result['score'] ?? 0;
      final createdAt = result['created_at'] != null
          ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(result['created_at']))
          : 'N/A';
      
      buffer.writeln('${i + 1},$userId,$quizId,$score,$createdAt');
    }
    
    final fileName = 'Quiz_Results_${DateFormat('yyyyMMdd_HHmmss').format(now)}.csv';
    final content = buffer.toString();
    
    if (kIsWeb) {
      return _downloadCsvWeb(content, fileName);
    } else {
      return _saveCsvMobile(content, fileName);
    }
  }
  
  /// Escape CSV special characters
  static String _escapeCsv(String text) {
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }
}
