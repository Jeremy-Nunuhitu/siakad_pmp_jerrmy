import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/siakad_models.dart';
import '../services/mock_service.dart';

class PdfService {
  static Future<void> printKRS({
    required BuildContext context,
    required String mahasiswaId,
    required MockService service,
    int? semester,
  }) async {
    final mahasiswa = service.mahasiswa.firstWhere(
      (m) => m.nim == mahasiswaId,
      orElse: () => Mahasiswa(
        nim: mahasiswaId,
        nama: mahasiswaId,
        jenisKelamin: '-',
        prodiId: '',
        password: '',
        pembimbingAkademikId: '',
      ),
    );
    final prodi = service.prodi.firstWhere(
      (p) => p.id == mahasiswa.prodiId,
      orElse: () => const Prodi(id: '', nama: '-', fakultasId: ''),
    );
    final krsList = service.krs
        .where(
          (k) =>
              k.mahasiswaId == mahasiswaId &&
              (semester == null || k.semester == semester),
        )
        .toList();

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'KARTU RENCANA STUDI (KRS)',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'SIAKAD - Sistem Informasi Akademik',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 12),
              // Student Info
              _infoRow('Nama Mahasiswa', mahasiswa.nama),
              _infoRow('NIM', mahasiswa.nim),
              _infoRow('Program Studi', prodi.nama),
              _infoRow(
                'Semester',
                semester == null ? 'Semua Semester' : '$semester',
              ),
              pw.SizedBox(height: 20),
              // Table
              pw.Text(
                'Mata Kuliah yang Diambil',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FixedColumnWidth(50),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue800,
                    ),
                    children: [
                      _tableHeader('No'),
                      _tableHeader('Mata Kuliah'),
                      _tableHeader('Dosen'),
                      _tableHeader('Jadwal'),
                      _tableHeader('SKS'),
                    ],
                  ),
                  // Data rows
                  ...krsList.asMap().entries.map((entry) {
                    final i = entry.key;
                    final krs = entry.value;
                    final kelas = service.kelas.firstWhere(
                      (k) => k.id == krs.kelasId,
                      orElse: () => const Kelas(
                        id: '',
                        mataKuliahId: '',
                        dosenId: '',
                        kapasitas: 0,
                        hari: '',
                        jam: '',
                        ruangan: '',
                      ),
                    );
                    final mkName = kelas.mataKuliahId.isNotEmpty
                        ? service.getMataKuliahName(kelas.mataKuliahId)
                        : '-';
                    final dosenName = kelas.dosenId.isNotEmpty
                        ? service.getDosenPengajarNames(kelas.id)
                        : '-';
                    final mk = service.mataKuliah.firstWhere(
                      (m) => m.kode == kelas.mataKuliahId,
                      orElse: () => const MataKuliah(
                        kode: '',
                        nama: '',
                        sks: 0,
                        prodiId: '',
                      ),
                    );
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: i % 2 == 0 ? PdfColors.grey100 : PdfColors.white,
                      ),
                      children: [
                        _tableCell('${i + 1}', center: true),
                        _tableCell(mkName),
                        _tableCell(dosenName),
                        _tableCell(
                          '${kelas.hari}, ${kelas.jam}\n${service.getRuanganName(kelas.ruangan)}',
                        ),
                        _tableCell('${mk.sks}', center: true),
                      ],
                    );
                  }),
                  // Total row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                    children: [
                      _tableCell('', center: true),
                      _tableCell('Total SKS', bold: true),
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell(
                        '${krsList.fold<int>(0, (sum, krs) {
                          final kelas = service.kelas.firstWhere(
                            (k) => k.id == krs.kelasId,
                            orElse: () => const Kelas(id: '', mataKuliahId: '', dosenId: '', kapasitas: 0, hari: '', jam: '', ruangan: ''),
                          );
                          final mk = service.mataKuliah.firstWhere(
                            (m) => m.kode == kelas.mataKuliahId,
                            orElse: () => const MataKuliah(kode: '', nama: '', sks: 0, prodiId: ''),
                          );
                          return sum + mk.sks;
                        })}',
                        bold: true,
                        center: true,
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              // Footer / Signature
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        'Disetujui oleh,',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 50),
                      pw.Text(
                        '(_________________)',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text('Dosen Wali', style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await _openPdf(
      context: context,
      document: doc,
      name: semester == null
          ? 'KRS_${mahasiswa.nim}'
          : 'KRS_${mahasiswa.nim}_semester_$semester',
    );
  }

  static Future<void> printKHS({
    required BuildContext context,
    required String mahasiswaId,
    required MockService service,
    int? semester,
  }) async {
    final mahasiswa = service.mahasiswa.firstWhere(
      (m) => m.nim == mahasiswaId,
      orElse: () => Mahasiswa(
        nim: mahasiswaId,
        nama: mahasiswaId,
        jenisKelamin: '-',
        prodiId: '',
        password: '',
        pembimbingAkademikId: '',
      ),
    );
    final prodi = service.prodi.firstWhere(
      (p) => p.id == mahasiswa.prodiId,
      orElse: () => const Prodi(id: '', nama: '-', fakultasId: ''),
    );
    final nilaiList = service.nilai
        .where(
          (n) =>
              n.mahasiswaId == mahasiswaId &&
              (semester == null || n.semester == semester),
        )
        .toList();
    final totalSks = nilaiList.fold<int>(0, (sum, n) {
      final kelas = service.kelas.firstWhere(
        (k) => k.id == n.kelasId,
        orElse: () => const Kelas(
          id: '',
          mataKuliahId: '',
          dosenId: '',
          kapasitas: 0,
          hari: '',
          jam: '',
          ruangan: '',
        ),
      );
      final mk = service.mataKuliah.firstWhere(
        (m) => m.kode == kelas.mataKuliahId,
        orElse: () => const MataKuliah(kode: '', nama: '', sks: 0, prodiId: ''),
      );
      return sum + mk.sks;
    });

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'KARTU HASIL STUDI (KHS)',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'SIAKAD - Sistem Informasi Akademik',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 12),
              _infoRow('Nama Mahasiswa', mahasiswa.nama),
              _infoRow('NIM', mahasiswa.nim),
              _infoRow('Program Studi', prodi.nama),
              _infoRow(
                'Semester',
                semester == null ? 'Semua Semester' : '$semester',
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Hasil Nilai',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40),
                  1: const pw.FlexColumnWidth(2.4),
                  2: const pw.FixedColumnWidth(50),
                  3: const pw.FixedColumnWidth(46),
                  4: const pw.FixedColumnWidth(46),
                  5: const pw.FixedColumnWidth(46),
                  6: const pw.FixedColumnWidth(46),
                  7: const pw.FixedColumnWidth(54),
                  8: const pw.FixedColumnWidth(44),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue800,
                    ),
                    children: [
                      _tableHeader('No'),
                      _tableHeader('Mata Kuliah'),
                      _tableHeader('SKS'),
                      _tableHeader('Tugas'),
                      _tableHeader('UTS'),
                      _tableHeader('UAS'),
                      _tableHeader('Soft'),
                      _tableHeader('Final'),
                      _tableHeader('Huruf'),
                    ],
                  ),
                  ...nilaiList.asMap().entries.map((entry) {
                    final i = entry.key;
                    final n = entry.value;
                    final kelas = service.kelas.firstWhere(
                      (k) => k.id == n.kelasId,
                      orElse: () => const Kelas(
                        id: '',
                        mataKuliahId: '',
                        dosenId: '',
                        kapasitas: 0,
                        hari: '',
                        jam: '',
                        ruangan: '',
                      ),
                    );
                    final mkName = kelas.mataKuliahId.isNotEmpty
                        ? service.getMataKuliahName(kelas.mataKuliahId)
                        : '-';
                    final mk = service.mataKuliah.firstWhere(
                      (m) => m.kode == kelas.mataKuliahId,
                      orElse: () => const MataKuliah(
                        kode: '',
                        nama: '',
                        sks: 0,
                        prodiId: '',
                      ),
                    );
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: i % 2 == 0 ? PdfColors.grey100 : PdfColors.white,
                      ),
                      children: [
                        _tableCell('${i + 1}', center: true),
                        _tableCell(mkName),
                        _tableCell('${mk.sks}', center: true),
                        _tableCell(
                          n.nilaiTugas.toStringAsFixed(0),
                          center: true,
                        ),
                        _tableCell(n.nilaiUts.toStringAsFixed(0), center: true),
                        _tableCell(n.nilaiUas.toStringAsFixed(0), center: true),
                        _tableCell(
                          n.nilaiSoftskill.toStringAsFixed(0),
                          center: true,
                        ),
                        _tableCell(
                          n.finalBobot.toStringAsFixed(1),
                          center: true,
                        ),
                        _tableCell(n.nilaiHuruf, center: true, bold: true),
                      ],
                    );
                  }),
                  // Total
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                    children: [
                      _tableCell(''),
                      _tableCell('Total', bold: true),
                      _tableCell('$totalSks', bold: true, center: true),
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell(''),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Bobot nilai: Tugas 25%, UTS 25%, UAS 35%, Softskill 15%. Final bobot adalah total nilai berbobot.',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue800),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                  color: PdfColors.blue50,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total SKS Lulus: $totalSks',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'IPK: ${_calcIPK(nilaiList, service)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        'Diketahui oleh,',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 50),
                      pw.Text(
                        '(_________________)',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Kepala Program Studi',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await _openPdf(
      context: context,
      document: doc,
      name: semester == null
          ? 'KHS_${mahasiswa.nim}'
          : 'KHS_${mahasiswa.nim}_semester_$semester',
    );
  }

  static Future<void> printPresensiKelas({
    required BuildContext context,
    required String kelasId,
    required MockService service,
  }) async {
    final kelas = service.kelas.firstWhere((item) => item.id == kelasId);
    final mkName = service.getMataKuliahName(kelas.mataKuliahId);
    final dosenName = service.getDosenPengajarNames(kelas.id);
    final peserta = service.krs
        .where((item) => item.kelasId == kelasId)
        .toList();
    final pertemuan =
        service.pertemuan.where((item) => item.kelasId == kelasId).toList()
          ..sort((a, b) => a.pertemuanKe.compareTo(b.pertemuanKe));

    String statusFor(String mahasiswaId, String pertemuanId) {
      final matches = service.presensi.where(
        (item) =>
            item.mahasiswaId == mahasiswaId && item.pertemuanId == pertemuanId,
      );
      if (matches.isEmpty) return '-';
      return matches.first.statusKehadiran;
    }

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'REKAP PRESENSI PERKULIAHAN',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('SIAKAD - Sistem Informasi Akademik'),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          _infoRow('Mata Kuliah', mkName),
          _infoRow('Dosen', dosenName),
          _infoRow(
            'Jadwal',
            '${kelas.hari}, ${kelas.jam} - ${service.getRuanganName(kelas.ruangan)}',
          ),
          pw.SizedBox(height: 14),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FixedColumnWidth(28),
              1: const pw.FixedColumnWidth(82),
              2: const pw.FlexColumnWidth(2),
              for (int i = 0; i < pertemuan.length; i++)
                i + 3: const pw.FixedColumnWidth(34),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue800),
                children: [
                  _tableHeader('No'),
                  _tableHeader('NIM'),
                  _tableHeader('Nama'),
                  for (final item in pertemuan)
                    _tableHeader('P${item.pertemuanKe}'),
                ],
              ),
              ...peserta.asMap().entries.map((entry) {
                final index = entry.key;
                final krs = entry.value;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: index % 2 == 0 ? PdfColors.grey100 : PdfColors.white,
                  ),
                  children: [
                    _tableCell('${index + 1}', center: true),
                    _tableCell(krs.mahasiswaId, center: true),
                    _tableCell(service.getMahasiswaName(krs.mahasiswaId)),
                    for (final item in pertemuan)
                      _tableCell(
                        statusFor(krs.mahasiswaId, item.id),
                        center: true,
                      ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    await _openPdf(
      context: context,
      document: doc,
      name: 'Presensi_${kelas.id}_${kelas.mataKuliahId}',
    );
  }

  // Helper: IPK calculation
  static String _calcIPK(List<Nilai> nilaiList, MockService service) {
    if (nilaiList.isEmpty) return '0.00';
    double totalBobot = 0;
    int totalSks = 0;
    for (final n in nilaiList) {
      final kelas = service.kelas.firstWhere(
        (k) => k.id == n.kelasId,
        orElse: () => const Kelas(
          id: '',
          mataKuliahId: '',
          dosenId: '',
          kapasitas: 0,
          hari: '',
          jam: '',
          ruangan: '',
        ),
      );
      final mk = service.mataKuliah.firstWhere(
        (m) => m.kode == kelas.mataKuliahId,
        orElse: () => const MataKuliah(kode: '', nama: '', sks: 0, prodiId: ''),
      );
      final bobot = _nilaiHurufToBobot(n.nilaiHuruf);
      totalBobot += bobot * mk.sks;
      totalSks += mk.sks;
    }
    if (totalSks == 0) return '0.00';
    return (totalBobot / totalSks).toStringAsFixed(2);
  }

  static double _nilaiHurufToBobot(String huruf) {
    switch (huruf) {
      case 'A':
        return 4.0;
      case 'B+':
        return 3.5;
      case 'B':
        return 3.0;
      case 'C':
        return 2.0;
      default:
        return 1.0;
    }
  }

  static Future<void> _openPdf({
    required BuildContext context,
    required pw.Document document,
    required String name,
  }) async {
    final bytes = await document.save();
    if (!context.mounted) return;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text('Preview $name')),
            body: PdfPreview(
              build: (format) async => bytes,
              pdfFileName: '$name.pdf',
              canChangePageFormat: false,
              canChangeOrientation: false,
            ),
          ),
        ),
      );
      return;
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: name,
    );
  }

  // PDF widget helpers
  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(': ', style: pw.TextStyle(fontSize: 11)),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 11))),
        ],
      ),
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _tableCell(
    String text, {
    bool center = false,
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }
}
