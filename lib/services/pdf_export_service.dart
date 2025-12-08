/// PDF Export Service - Generate analytics reports in PDF format
/// Features: Statistics overview, user data tables, quiz results, article stats
/// Supports: Mobile (Android/iOS), Desktop, and Web platforms
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_io/io.dart';
import 'dart:typed_data';

// Import for web
import 'dart:html' as html show AnchorElement, Blob, Url;

class PdfExportService {
  /// Generate complete analytics report PDF
  static Future<String> generateAnalyticsReport({
    required int totalUsers,
    required int activeUsers,
    required int totalQuizAttempts,
    required double avgQuizScore,
    required int totalArticlesRead,
    required List<Map<String, dynamic>> usersData,
    required List<Map<String, dynamic>> quizResults,
    String? adminName,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    // Add pages to PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(dateFormat.format(now)),
          pw.SizedBox(height: 20),
          
          // Statistics Overview
          _buildStatisticsSection(
            totalUsers: totalUsers,
            activeUsers: activeUsers,
            totalQuizAttempts: totalQuizAttempts,
            avgQuizScore: avgQuizScore,
            totalArticlesRead: totalArticlesRead,
          ),
          pw.SizedBox(height: 20),
          
          // Users Summary
          _buildSectionTitle('Ringkasan Pengguna'),
          pw.SizedBox(height: 10),
          _buildUsersSummaryTable(usersData),
          pw.SizedBox(height: 20),
          
          // Quiz Results Summary
          _buildSectionTitle('Hasil Quiz Terbaru'),
          pw.SizedBox(height: 10),
          _buildQuizResultsTable(quizResults),
          pw.SizedBox(height: 30),
          
          // Footer
          _buildFooter(adminName ?? 'Admin', dateFormat.format(now)),
        ],
      ),
    );
    
    // Generate PDF bytes
    final bytes = await pdf.save();
    final fileName = 'Laporan_Analytics_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf';
    
    // Save or download based on platform
    if (kIsWeb) {
      return _downloadPdfWeb(bytes, fileName);
    } else {
      return _savePdfMobile(bytes, fileName);
    }
  }
  
  /// Download PDF for web platform
  static String _downloadPdfWeb(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
    
    return 'Downloaded: $fileName';
  }
  
  /// Save PDF for mobile/desktop platforms
  static Future<String> _savePdfMobile(Uint8List bytes, String fileName) async {
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
    await file.writeAsBytes(bytes);
    return file.path;
  }
  
  /// Build PDF header
  static pw.Widget _buildHeader(String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue900,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Text(
            'LAPORAN ANALYTICS IDEN',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Informasi Drug Education Network',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Tanggal: $date',
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
      ],
    );
  }
  
  /// Build statistics section with cards
  static pw.Widget _buildStatisticsSection({
    required int totalUsers,
    required int activeUsers,
    required int totalQuizAttempts,
    required double avgQuizScore,
    required int totalArticlesRead,
  }) {
    final engagementRate = (activeUsers / (totalUsers > 0 ? totalUsers : 1) * 100);
    final quizPerUser = totalQuizAttempts / (activeUsers > 0 ? activeUsers : 1);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Statistik Utama'),
        pw.SizedBox(height: 10),
        
        // Statistics grid
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard('Total Pengguna', totalUsers.toString(), PdfColors.blue),
            _buildStatCard('Pengguna Aktif', activeUsers.toString(), PdfColors.green),
            _buildStatCard('Total Quiz', totalQuizAttempts.toString(), PdfColors.orange),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildStatCard('Nilai Rata-rata', avgQuizScore.toStringAsFixed(1), PdfColors.purple),
            _buildStatCard('Artikel Dibaca', totalArticlesRead.toString(), PdfColors.teal),
            _buildStatCard('Engagement', '${engagementRate.toStringAsFixed(1)}%', PdfColors.pink),
          ],
        ),
        pw.SizedBox(height: 15),
        
        // Additional metrics
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Metrik Tambahan',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Quiz per Pengguna Aktif:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('${quizPerUser.toStringAsFixed(1)} quiz', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Engagement Rate:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('${engagementRate.toStringAsFixed(1)}%', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Build statistics card
  static pw.Widget _buildStatCard(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        margin: const pw.EdgeInsets.only(right: 5),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 2),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build section title
  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
    );
  }
  
  /// Build users summary table
  static pw.Widget _buildUsersSummaryTable(List<Map<String, dynamic>> users) {
    // Take top 20 users
    final topUsers = users.take(20).toList();
    
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue100),
          children: [
            _buildTableCell('No', isHeader: true),
            _buildTableCell('Nama', isHeader: true),
            _buildTableCell('Email', isHeader: true),
            _buildTableCell('Artikel Dibaca', isHeader: true),
          ],
        ),
        // Data rows
        ...topUsers.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          return pw.TableRow(
            decoration: index.isEven
                ? const pw.BoxDecoration(color: PdfColors.grey100)
                : null,
            children: [
              _buildTableCell((index + 1).toString()),
              _buildTableCell(user['name']?.toString() ?? 'N/A'),
              _buildTableCell(user['email']?.toString() ?? 'N/A'),
              _buildTableCell((user['articles_read'] ?? 0).toString()),
            ],
          );
        }).toList(),
      ],
    );
  }
  
  /// Build quiz results table
  static pw.Widget _buildQuizResultsTable(List<Map<String, dynamic>> results) {
    // Take latest 20 results
    final latestResults = results.take(20).toList();
    
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green100),
          children: [
            _buildTableCell('No', isHeader: true),
            _buildTableCell('User ID', isHeader: true),
            _buildTableCell('Quiz ID', isHeader: true),
            _buildTableCell('Score', isHeader: true),
            _buildTableCell('Tanggal', isHeader: true),
          ],
        ),
        // Data rows
        ...latestResults.asMap().entries.map((entry) {
          final index = entry.key;
          final result = entry.value;
          final createdAt = result['created_at'] != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(result['created_at']))
              : 'N/A';
          
          return pw.TableRow(
            decoration: index.isEven
                ? const pw.BoxDecoration(color: PdfColors.grey100)
                : null,
            children: [
              _buildTableCell((index + 1).toString()),
              _buildTableCell(result['user_id']?.toString().substring(0, 8) ?? 'N/A'),
              _buildTableCell(result['quiz_id']?.toString().substring(0, 8) ?? 'N/A'),
              _buildTableCell((result['score'] ?? 0).toString()),
              _buildTableCell(createdAt),
            ],
          );
        }).toList(),
      ],
    );
  }
  
  /// Build table cell
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.left,
      ),
    );
  }
  
  /// Build footer
  static pw.Widget _buildFooter(String adminName, String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Dibuat oleh: $adminName',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Tanggal: $date',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
            pw.Text(
              'IDEN App - Admin Dashboard',
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey700,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
