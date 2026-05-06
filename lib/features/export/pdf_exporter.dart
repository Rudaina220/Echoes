import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../../db/database.dart';

class PdfExporter {
  // mirrors the _images getter in MemoryCard
  List<String> _parsePaths(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    return raw.split(',').where((s) => s.isNotEmpty).toList();
  }

  Future<void> export(List<Memory> memories) async {
    final doc = pw.Document();

    final List<({Memory memory, List<pw.MemoryImage> images})> entries = [];

    for (final m in memories) {
      final images = <pw.MemoryImage>[];
      for (final path in _parsePaths(m.imagePaths)) {
        final file = File(path);
        if (await file.exists()) {
          images.add(pw.MemoryImage(await file.readAsBytes()));
        }
      }
      entries.add((memory: m, images: images));
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Echoes — Memory Export',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.pink800,
              ),
            ),
            pw.Text(
              'Exported on ${DateTime.now().toLocal().toString().substring(0, 16)}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
            pw.Divider(color: PdfColors.pink200, thickness: 1.5),
            pw.SizedBox(height: 4),
          ],
        ),
        build: (ctx) => [
          for (final entry in entries) ...[
            _buildMemoryCard(entry.memory, entry.images),
            pw.SizedBox(height: 20),
          ],
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'echoes_export.pdf'));
    await file.writeAsBytes(await doc.save());
    await Share.shareXFiles([XFile(file.path)], text: 'My Echoes memories export');
  }

  pw.Widget _buildMemoryCard(Memory m, List<pw.MemoryImage> images) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.pink100, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: PdfColors.pink50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  m.title,
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.pink900,
                  ),
                ),
              ),
              pw.Text(
                m.createdAt.toLocal().toString().substring(0, 16),
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(m.note, style: const pw.TextStyle(fontSize: 12)),
          if (m.latitude != null && m.longitude != null) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                border: pw.Border.all(color: PdfColors.pink200),
              ),
              child: pw.Text(
                'Location: ${m.latitude!.toStringAsFixed(5)}, ${m.longitude!.toStringAsFixed(5)}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey700),
              ),
            ),
          ],
          if (images.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: images
                  .map((img) => pw.ClipRRect(
                horizontalRadius: 4,
                verticalRadius: 4,
                child: pw.Image(img, width: 150, height: 110, fit: pw.BoxFit.cover),
              ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}