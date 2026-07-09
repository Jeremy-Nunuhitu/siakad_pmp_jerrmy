import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as xlsx;
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import '../utils/app_helpers.dart';
import '../utils/csv_file_writer.dart';
import '../viewmodels/base_list_viewmodel.dart';
import '../viewmodels/dosen_viewmodel.dart';
import '../viewmodels/fakultas_viewmodel.dart';
import '../viewmodels/kelas_viewmodel.dart';
import '../viewmodels/mahasiswa_viewmodel.dart';
import '../viewmodels/mata_kuliah_viewmodel.dart';
import '../viewmodels/prodi_viewmodel.dart';
import '../viewmodels/ruangan_viewmodel.dart';
import '../widgets/animated_entrance.dart';
import '../widgets/app_scaffold.dart';

class FakultasView extends StatelessWidget {
  const FakultasView({super.key});

  @override
  Widget build(BuildContext context) {
    // Halaman admin universitas: membaca FakultasViewModel,
    // lalu menampilkan daftar fakultas dan dialog tambah fakultas.
    return Consumer<FakultasViewModel>(
      builder: (context, vm, _) {
        return AppScaffold(
          title: 'Kelola Fakultas',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final namaController = TextEditingController();
              final adminUsernameController = TextEditingController();
              final adminPasswordController = TextEditingController();

              await showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Tambah Fakultas & Admin'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: namaController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Fakultas',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Akun Admin Fakultas',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: adminUsernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username Admin (tanpa spasi)',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: adminPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Password Admin',
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () {
                          try {
                            vm.add(
                              namaController.text,
                              adminUsernameController.text,
                              adminPasswordController.text,
                            );
                            showAppMessage(context, vm.message);
                            Navigator.pop(context);
                          } catch (e) {
                            showAppMessage(context, e.toString());
                          }
                        },
                        child: const Text('Simpan'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Fakultas'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SearchableList<Fakultas>(
                items: vm.items,
                hintText: 'Cari nama fakultas atau ID',
                searchableText: (item) => '${item.id} ${item.nama}',
                itemBuilder: (context, item, index) => AnimatedEntrance(
                  delay: Duration(milliseconds: index * 80),
                  child: InfoTile(
                    icon: Icons.account_balance_outlined,
                    title: item.nama,
                    subtitle: 'ID: ${item.id}',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProdiView extends StatelessWidget {
  const ProdiView({required this.fakultasId, super.key});

  final String fakultasId;

  @override
  Widget build(BuildContext context) {
    // Halaman admin fakultas: prodi yang tampil dibatasi oleh fakultasId.
    return Consumer<ProdiViewModel>(
      builder: (context, vm, _) {
        return AppScaffold(
          title: 'Kelola Prodi',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final namaController = TextEditingController();
              final adminUsernameController = TextEditingController();
              final adminPasswordController = TextEditingController();

              await showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Tambah Prodi & Admin'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: namaController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Prodi',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Akun Admin Prodi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: adminUsernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username Admin (tanpa spasi)',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: adminPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Password Admin',
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () {
                          try {
                            vm.add(
                              namaController.text,
                              fakultasId,
                              adminUsernameController.text,
                              adminPasswordController.text,
                            );
                            showAppMessage(context, vm.message);
                            Navigator.pop(context);
                          } catch (e) {
                            showAppMessage(context, e.toString());
                          }
                        },
                        child: const Text('Simpan'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Prodi'),
          ),
          child: Builder(
            builder: (context) {
              final items = vm.items(fakultasId: fakultasId);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SearchableList<Prodi>(
                    items: items,
                    hintText: 'Cari nama prodi, ID, atau fakultas',
                    searchableText: (item) =>
                        '${item.id} ${item.nama} ${item.fakultasId}',
                    itemBuilder: (context, item, index) => AnimatedEntrance(
                      delay: Duration(milliseconds: index * 80),
                      child: InfoTile(
                        icon: Icons.apartment_outlined,
                        title: item.nama,
                        subtitle: 'Fakultas: ${item.fakultasId}',
                        trailing: _CrudMenu(
                          onEdit: () => _editProdi(context, item),
                          onDelete: () => _deleteProdi(context, item.id),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class GlobalDataView extends StatefulWidget {
  const GlobalDataView({super.key});

  @override
  State<GlobalDataView> createState() => _GlobalDataViewState();
}

class _GlobalDataViewState extends State<GlobalDataView> {
  @override
  Widget build(BuildContext context) {
    // Ringkasan data global untuk admin universitas.
    // Semua angka diambil dari MockService agar selalu mengikuti data terbaru.
    final service = context.watch<MockService>();
    final fase = service.faseKrsTahunAktif;
    final now = DateTime.now();
    return AppScaffold(
      title: 'Data Global',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Fase KRS Universitas',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Chip(
                        label: Text(fase?.statusPada(now) ?? 'Belum Dibuka'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fase == null
                        ? 'Belum ada jadwal pengisian KRS untuk ${service.tahunAjaranAktif.label}.'
                        : 'Berlaku untuk seluruh universitas pada ${service.tahunAjaranAktif.label}.\n'
                              'Mulai: ${_formatDateTime(fase.mulai)}\n'
                              'Batas akhir: ${_formatDateTime(fase.berakhir)}',
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _showFaseKrsDialog(context, service),
                        icon: const Icon(Icons.play_circle_outline),
                        label: Text(
                          fase == null ? 'Mulai Fase KRS' : 'Atur Ulang Fase',
                        ),
                      ),
                      if (fase?.aktif == true)
                        OutlinedButton.icon(
                          onPressed: () => _akhiriFaseKrs(context, service),
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text('Akhiri Fase KRS'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _StatRow(label: 'Fakultas', value: '${service.fakultas.length}'),
          _StatRow(label: 'Prodi', value: '${service.prodi.length}'),
          _StatRow(label: 'Mahasiswa', value: '${service.mahasiswa.length}'),
          _StatRow(label: 'Dosen', value: '${service.dosen.length}'),
          _StatRow(label: 'Kelas Dibuka', value: '${service.kelas.length}'),
          _StatRow(label: 'Ruangan', value: '${service.ruangan.length}'),
          _StatRow(
            label: 'Dosen Pengajar',
            value: '${service.dosenPengajar.length}',
          ),
          const SizedBox(height: 14),
          _ActivityLogPanel(logs: service.recentActivityLogs(limit: 8)),
        ],
      ),
    );
  }

  Future<void> _showFaseKrsDialog(
    BuildContext context,
    MockService service,
  ) async {
    final tahunAktif = service.tahunAjaranAktif;
    final faseSebelumnya = service.faseKrsTahunAktif;
    var mulai = faseSebelumnya?.mulai ?? DateTime.now();
    if (mulai.isBefore(tahunAktif.tanggalMulai)) {
      mulai = tahunAktif.tanggalMulai;
    } else if (mulai.isAfter(tahunAktif.tanggalSelesai)) {
      mulai = tahunAktif.tanggalSelesai;
    }
    var berakhir =
        faseSebelumnya?.berakhir ?? mulai.add(const Duration(days: 14));
    if (berakhir.isAfter(tahunAktif.tanggalSelesai)) {
      berakhir = tahunAktif.tanggalSelesai;
    } else if (berakhir.isBefore(mulai)) {
      berakhir = mulai;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Mulai Fase KRS Universitas'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Jadwal ini berlaku untuk seluruh mahasiswa pada ${service.tahunAjaranAktif.label}.',
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Tanggal mulai'),
                  subtitle: Text(_formatDateOnly(mulai)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: mulai,
                      firstDate: tahunAktif.tanggalMulai,
                      lastDate: tahunAktif.tanggalSelesai,
                    );
                    if (selected != null) {
                      setDialogState(() => mulai = selected);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_busy_outlined),
                  title: const Text('Batas akhir'),
                  subtitle: Text('${_formatDateOnly(berakhir)} pukul 23:59'),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: berakhir.isBefore(mulai) ? mulai : berakhir,
                      firstDate: mulai,
                      lastDate: tahunAktif.tanggalSelesai,
                    );
                    if (selected != null) {
                      setDialogState(() => berakhir = selected);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                try {
                  final message = service.mulaiFaseKrs(
                    mulai: mulai,
                    berakhir: berakhir,
                  );
                  Navigator.pop(dialogContext);
                  if (mounted) {
                    setState(() {});
                    showAppMessage(this.context, message);
                  }
                } on StateError catch (error) {
                  showAppMessage(context, error.message);
                }
              },
              child: const Text('Mulai Fase'),
            ),
          ],
        ),
      ),
    );
  }

  void _akhiriFaseKrs(BuildContext context, MockService service) {
    try {
      final message = service.akhiriFaseKrs();
      setState(() {});
      showAppMessage(context, message);
    } on StateError catch (error) {
      showAppMessage(context, error.message);
    }
  }
}

class _AcademicExportPanel extends StatelessWidget {
  const _AcademicExportPanel({required this.service});

  final MockService service;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _PanelIcon(
                  icon: Icons.inventory_2_outlined,
                  color: scheme.tertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pusat Template dan Ekspor',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Workbook lengkap, template per data, dan export CSV tersedia dalam satu grid.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () =>
                      _saveFullXlsxTemplate(context, service: service),
                  icon: const Icon(Icons.dataset_outlined),
                  label: const Text('Workbook Master'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 1280
                    ? 4
                    : width >= 920
                    ? 3
                    : width >= 620
                    ? 2
                    : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: AcademicExportType.values.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 150,
                  ),
                  itemBuilder: (context, index) => _ExportResourceCard(
                    type: AcademicExportType.values[index],
                    service: service,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportResourceCard extends StatelessWidget {
  const _ExportResourceCard({required this.type, required this.service});

  final AcademicExportType type;
  final MockService service;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SmallBadge(icon: _typeIcon(type), color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    type.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _saveXlsxTemplate(
                      context,
                      service: service,
                      type: type,
                    ),
                    icon: const Icon(Icons.table_chart_outlined, size: 18),
                    label: const Text('XLSX'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _saveCsv(
                      context,
                      fileName: type.fileName,
                      contents: service.academicCsvTemplate(type),
                    ),
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text('CSV'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () => _saveCsv(
                  context,
                  fileName: 'export_${type.fileName}',
                  contents: service.exportAcademicCsv(type),
                ),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Export Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityLogPanel extends StatelessWidget {
  const _ActivityLogPanel({required this.logs});

  final List<ActivityLog> logs;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.manage_history_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Log Aktivitas Terbaru',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (logs.isEmpty)
              const Text('Belum ada aktivitas yang tercatat.')
            else
              for (final log in logs)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history_outlined),
                  title: Text('${log.action} - ${log.target}'),
                  subtitle: Text(
                    '${log.description}\n${log.actorName} (${log.role}) - ${_formatDateTime(log.createdAt)}',
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class ImportExportDataView extends StatelessWidget {
  const ImportExportDataView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<MockService>();
    return AppScaffold(
      title: 'Import dan Export Data',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ImportExportHero(service: service),
          const SizedBox(height: 14),
          _AcademicImportPanel(service: service),
          const SizedBox(height: 14),
          _AcademicExportPanel(service: service),
        ],
      ),
    );
  }
}

class _ImportExportHero extends StatelessWidget {
  const _ImportExportHero({required this.service});

  final MockService service;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.45),
          border: Border(left: BorderSide(color: scheme.primary, width: 5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stats = Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroStat(
                    label: 'Sheet master',
                    value: '${AcademicExportType.values.length}',
                    icon: Icons.dataset_outlined,
                  ),
                  _HeroStat(
                    label: 'Format aktif',
                    value: 'XLSX + CSV',
                    icon: Icons.table_chart_outlined,
                  ),
                  _HeroStat(
                    label: 'Audit log',
                    value: '${service.activityLogs.length}',
                    icon: Icons.manage_history_outlined,
                  ),
                ],
              );
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroLabel(
                    icon: Icons.auto_awesome_outlined,
                    text: 'Academic Data Pipeline',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Import dan Export Data',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kelola template, upload workbook multi-sheet, preview validasi, dan simpan data akademik dari satu ruang kerja.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
              if (constraints.maxWidth < 860) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 18), stats],
                );
              }
              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 20),
                  stats,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AcademicImportPanel extends StatefulWidget {
  const _AcademicImportPanel({required this.service});

  final MockService service;

  @override
  State<_AcademicImportPanel> createState() => _AcademicImportPanelState();
}

class _AcademicImportPanelState extends State<_AcademicImportPanel> {
  AcademicExportType _type = AcademicExportType.mahasiswa;
  AcademicImportMode _mode = AcademicImportMode.createOnly;
  String? _selectedFileName;
  Map<AcademicExportType, List<Map<String, String>>> _workbookRows = const {};
  AcademicImportPreview? _preview;
  List<String> _parseErrors = const [];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canImport = _preview?.canImport == true;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PanelIcon(
                  icon: Icons.cloud_upload_outlined,
                  color: scheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import Workbench',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pilih sumber, cek mode import, validasi workbook, lalu simpan saat semua data siap.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: canImport ? _importPreview : null,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Simpan Import'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 980;
                final config = _ImportConfigPanel(
                  selectedType: _type,
                  mode: _mode,
                  selectedFileName: _selectedFileName,
                  parseErrors: _parseErrors,
                  onTypeChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _type = value;
                      _selectedFileName = null;
                      _workbookRows = const {};
                      _preview = null;
                      _parseErrors = const [];
                    });
                  },
                  onModeChanged: (value) {
                    if (value == null) return;
                    setState(() => _mode = value);
                    _refreshPreview();
                  },
                  onPickFile: _pickImportFile,
                );
                final validation = _ValidationPanel(
                  preview: _preview,
                  onShowErrors: _showPreviewErrors,
                );
                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [config, const SizedBox(height: 12), validation],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: config),
                    const SizedBox(width: 12),
                    Expanded(flex: 4, child: validation),
                  ],
                );
              },
            ),
            if (_preview != null) ...[
              const SizedBox(height: 16),
              _ImportPreviewTable(preview: _preview!),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickImportFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xlsx'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    final file = result.files.single;
    try {
      final rows = _workbookRowsFromImportFile(file, selectedType: _type);
      final preview = widget.service.previewAcademicWorkbook(rows, mode: _mode);
      setState(() {
        _selectedFileName = file.name;
        _workbookRows = rows;
        _preview = preview;
        _parseErrors = const [];
      });
    } on StateError catch (error) {
      setState(() {
        _selectedFileName = file.name;
        _workbookRows = const {};
        _preview = null;
        _parseErrors = [error.message];
      });
    } catch (error) {
      setState(() {
        _selectedFileName = file.name;
        _workbookRows = const {};
        _preview = null;
        _parseErrors = ['$error'];
      });
    }
  }

  void _refreshPreview() {
    if (_workbookRows.isEmpty) return;
    final preview = widget.service.previewAcademicWorkbook(
      _workbookRows,
      mode: _mode,
    );
    setState(() => _preview = preview);
  }

  void _importPreview() {
    final preview = _preview;
    if (preview == null) return;
    final result = widget.service.importAcademicPreview(preview);
    showAppMessage(context, result.message);
    if (result.errors.isNotEmpty) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Catatan Import'),
          content: SizedBox(
            width: 560,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: result.errors.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) => Text(result.errors[index]),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }
    setState(() {
      _selectedFileName = null;
      _workbookRows = const {};
      _preview = null;
      _parseErrors = const [];
    });
  }

  void _showPreviewErrors() {
    final preview = _preview;
    if (preview == null) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Error Import'),
        content: SizedBox(
          width: 620,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: preview.errorMessages.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => Text(preview.errorMessages[index]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _ImportConfigPanel extends StatelessWidget {
  const _ImportConfigPanel({
    required this.selectedType,
    required this.mode,
    required this.selectedFileName,
    required this.parseErrors,
    required this.onTypeChanged,
    required this.onModeChanged,
    required this.onPickFile,
  });

  final AcademicExportType selectedType;
  final AcademicImportMode mode;
  final String? selectedFileName;
  final List<String> parseErrors;
  final ValueChanged<AcademicExportType?> onTypeChanged;
  final ValueChanged<AcademicImportMode?> onModeChanged;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _StepChip(number: '1', text: 'Pilih data'),
                _StepChip(number: '2', text: 'Mode import'),
                _StepChip(number: '3', text: 'Upload dan validasi'),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AcademicExportType>(
              initialValue: selectedType,
              decoration: const InputDecoration(
                labelText: 'Jenis Data',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                for (final type in AcademicExportType.values)
                  DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: onTypeChanged,
            ),
            const SizedBox(height: 12),
            SegmentedButton<AcademicImportMode>(
              segments: [
                for (final item in AcademicImportMode.values)
                  ButtonSegment(
                    value: item,
                    icon: Icon(
                      item == AcademicImportMode.createOnly
                          ? Icons.add_circle_outline
                          : Icons.sync_alt_outlined,
                    ),
                    label: Text(item.label),
                  ),
              ],
              selected: {mode},
              onSelectionChanged: (value) => onModeChanged(value.first),
            ),
            const SizedBox(height: 14),
            _UploadZone(
              fileName: selectedFileName,
              hasError: parseErrors.isNotEmpty,
              onPickFile: onPickFile,
            ),
            if (parseErrors.isNotEmpty) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: scheme.error.withValues(alpha: 0.35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    parseErrors.take(3).join('\n'),
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ValidationPanel extends StatelessWidget {
  const _ValidationPanel({required this.preview, required this.onShowErrors});

  final AcademicImportPreview? preview;
  final VoidCallback onShowErrors;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final preview = this.preview;
    final ready = preview?.canImport == true;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ready
            ? scheme.primaryContainer.withValues(alpha: 0.25)
            : scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ready
              ? scheme.primary.withValues(alpha: 0.35)
              : scheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _SmallBadge(
                  icon: ready
                      ? Icons.verified_outlined
                      : Icons.rule_folder_outlined,
                  color: ready ? scheme.primary : scheme.outline,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    preview == null
                        ? 'Menunggu file'
                        : ready
                        ? 'Siap disimpan'
                        : 'Perlu diperbaiki',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (preview != null && preview.errors > 0)
                  TextButton.icon(
                    onPressed: onShowErrors,
                    icon: const Icon(Icons.report_problem_outlined, size: 18),
                    label: Text('${preview.errors} error'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              preview == null
                  ? 'Upload file CSV/XLSX untuk melihat hasil validasi sebelum data masuk ke sistem.'
                  : ready
                  ? 'Semua validasi fatal lolos. Data baru dan update akan mengikuti mode import yang dipilih.'
                  : 'Sistem menemukan error pada workbook. Buka detail error, perbaiki file, lalu upload ulang.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            if (preview == null)
              const _EmptyValidationState()
            else
              _ImportPreviewSummary(preview: preview),
          ],
        ),
      ),
    );
  }
}

class _UploadZone extends StatelessWidget {
  const _UploadZone({
    required this.fileName,
    required this.hasError,
    required this.onPickFile,
  });

  final String? fileName;
  final bool hasError;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = hasError ? scheme.error : scheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPickFile,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _SmallBadge(icon: Icons.file_open_outlined, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName ?? 'Pilih file untuk divalidasi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      fileName == null
                          ? 'Mendukung workbook XLSX multi-sheet dan CSV lama.'
                          : 'Klik untuk mengganti file import.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onPickFile,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Browse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyValidationState extends StatelessWidget {
  const _EmptyValidationState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MetricPill(
          label: 'Valid',
          value: '-',
          icon: Icons.check_circle_outline,
          color: scheme.outline,
        ),
        const SizedBox(height: 8),
        _MetricPill(
          label: 'Error',
          value: '-',
          icon: Icons.error_outline,
          color: scheme.outline,
        ),
        const SizedBox(height: 8),
        _MetricPill(
          label: 'Dibuat / Update',
          value: '-',
          icon: Icons.sync_outlined,
          color: scheme.outline,
        ),
      ],
    );
  }
}

class _ImportPreviewSummary extends StatelessWidget {
  const _ImportPreviewSummary({required this.preview});

  final AcademicImportPreview preview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MetricPill(
          label: 'Baris Valid',
          value: '${preview.validRows}',
          icon: Icons.check_circle_outline,
          color: scheme.primary,
        ),
        const SizedBox(height: 8),
        _MetricPill(
          label: 'Baris Error',
          value: '${preview.errors}',
          icon: Icons.error_outline,
          color: preview.errors == 0 ? scheme.primary : scheme.error,
        ),
        const SizedBox(height: 8),
        _MetricPill(
          label: 'Dibuat',
          value: '${preview.created}',
          icon: Icons.add_circle_outline,
          color: scheme.tertiary,
        ),
        const SizedBox(height: 8),
        _MetricPill(
          label: 'Diperbarui',
          value: '${preview.updated}',
          icon: Icons.update_outlined,
          color: scheme.secondary,
        ),
        const SizedBox(height: 8),
        _MetricPill(
          label: 'Dilewati',
          value: '${preview.skipped}',
          icon: Icons.block_outlined,
          color: scheme.outline,
        ),
      ],
    );
  }
}

class _ImportPreviewTable extends StatelessWidget {
  const _ImportPreviewTable({required this.preview});

  final AcademicImportPreview preview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rows = preview.rows.take(12).toList();
    if (rows.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Belum ada baris untuk dipreview.'),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                _SmallBadge(
                  icon: Icons.preview_outlined,
                  color: scheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Preview Validasi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${rows.length} dari ${preview.rows.length} baris',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                scheme.surfaceContainerHighest.withValues(alpha: 0.55),
              ),
              columns: const [
                DataColumn(label: Text('Sheet')),
                DataColumn(label: Text('Baris')),
                DataColumn(label: Text('Aksi')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Data / Error')),
              ],
              rows: [
                for (final row in rows)
                  DataRow(
                    cells: [
                      DataCell(Text(row.sheetName)),
                      DataCell(Text('${row.rowNumber}')),
                      DataCell(
                        _TinyStatusChip(
                          label: _actionLabel(row.action),
                          icon: _actionIcon(row.action),
                          color: _actionColor(context, row.action),
                        ),
                      ),
                      DataCell(
                        _TinyStatusChip(
                          label: row.hasError ? 'Error' : 'Valid',
                          icon: row.hasError
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          color: row.hasError ? scheme.error : scheme.primary,
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 360,
                          child: Text(
                            row.hasError
                                ? row.error!
                                : row.row.entries
                                      .take(5)
                                      .map(
                                        (entry) =>
                                            '${entry.key}: ${entry.value}',
                                      )
                                      .join(', '),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _actionLabel(AcademicImportAction action) {
    switch (action) {
      case AcademicImportAction.created:
        return 'Buat';
      case AcademicImportAction.updated:
        return 'Update';
      case AcademicImportAction.skipped:
        return 'Lewati';
    }
  }

  static IconData _actionIcon(AcademicImportAction action) {
    switch (action) {
      case AcademicImportAction.created:
        return Icons.add_circle_outline;
      case AcademicImportAction.updated:
        return Icons.update_outlined;
      case AcademicImportAction.skipped:
        return Icons.block_outlined;
    }
  }

  static Color _actionColor(BuildContext context, AcademicImportAction action) {
    final scheme = Theme.of(context).colorScheme;
    switch (action) {
      case AcademicImportAction.created:
        return scheme.tertiary;
      case AcademicImportAction.updated:
        return scheme.secondary;
      case AcademicImportAction.skipped:
        return scheme.outline;
    }
  }
}

class _PanelIcon extends StatelessWidget {
  const _PanelIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: SizedBox(width: 44, height: 44, child: Icon(icon, color: color)),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _HeroLabel extends StatelessWidget {
  const _HeroLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: scheme.primary),
            const SizedBox(width: 6),
            Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: SizedBox(
        width: 150,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: scheme.primary, size: 20),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: scheme.primary,
              child: Text(
                number,
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyStatusChip extends StatelessWidget {
  const _TinyStatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _typeIcon(AcademicExportType type) {
  switch (type) {
    case AcademicExportType.fakultas:
      return Icons.account_balance_outlined;
    case AcademicExportType.prodi:
      return Icons.school_outlined;
    case AcademicExportType.ruangan:
      return Icons.meeting_room_outlined;
    case AcademicExportType.dosen:
      return Icons.badge_outlined;
    case AcademicExportType.mahasiswa:
      return Icons.groups_outlined;
    case AcademicExportType.mataKuliah:
      return Icons.menu_book_outlined;
    case AcademicExportType.kelas:
      return Icons.event_seat_outlined;
    case AcademicExportType.nilai:
      return Icons.fact_check_outlined;
  }
}

Future<void> _saveCsv(
  BuildContext context, {
  required String fileName,
  required String contents,
}) async {
  final bytes = Uint8List.fromList(utf8.encode(contents));
  final savedPath = await FilePicker.saveFile(
    dialogTitle: 'Simpan $fileName',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: const ['csv'],
    bytes: bytes,
  );
  await writeCsvFile(savedPath, bytes);
  if (context.mounted && savedPath != null) {
    showAppMessage(context, 'File berhasil disimpan: $fileName');
  }
}

Future<void> _saveXlsxTemplate(
  BuildContext context, {
  required MockService service,
  required AcademicExportType type,
}) async {
  final bytes = _xlsxBytes({
    type.sheetName: [service.academicXlsxTemplate(type)],
  });
  await _saveXlsxBytes(
    context,
    fileName: type.fileName.replaceAll('.csv', '.xlsx'),
    bytes: bytes,
  );
}

Future<void> _saveFullXlsxTemplate(
  BuildContext context, {
  required MockService service,
}) async {
  final sheets = <String, List<List<String>>>{
    'Petunjuk': [
      ['Urutan Import'],
      ['1. Fakultas'],
      ['2. Prodi'],
      ['3. Ruangan'],
      ['4. Dosen'],
      ['5. Mahasiswa'],
      ['6. MataKuliah'],
      ['7. Kelas'],
      ['8. Nilai'],
      ['Catatan'],
      ['Gunakan dosenIds dipisah koma, contoh d-01,d-02'],
    ],
    for (final entry in service.academicFullWorkbookTemplate().entries)
      entry.key.sheetName: [entry.value],
  };
  await _saveXlsxBytes(
    context,
    fileName: 'template_master_akademik.xlsx',
    bytes: _xlsxBytes(sheets),
  );
}

Uint8List _xlsxBytes(Map<String, List<List<String>>> sheets) {
  final workbook = xlsx.Excel.createExcel();
  for (final entry in sheets.entries) {
    final sheet = workbook[entry.key];
    for (final row in entry.value) {
      sheet.appendRow([for (final cell in row) xlsx.TextCellValue(cell)]);
    }
  }
  if (workbook.tables.containsKey('Sheet1') && !sheets.containsKey('Sheet1')) {
    workbook.delete('Sheet1');
  }
  return Uint8List.fromList(workbook.encode() ?? const []);
}

Future<void> _saveXlsxBytes(
  BuildContext context, {
  required String fileName,
  required Uint8List bytes,
}) async {
  final savedPath = await FilePicker.saveFile(
    dialogTitle: 'Simpan $fileName',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: const ['xlsx'],
    bytes: bytes,
  );
  await writeCsvFile(savedPath, bytes);
  if (context.mounted && savedPath != null) {
    showAppMessage(context, 'File berhasil disimpan: $fileName');
  }
}

Map<AcademicExportType, List<Map<String, String>>> _workbookRowsFromImportFile(
  PlatformFile file, {
  required AcademicExportType selectedType,
}) {
  final bytes = file.bytes;
  if (bytes == null || bytes.isEmpty) {
    throw StateError('File tidak dapat dibaca');
  }
  final extension = file.extension?.toLowerCase();
  return switch (extension) {
    'csv' => {selectedType: _rowsFromTable(_parseCsvRows(utf8.decode(bytes)))},
    'xlsx' => _parseXlsxWorkbookRows(bytes, selectedType: selectedType),
    _ => throw StateError('Format file harus CSV atau XLSX'),
  };
}

Map<AcademicExportType, List<Map<String, String>>> _parseXlsxWorkbookRows(
  Uint8List bytes, {
  required AcademicExportType selectedType,
}) {
  final workbook = xlsx.Excel.decodeBytes(bytes);
  if (workbook.tables.isEmpty) throw StateError('Workbook XLSX kosong');
  final result = <AcademicExportType, List<Map<String, String>>>{};
  for (final type in AcademicExportType.values) {
    final sheet = _sheetByNormalizedName(workbook, type.sheetName);
    if (sheet == null) continue;
    final rows = _rowsFromTable([
      for (final row in sheet.rows)
        [for (final cell in row) cell?.value.toString().trim() ?? ''],
    ]);
    if (rows.isNotEmpty) result[type] = rows;
  }
  if (result.isNotEmpty) return result;

  final selectedSheet = workbook.tables.values.first;
  return {
    selectedType: _rowsFromTable([
      for (final row in selectedSheet.rows)
        [for (final cell in row) cell?.value.toString().trim() ?? ''],
    ]),
  };
}

xlsx.Sheet? _sheetByNormalizedName(xlsx.Excel workbook, String name) {
  final normalized = _normalizeSheetName(name);
  for (final entry in workbook.tables.entries) {
    if (_normalizeSheetName(entry.key) == normalized) return entry.value;
  }
  return null;
}

String _normalizeSheetName(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

List<List<String>> _parseCsvRows(String source) {
  final rows = <List<String>>[];
  final row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < source.length; i++) {
    final char = source[i];
    if (char == '"') {
      if (inQuotes && i + 1 < source.length && source[i + 1] == '"') {
        cell.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char == ',' && !inQuotes) {
      row.add(cell.toString());
      cell.clear();
    } else if ((char == '\n' || char == '\r') && !inQuotes) {
      if (char == '\r' && i + 1 < source.length && source[i + 1] == '\n') {
        i++;
      }
      row.add(cell.toString());
      rows.add(List<String>.from(row));
      row.clear();
      cell.clear();
    } else {
      cell.write(char);
    }
  }

  if (cell.isNotEmpty || row.isNotEmpty) {
    row.add(cell.toString());
    rows.add(List<String>.from(row));
  }
  return rows;
}

List<Map<String, String>> _rowsFromTable(List<List<String>> table) {
  final nonEmptyRows = table
      .where((row) => row.any((cell) => cell.trim().isNotEmpty))
      .toList();
  if (nonEmptyRows.isEmpty) throw StateError('File tidak memiliki data');
  final headers = nonEmptyRows.first.map((cell) => cell.trim()).toList();
  if (headers.every((header) => header.isEmpty)) {
    throw StateError('Header kolom wajib ada di baris pertama');
  }

  return [
    for (final row in nonEmptyRows.skip(1))
      {
        for (var index = 0; index < headers.length; index++)
          if (headers[index].isNotEmpty)
            headers[index]: index < row.length ? row[index].trim() : '',
      },
  ];
}

class ProdiScopeDataView extends StatelessWidget {
  const ProdiScopeDataView({required this.fakultasId, super.key});

  final String fakultasId;

  @override
  Widget build(BuildContext context) {
    // Ringkasan ini hanya menghitung data dalam satu fakultas.
    final service = context.watch<MockService>();
    final prodi = service.prodi
        .where((item) => item.fakultasId == fakultasId)
        .toList();

    return AppScaffold(
      title: 'Data Fakultas',
      child: Column(
        children: [
          for (int i = 0; i < prodi.length; i++)
            AnimatedEntrance(
              delay: Duration(milliseconds: i * 80),
              child: InfoTile(
                icon: Icons.apartment_outlined,
                title: prodi[i].nama,
                subtitle: 'Scope fakultas: $fakultasId',
              ),
            ),
        ],
      ),
    );
  }
}

class MahasiswaManagementView extends StatelessWidget {
  const MahasiswaManagementView({required this.prodiId, super.key});

  final String prodiId;

  @override
  Widget build(BuildContext context) {
    final mahasiswaVm = context.watch<MahasiswaViewModel>();
    final service = context.watch<MockService>();

    return AppScaffold(
      title: 'Kelola Mahasiswa',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _quickAddMahasiswa(context, prodiId),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mahasiswa'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PagedSearchableList<Mahasiswa>(
            pageLoader: (query, page, pageSize, sortMode) => mahasiswaVm.pagedItems(
              prodiId: prodiId,
              page: page,
              pageSize: pageSize,
              query: query,
              searchableText: (item) =>
                  '${item.nama} ${item.nim} ${item.jenisKelamin} ${service.getDosenName(item.pembimbingAkademikId)}',
              sortBy: sortMode == _DataSortMode.alphabet
                  ? (first, second) => _compareText(first.nama, second.nama)
                  : null,
              descending: sortMode == _DataSortMode.newest,
            ),
            hintText: 'Cari nama, NIM, jenis kelamin, atau dosen PA',
            itemBuilder: (context, item, index) => InfoTile(
              icon: Icons.groups_outlined,
              title: item.nama,
              subtitle:
                  '${item.nim} - ${item.jenisKelamin} - PA: ${service.getDosenName(item.pembimbingAkademikId)}',
              trailing: _CrudMenu(
                onEdit: () => _editMahasiswa(context, item),
                onDelete: () => _deleteMahasiswa(context, item.nim),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusMahasiswaManagementView extends StatelessWidget {
  const StatusMahasiswaManagementView({required this.prodiId, super.key});

  final String prodiId;

  @override
  Widget build(BuildContext context) {
    final mahasiswaVm = context.watch<MahasiswaViewModel>();
    final service = context.read<MockService>();

    return AppScaffold(
      title: 'Kelola Status Mahasiswa',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Setiap perubahan status wajib disertai bukti PDF/JPG/JPEG/PNG dengan ukuran maksimal 5 MB.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PagedSearchableList<Mahasiswa>(
            pageLoader: (query, page, pageSize, sortMode) =>
                mahasiswaVm.pagedItems(
                  prodiId: prodiId,
                  page: page,
                  pageSize: pageSize,
                  query: query,
                  searchableText: (item) =>
                      '${item.nama} ${item.nim} ${item.status.label}',
                  sortBy: sortMode == _DataSortMode.alphabet
                      ? (first, second) => _compareText(first.nama, second.nama)
                      : null,
                  descending: sortMode == _DataSortMode.newest,
                ),
            hintText: 'Cari nama, NIM, atau status mahasiswa',
            itemBuilder: (context, item, index) => InfoTile(
              icon: Icons.manage_accounts_outlined,
              title: item.nama,
              subtitle: '${item.nim} - Status: ${item.status.label}',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Lihat riwayat status',
                    onPressed: () => _showRiwayatStatus(context, item, service),
                    icon: const Icon(Icons.history_rounded),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _ubahStatusMahasiswa(context, item),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Ubah Status'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _ubahStatusMahasiswa(
  BuildContext context,
  Mahasiswa mahasiswa,
) async {
  final vm = context.read<MahasiswaViewModel>();
  var selectedStatus = StatusMahasiswa.values.firstWhere(
    (status) => status != mahasiswa.status,
  );
  PlatformFile? selectedFile;
  String? fileError;

  await showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Ubah Status ${mahasiswa.nama}'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${mahasiswa.nim} - Status saat ini: ${mahasiswa.status.label}',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<StatusMahasiswa>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status Baru',
                      ),
                      items: [
                        for (final status in StatusMahasiswa.values)
                          if (status != mahasiswa.status)
                            DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedStatus = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: const [
                            'pdf',
                            'jpg',
                            'jpeg',
                            'png',
                          ],
                          withData: true,
                        );
                        if (result == null) return;
                        final file = result.files.single;
                        setState(() {
                          if (file.size > 5 * 1024 * 1024) {
                            selectedFile = null;
                            fileError = 'Ukuran file melebihi batas 5 MB';
                          } else if (file.bytes == null ||
                              file.bytes!.isEmpty) {
                            selectedFile = null;
                            fileError = 'File tidak dapat dibaca';
                          } else {
                            selectedFile = file;
                            fileError = null;
                          }
                        });
                      },
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Upload Bukti Wajib'),
                    ),
                    const SizedBox(height: 8),
                    if (selectedFile != null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.task_outlined),
                        title: Text(selectedFile!.name),
                        subtitle: Text(_formatFileSize(selectedFile!.size)),
                        trailing: IconButton(
                          tooltip: 'Hapus file',
                          onPressed: () => setState(() => selectedFile = null),
                          icon: const Icon(Icons.close),
                        ),
                      )
                    else
                      Text(
                        fileError ??
                            'Format: PDF, JPG, JPEG, PNG. Maksimal 5 MB.',
                        style: TextStyle(
                          color: fileError == null
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: selectedFile?.bytes == null
                    ? null
                    : () {
                        vm.ubahStatus(
                          nim: mahasiswa.nim,
                          statusBaru: selectedStatus,
                          namaBukti: selectedFile!.name,
                          buktiBytes: selectedFile!.bytes!,
                        );
                        showAppMessage(context, vm.message);
                        if ((vm.message ?? '').startsWith(
                          'Status mahasiswa berhasil',
                        )) {
                          Navigator.pop(context);
                        }
                      },
                child: const Text('Simpan Perubahan'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _showRiwayatStatus(
  BuildContext context,
  Mahasiswa mahasiswa,
  MockService service,
) {
  final riwayat = service.getRiwayatStatusMahasiswa(mahasiswa.nim);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Riwayat Status ${mahasiswa.nama}'),
      content: SizedBox(
        width: 560,
        child: riwayat.isEmpty
            ? const Text('Belum ada perubahan status.')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: riwayat.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final item = riwayat[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.description_outlined),
                    title: Text(
                      '${item.statusSebelumnya.label} menjadi ${item.statusBaru.label}',
                    ),
                    subtitle: Text(
                      '${item.namaBukti} (${_formatFileSize(item.ukuranBukti)})\n${_formatDateTime(item.diubahPada)}',
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}

String _formatFileSize(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
  return '${(bytes / 1024).toStringAsFixed(1)} KB';
}

String _formatDateTime(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${twoDigits(value.day)}/${twoDigits(value.month)}/${value.year} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}

String _formatDateOnly(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';

class DosenManagementView extends StatelessWidget {
  const DosenManagementView({required this.prodiId, super.key});

  final String prodiId;

  @override
  Widget build(BuildContext context) {
    final dosenVm = context.watch<DosenViewModel>();

    return AppScaffold(
      title: 'Kelola Dosen',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _quickAddDosen(context, prodiId),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Dosen'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PagedSearchableList<Dosen>(
            pageLoader: (query, page, pageSize, sortMode) => dosenVm.pagedItems(
              prodiId: prodiId,
              page: page,
              pageSize: pageSize,
              query: query,
              searchableText: (item) =>
                  '${item.nama} ${item.nidn} ${item.email} ${item.noHp} ${item.keahlian}',
              sortBy: sortMode == _DataSortMode.alphabet
                  ? (first, second) => _compareText(first.nama, second.nama)
                  : null,
              descending: sortMode == _DataSortMode.newest,
            ),
            hintText: 'Cari nama, NIDN, email, atau keahlian',
            itemBuilder: (context, item, index) => InfoTile(
              icon: Icons.co_present_outlined,
              title: item.nama,
              subtitle: '${item.nidn} - Prodi: ${item.prodiId}',
              trailing: _CrudMenu(
                onEdit: () => _editDosen(context, item),
                onDelete: () => _deleteDosen(context, item.nidn),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MataKuliahManagementView extends StatelessWidget {
  const MataKuliahManagementView({required this.prodiId, super.key});

  final String prodiId;

  @override
  Widget build(BuildContext context) {
    final mkVm = context.watch<MataKuliahViewModel>();

    return AppScaffold(
      title: 'Kelola Mata Kuliah',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _quickAddMataKuliah(context, prodiId),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mata Kuliah'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PagedSearchableList<MataKuliah>(
            pageLoader: (query, page, pageSize, sortMode) => mkVm.pagedItems(
              prodiId: prodiId,
              page: page,
              pageSize: pageSize,
              query: query,
              searchableText: (item) => '${item.kode} ${item.nama} ${item.sks}',
              sortBy: sortMode == _DataSortMode.alphabet
                  ? (first, second) => _compareText(first.nama, second.nama)
                  : null,
              descending: sortMode == _DataSortMode.newest,
            ),
            hintText: 'Cari kode, nama mata kuliah, atau jumlah SKS',
            itemBuilder: (context, item, index) => InfoTile(
              icon: Icons.menu_book_outlined,
              title: item.nama,
              subtitle:
                  '${item.kode} - ${item.sks} SKS - ${item.kategori.label}\n'
                  'Bobot: Tugas ${item.bobotTugas.toStringAsFixed(0)}%, '
                  'UTS ${item.bobotUts.toStringAsFixed(0)}%, '
                  'UAS ${item.bobotUas.toStringAsFixed(0)}%, '
                  'Softskill ${item.bobotSoftskill.toStringAsFixed(0)}%',
              trailing: _CrudMenu(
                onEdit: () => _editMataKuliah(context, item),
                onDelete: () => _deleteMataKuliah(context, item.kode),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RuanganManagementView extends StatelessWidget {
  const RuanganManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final ruanganVm = context.watch<RuanganViewModel>();

    return AppScaffold(
      title: 'Kelola Ruangan',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRuangan(context),
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Tambah Ruangan'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PagedSearchableList<Ruangan>(
            pageLoader: (query, page, pageSize, sortMode) => ruanganVm.pagedItems(
              page: page,
              pageSize: pageSize,
              query: query,
              searchableText: (item) =>
                  '${item.kodeRuangan} ${item.namaRuangan} ${item.kapasitasRuangan} ${item.lokasi}',
              sortBy: sortMode == _DataSortMode.alphabet
                  ? (first, second) =>
                        _compareText(first.namaRuangan, second.namaRuangan)
                  : null,
              descending: sortMode == _DataSortMode.newest,
            ),
            hintText: 'Cari kode, nama ruangan, kapasitas, atau lokasi',
            itemBuilder: (context, item, index) => InfoTile(
              icon: Icons.meeting_room_outlined,
              title: '${item.kodeRuangan} - ${item.namaRuangan}',
              subtitle: 'Kapasitas: ${item.kapasitasRuangan} - ${item.lokasi}',
              trailing: _CrudMenu(
                onEdit: () => _editRuangan(context, item),
                onDelete: () => _deleteRuangan(context, item.kodeRuangan),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KelasManagementView extends StatelessWidget {
  const KelasManagementView({required this.prodiId, super.key});

  final String prodiId;

  @override
  Widget build(BuildContext context) {
    // Kelas dibuka oleh operator prodi dari kombinasi mata kuliah, dosen,
    // jadwal, dan ruangan yang sudah dikelola di menu Ruangan.
    final kelasVm = context.watch<KelasViewModel>();
    final service = context.watch<MockService>();

    return AppScaffold(
      title: 'Kelola Kelas Kuliah',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openKelasDialog(context, prodiId),
        icon: const Icon(Icons.add),
        label: const Text('Buka Kelas'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PagedSearchableList<Kelas>(
            pageLoader: (query, page, pageSize, sortMode) => kelasVm.pagedItems(
              prodiId: prodiId,
              page: page,
              pageSize: pageSize,
              query: query,
              searchableText: (item) =>
                  '${item.id} ${service.getMataKuliahName(item.mataKuliahId)} ${service.getDosenPengajarNames(item.id)} ${item.hari} ${item.jam} ${service.getRuanganName(item.ruangan)}',
              sortBy: sortMode == _DataSortMode.alphabet
                  ? (first, second) => _compareText(first.id, second.id)
                  : null,
              descending: sortMode == _DataSortMode.newest,
            ),
            hintText: 'Cari ID, mata kuliah, dosen, hari, jam, atau ruangan',
            itemBuilder: (context, item, index) => AnimatedEntrance(
              delay: Duration(milliseconds: index * 80),
              child: InfoTile(
                icon: Icons.event_available_outlined,
                title: item.id,
                subtitle:
                    '${service.getMataKuliahName(item.mataKuliahId)}\nDosen: ${service.getDosenPengajarNames(item.id)}\n${item.hari}, ${item.jam} - ${service.getRuanganName(item.ruangan)}\nKapasitas: ${service.getJumlahPesertaKelas(item.id)}/${item.kapasitas}',
                trailing: _CrudMenu(
                  onEdit: () => _editKelas(context, item),
                  onDelete: () => _deleteKelas(context, item.id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProdiUserView extends StatelessWidget {
  const ProdiUserView({required this.prodiId, super.key});

  final String prodiId;

  @override
  Widget build(BuildContext context) {
    // Halaman ini menampilkan akun yang berada dalam scope prodi aktif.
    final service = context.watch<MockService>();

    return AppScaffold(
      title: 'User Prodi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PagedSearchableList<User>(
            pageSize: 5,
            pageLoader: (query, page, pageSize, sortMode) => _pagedProdiUsers(
              service: service,
              prodiId: prodiId,
              query: query,
              page: page,
              pageSize: pageSize,
              sortMode: sortMode,
            ),
            hintText: 'Cari nama, username, role, atau scope',
            itemBuilder: (context, user, index) => InfoTile(
              icon: Icons.person_outline,
              title: user.name,
              subtitle: '${user.username} - ${user.role.label}',
            ),
          ),
        ],
      ),
    );
  }
}

PagedResult<User> _pagedProdiUsers({
  required MockService service,
  required String prodiId,
  required String query,
  required int page,
  required int pageSize,
  required _DataSortMode sortMode,
}) {
  final normalizedQuery = query.toLowerCase().trim();
  final source = _prodiScopedUsers(service, prodiId);
  final filtered = normalizedQuery.isEmpty
      ? source
      : source.where((user) {
          final searchableText =
              '${user.name} ${user.username} ${user.role.label} ${user.scopeId}';
          return searchableText.toLowerCase().contains(normalizedQuery);
        }).toList();

  final ordered = filtered.toList();
  if (sortMode == _DataSortMode.alphabet) {
    ordered.sort((first, second) => _compareText(first.name, second.name));
  }
  final pagedSource = sortMode == _DataSortMode.newest
      ? ordered.reversed.toList()
      : ordered;
  final safePage = page < 0 ? 0 : page;
  final safePageSize = pageSize < 1 ? 5 : pageSize;
  final window = pagedSource
      .skip(safePage * safePageSize)
      .take(safePageSize + 1)
      .toList();

  return PagedResult<User>(
    items: window.take(safePageSize).toList(),
    page: safePage,
    pageSize: safePageSize,
    hasNext: window.length > safePageSize,
  );
}

List<User> _prodiScopedUsers(MockService service, String prodiId) {
  final dosenIds = service.dosen
      .where((dosen) => dosen.prodiId == prodiId)
      .map((dosen) => dosen.nidn)
      .toSet();
  final mahasiswaIds = service.mahasiswa
      .where((mahasiswa) => mahasiswa.prodiId == prodiId)
      .map((mahasiswa) => mahasiswa.nim)
      .toSet();

  return service.users.where((user) {
    return switch (user.role) {
      Role.adminProdi => user.scopeId == prodiId,
      Role.dosen => dosenIds.contains(user.scopeId),
      Role.mahasiswa => mahasiswaIds.contains(user.scopeId),
      _ => false,
    };
  }).toList();
}

class UserManagementView extends StatelessWidget {
  const UserManagementView({required this.currentUser, super.key});

  final User currentUser;

  @override
  Widget build(BuildContext context) {
    // Manajemen user mengikuti role login:
    // admin universitas melihat lebih luas daripada admin fakultas/prodi.
    final service = context.watch<MockService>();

    List<User> visibleUsers = [];
    if (currentUser.role == Role.adminUniversitas) {
      visibleUsers = service.users.toList();
    } else if (currentUser.role == Role.adminFakultas) {
      final myProdiIds = service.prodi
          .where((p) => p.fakultasId == currentUser.scopeId)
          .map((p) => p.id)
          .toSet();

      visibleUsers = service.users.where((u) {
        if (u.id == currentUser.id) return true;
        if (u.role == Role.adminProdi) return myProdiIds.contains(u.scopeId);
        if (u.role == Role.dosen) {
          final matches = service.dosen.where((d) => d.nidn == u.scopeId);
          return matches.isNotEmpty &&
              myProdiIds.contains(matches.first.prodiId);
        }
        if (u.role == Role.mahasiswa) {
          final matches = service.mahasiswa.where((m) => m.nim == u.scopeId);
          return matches.isNotEmpty &&
              myProdiIds.contains(matches.first.prodiId);
        }
        return false;
      }).toList();
    }

    return AppScaffold(
      title: 'User Management',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final userController = TextEditingController();
          final nameController = TextEditingController();
          final scopeController = TextEditingController();
          Role selectedRole = Role.adminProdi;

          await showDialog<void>(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Tambah Admin'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: userController,
                            decoration: const InputDecoration(
                              labelText: 'Username (tanpa spasi)',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap',
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Role>(
                            initialValue: selectedRole,
                            items: [
                              const DropdownMenuItem(
                                value: Role.adminProdi,
                                child: Text('Admin Prodi'),
                              ),
                              if (currentUser.role == Role.adminUniversitas)
                                const DropdownMenuItem(
                                  value: Role.adminFakultas,
                                  child: Text('Admin Fakultas'),
                                ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedRole = val);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Role Admin',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: scopeController,
                            decoration: const InputDecoration(
                              labelText: 'Scope ID (ID Prodi/Fakultas)',
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () {
                          try {
                            final msg = service.addAdmin(
                              userController.text,
                              nameController.text,
                              selectedRole,
                              scopeController.text,
                            );
                            showAppMessage(context, msg);
                            Navigator.pop(context);
                          } catch (e) {
                            showAppMessage(context, e.toString());
                          }
                        },
                        child: const Text('Simpan'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Tambah Admin'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PagedSearchableList<User>(
            pageSize: 10,
            pageLoader: (query, page, pageSize, sortMode) => _pagedUsers(
              visibleUsers,
              query: query,
              page: page,
              pageSize: pageSize,
              sortMode: sortMode,
            ),
            hintText: 'Cari nama, username, role, atau scope',
            itemBuilder: (context, user, index) => InfoTile(
              icon: Icons.admin_panel_settings_outlined,
              title: user.name,
              subtitle: '${user.username} - ${user.role.label}',
            ),
          ),
        ],
      ),
    );
  }
}

PagedResult<User> _pagedUsers(
  List<User> source, {
  required String query,
  required int page,
  required int pageSize,
  required _DataSortMode sortMode,
}) {
  final normalizedQuery = query.toLowerCase().trim();
  final filtered = normalizedQuery.isEmpty
      ? source
      : source.where((user) {
          final text =
              '${user.name} ${user.username} ${user.role.label} ${user.scopeId}';
          return text.toLowerCase().contains(normalizedQuery);
        }).toList();
  filtered.sort(
    sortMode == _DataSortMode.alphabet
        ? (first, second) => _compareText(first.name, second.name)
        : (first, second) => second.id.compareTo(first.id),
  );
  final start = page * pageSize;
  final window = filtered.skip(start).take(pageSize + 1).toList();
  return PagedResult<User>(
    items: window.take(pageSize).toList(),
    page: page,
    pageSize: pageSize,
    hasNext: window.length > pageSize,
  );
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InfoTile(
      icon: Icons.analytics_outlined,
      title: label,
      subtitle: 'Data tersedia di sistem',
      trailing: Text(
        value,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _SearchableList<T> extends StatefulWidget {
  const _SearchableList({
    required this.items,
    required this.searchableText,
    required this.itemBuilder,
    required this.hintText,
  });

  final List<T> items;
  final String Function(T item) searchableText;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String hintText;

  @override
  State<_SearchableList<T>> createState() => _SearchableListState<T>();
}

class _SearchableListState<T> extends State<_SearchableList<T>> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _normalize(_query);
    final filtered = normalizedQuery.isEmpty
        ? widget.items
        : widget.items
              .where(
                (item) => _normalize(
                  widget.searchableText(item),
                ).contains(normalizedQuery),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchField(
          controller: _controller,
          hintText: widget.hintText,
          onChanged: (value) => setState(() => _query = value),
          onClear: _query.isEmpty
              ? null
              : () {
                  _controller.clear();
                  setState(() => _query = '');
                },
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          _EmptySearchResult(query: _query)
        else
          for (int i = 0; i < filtered.length; i++)
            widget.itemBuilder(context, filtered[i], i),
      ],
    );
  }

  String _normalize(String value) => value.toLowerCase().trim();
}

enum _DataSortMode {
  newest('Terbaru'),
  oldest('Terlama'),
  alphabet('Alfabet');

  const _DataSortMode(this.label);

  final String label;
}

typedef _PagedLoader<T> =
    PagedResult<T> Function(
      String query,
      int page,
      int pageSize,
      _DataSortMode sortMode,
    );

int _compareText(String first, String second) {
  return first.toLowerCase().compareTo(second.toLowerCase());
}

class _PagedSearchableList<T> extends StatefulWidget {
  const _PagedSearchableList({
    required this.pageLoader,
    required this.itemBuilder,
    required this.hintText,
    this.pageSize = BaseListViewModel.defaultPageSize,
  });

  final _PagedLoader<T> pageLoader;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String hintText;
  final int pageSize;

  @override
  State<_PagedSearchableList<T>> createState() =>
      _PagedSearchableListState<T>();
}

class _PagedSearchableListState<T> extends State<_PagedSearchableList<T>> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  int _page = 0;
  _DataSortMode _sortMode = _DataSortMode.newest;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.pageLoader(_query, _page, widget.pageSize, _sortMode);
    if (result.items.isEmpty && result.hasPrevious) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _page--);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PagedListToolbar(
          searchField: _SearchField(
            controller: _controller,
            hintText: widget.hintText,
            onChanged: (value) => setState(() {
              _query = value;
              _page = 0;
            }),
            onClear: _query.isEmpty
                ? null
                : () {
                    _controller.clear();
                    setState(() {
                      _query = '';
                      _page = 0;
                    });
                  },
          ),
          sortMode: _sortMode,
          onSortChanged: (value) => setState(() {
            _sortMode = value;
            _page = 0;
          }),
        ),
        const SizedBox(height: 14),
        if (result.items.isEmpty)
          _EmptySearchResult(query: _query)
        else ...[
          for (int i = 0; i < result.items.length; i++)
            widget.itemBuilder(context, result.items[i], i),
          const SizedBox(height: 8),
          _PaginationBar(
            page: result.page,
            pageSize: result.pageSize,
            itemCount: result.items.length,
            hasPrevious: result.hasPrevious,
            hasNext: result.hasNext,
            onPrevious: () => setState(() => _page--),
            onNext: () => setState(() => _page++),
          ),
        ],
      ],
    );
  }
}

class _PagedListToolbar extends StatelessWidget {
  const _PagedListToolbar({
    required this.searchField,
    required this.sortMode,
    required this.onSortChanged,
  });

  final Widget searchField;
  final _DataSortMode sortMode;
  final ValueChanged<_DataSortMode> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final sortField = SizedBox(
      width: 190,
      child: DropdownButtonFormField<_DataSortMode>(
        initialValue: sortMode,
        decoration: const InputDecoration(
          labelText: 'Urutkan',
          prefixIcon: Icon(Icons.sort_rounded),
        ),
        items: [
          for (final mode in _DataSortMode.values)
            DropdownMenuItem(value: mode, child: Text(mode.label)),
        ],
        onChanged: (value) {
          if (value != null) onSortChanged(value);
        },
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [searchField, const SizedBox(height: 10), sortField],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 12),
            sortField,
          ],
        );
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.pageSize,
    required this.itemCount,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int pageSize;
  final int itemCount;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 96),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Halaman ${page + 1} - $itemCount dari maks. $pageSize data',
              style: textStyle,
            ),
          ),
          IconButton(
            tooltip: 'Halaman sebelumnya',
            onPressed: hasPrevious ? onPrevious : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            tooltip: 'Halaman berikutnya',
            onPressed: hasNext ? onNext : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: onClear == null
            ? null
            : IconButton(
                tooltip: 'Bersihkan pencarian',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              Icons.search_off_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                query.trim().isEmpty
                    ? 'Belum ada data yang tersedia'
                    : 'Tidak ada data yang cocok dengan "$query"',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrudMenu extends StatelessWidget {
  const _CrudMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Aksi data',
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Ubah'),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Hapus'),
          ),
        ),
      ],
    );
  }
}

Future<void> _editMahasiswa(BuildContext context, Mahasiswa item) async {
  final vm = context.read<MahasiswaViewModel>();
  final service = context.read<MockService>();
  final nameController = TextEditingController(text: item.nama);
  String jenisKelamin = item.jenisKelamin;
  String pembimbingAkademikId = item.pembimbingAkademikId;
  final dosenProdi = service.dosen
      .where((dosen) => dosen.prodiId == item.prodiId)
      .toList();

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Ubah Mahasiswa ${item.nim}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Mahasiswa',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: jenisKelamin,
                  decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Laki-laki',
                      child: Text('Laki-laki'),
                    ),
                    DropdownMenuItem(
                      value: 'Perempuan',
                      child: Text('Perempuan'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => jenisKelamin = value);
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: pembimbingAkademikId,
                  decoration: const InputDecoration(labelText: 'Dosen PA'),
                  items: [
                    for (final dosen in dosenProdi)
                      DropdownMenuItem(
                        value: dosen.nidn,
                        child: Text(dosen.nama),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => pembimbingAkademikId = value);
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              vm.update(
                item.nim,
                nameController.text,
                jenisKelamin,
                item.prodiId,
                pembimbingAkademikId,
              );
              showAppMessage(context, vm.message);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

Future<void> _editProdi(BuildContext context, Prodi item) async {
  final vm = context.read<ProdiViewModel>();
  final nameController = TextEditingController(text: item.nama);

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Ubah Prodi ${item.id}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nama Prodi'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              vm.update(item.id, nameController.text, item.fakultasId);
              showAppMessage(context, vm.message);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

Future<void> _deleteProdi(BuildContext context, String id) async {
  final vm = context.read<ProdiViewModel>();
  final confirmed = await _confirmDelete(context, 'Hapus prodi $id?');
  if (!confirmed) return;
  vm.delete(id);
  if (context.mounted) showAppMessage(context, vm.message);
}

Future<void> _deleteMahasiswa(BuildContext context, String nim) async {
  final vm = context.read<MahasiswaViewModel>();
  final confirmed = await _confirmDelete(context, 'Hapus mahasiswa $nim?');
  if (!confirmed) return;
  vm.delete(nim);
  if (context.mounted) showAppMessage(context, vm.message);
}

Future<void> _editDosen(BuildContext context, Dosen item) async {
  final vm = context.read<DosenViewModel>();
  final nameController = TextEditingController(text: item.nama);

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Ubah Dosen ${item.nidn}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nama Dosen'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              vm.update(item.nidn, nameController.text, item.prodiId);
              showAppMessage(context, vm.message);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

Future<void> _deleteDosen(BuildContext context, String nidn) async {
  final vm = context.read<DosenViewModel>();
  final confirmed = await _confirmDelete(context, 'Hapus dosen $nidn?');
  if (!confirmed) return;
  vm.delete(nidn);
  if (context.mounted) showAppMessage(context, vm.message);
}

Future<void> _editMataKuliah(BuildContext context, MataKuliah item) async {
  final vm = context.read<MataKuliahViewModel>();
  final nameController = TextEditingController(text: item.nama);
  final sksController = TextEditingController(text: item.sks.toString());
  final tugasController = TextEditingController(
    text: item.bobotTugas.toStringAsFixed(0),
  );
  final utsController = TextEditingController(
    text: item.bobotUts.toStringAsFixed(0),
  );
  final uasController = TextEditingController(
    text: item.bobotUas.toStringAsFixed(0),
  );
  final softskillController = TextEditingController(
    text: item.bobotSoftskill.toStringAsFixed(0),
  );
  var kategori = item.kategori;

  await showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Ubah Mata Kuliah ${item.kode}'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Mata Kuliah',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: sksController,
                    decoration: const InputDecoration(labelText: 'Jumlah SKS'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<KategoriMataKuliah>(
                    initialValue: kategori,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: [
                      for (final value in KategoriMataKuliah.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => kategori = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  _BobotNilaiFields(
                    tugasController: tugasController,
                    utsController: utsController,
                    uasController: uasController,
                    softskillController: softskillController,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                vm.update(
                  item.kode,
                  nameController.text,
                  int.tryParse(sksController.text) ?? 0,
                  item.prodiId,
                  kategori: kategori,
                  bobotTugas: double.tryParse(tugasController.text) ?? -1,
                  bobotUts: double.tryParse(utsController.text) ?? -1,
                  bobotUas: double.tryParse(uasController.text) ?? -1,
                  bobotSoftskill:
                      double.tryParse(softskillController.text) ?? -1,
                );
                showAppMessage(context, vm.message);
                if ((vm.message ?? '').contains('berhasil')) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _deleteMataKuliah(BuildContext context, String kode) async {
  final vm = context.read<MataKuliahViewModel>();
  final confirmed = await _confirmDelete(context, 'Hapus mata kuliah $kode?');
  if (!confirmed) return;
  vm.delete(kode);
  if (context.mounted) showAppMessage(context, vm.message);
}

class _BobotNilaiFields extends StatelessWidget {
  const _BobotNilaiFields({
    required this.tugasController,
    required this.utsController,
    required this.uasController,
    required this.softskillController,
  });

  final TextEditingController tugasController;
  final TextEditingController utsController;
  final TextEditingController uasController;
  final TextEditingController softskillController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fields = [
          TextField(
            controller: tugasController,
            decoration: const InputDecoration(labelText: 'Bobot Tugas (%)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: utsController,
            decoration: const InputDecoration(labelText: 'Bobot UTS (%)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: uasController,
            decoration: const InputDecoration(labelText: 'Bobot UAS (%)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: softskillController,
            decoration: const InputDecoration(labelText: 'Bobot Softskill (%)'),
            keyboardType: TextInputType.number,
          ),
        ];

        if (constraints.maxWidth < 460) {
          return Column(
            children: [
              for (final field in fields) ...[field, const SizedBox(height: 8)],
            ],
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final field in fields)
              SizedBox(width: (constraints.maxWidth - 8) / 2, child: field),
          ],
        );
      },
    );
  }
}

void _applyBobotPreset(
  KategoriMataKuliah kategori,
  TextEditingController tugasController,
  TextEditingController utsController,
  TextEditingController uasController,
  TextEditingController softskillController,
) {
  switch (kategori) {
    case KategoriMataKuliah.reguler:
      tugasController.text = '25';
      utsController.text = '25';
      uasController.text = '35';
      softskillController.text = '15';
    case KategoriMataKuliah.praktikum:
      tugasController.text = '40';
      utsController.text = '15';
      uasController.text = '30';
      softskillController.text = '15';
    case KategoriMataKuliah.caseMethod:
      tugasController.text = '45';
      utsController.text = '15';
      uasController.text = '25';
      softskillController.text = '15';
  }
}

class _DosenMultiSelectField extends StatelessWidget {
  const _DosenMultiSelectField({
    required this.dosen,
    required this.selectedIds,
    required this.onChanged,
  });

  final List<Dosen> dosen;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedDosen = [
      for (final id in selectedIds)
        if (dosen.any((item) => item.nidn == id))
          dosen.firstWhere((item) => item.nidn == id),
    ];

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Dosen Pengajar',
        border: OutlineInputBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (selectedDosen.isEmpty)
            Text(
              'Belum ada dosen dipilih',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            Text(
              '${selectedDosen.length} dosen dipilih. Pilihan pertama menjadi dosen utama.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var index = 0; index < selectedDosen.length; index++)
                  InputChip(
                    avatar: index == 0
                        ? const Icon(Icons.star_rounded, size: 18)
                        : null,
                    label: Text(
                      index == 0
                          ? '${selectedDosen[index].nama} (Utama)'
                          : selectedDosen[index].nama,
                    ),
                    onDeleted: () {
                      final updated = Set<String>.from(selectedIds)
                        ..remove(selectedDosen[index].nidn);
                      onChanged(updated);
                    },
                  ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: dosen.isEmpty
                ? null
                : () async {
                    final result = await _showDosenPicker(
                      context,
                      dosen: dosen,
                      selectedIds: selectedIds,
                    );
                    if (result != null) onChanged(result);
                  },
            icon: const Icon(Icons.person_search_outlined),
            label: Text(
              selectedDosen.isEmpty ? 'Pilih Dosen' : 'Ubah Pilihan Dosen',
            ),
          ),
        ],
      ),
    );
  }
}

Future<Set<String>?> _showDosenPicker(
  BuildContext context, {
  required List<Dosen> dosen,
  required Set<String> selectedIds,
}) {
  final searchController = TextEditingController();
  final pendingIds = Set<String>.from(selectedIds);

  return showDialog<Set<String>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final query = searchController.text.trim().toLowerCase();
          final filtered =
              dosen.where((item) {
                return query.isEmpty ||
                    item.nama.toLowerCase().contains(query) ||
                    item.nidn.toLowerCase().contains(query);
              }).toList()..sort((a, b) {
                final aSelected = pendingIds.contains(a.nidn);
                final bSelected = pendingIds.contains(b.nidn);
                if (aSelected != bSelected) return aSelected ? -1 : 1;
                return a.nama.compareTo(b.nama);
              });

          return AlertDialog(
            title: const Text('Pilih Dosen Pengajar'),
            content: SizedBox(
              width: 560,
              height: 520,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Cari nama atau NIDN',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              onPressed: () {
                                searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear),
                            ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${pendingIds.length} dipilih - ${filtered.length} hasil',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('Dosen tidak ditemukan'))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final selected = pendingIds.contains(item.nidn);
                              final selectedIndex = pendingIds.toList().indexOf(
                                item.nidn,
                              );
                              return CheckboxListTile(
                                value: selected,
                                title: Text(item.nama),
                                subtitle: Text(
                                  selectedIndex == 0
                                      ? '${item.nidn} - Dosen Utama'
                                      : item.nidn,
                                ),
                                secondary: selected
                                    ? IconButton(
                                        tooltip: selectedIndex == 0
                                            ? 'Dosen utama'
                                            : 'Jadikan dosen utama',
                                        onPressed: selectedIndex == 0
                                            ? null
                                            : () {
                                                setState(() {
                                                  final reordered = [
                                                    item.nidn,
                                                    ...pendingIds.where(
                                                      (id) => id != item.nidn,
                                                    ),
                                                  ];
                                                  pendingIds
                                                    ..clear()
                                                    ..addAll(reordered);
                                                });
                                              },
                                        icon: Icon(
                                          selectedIndex == 0
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                        ),
                                      )
                                    : const Icon(Icons.person_outline),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked ?? false) {
                                      pendingIds.add(item.nidn);
                                    } else {
                                      pendingIds.remove(item.nidn);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: pendingIds.isEmpty
                    ? null
                    : () => Navigator.pop(context, pendingIds),
                child: Text('Terapkan (${pendingIds.length})'),
              ),
            ],
          );
        },
      );
    },
  ).whenComplete(searchController.dispose);
}

Future<void> _openKelasDialog(BuildContext context, String prodiId) async {
  final vm = context.read<KelasViewModel>();
  final service = context.read<MockService>();
  final mataKuliah = service.mataKuliah
      .where((item) => item.prodiId == prodiId)
      .toList();
  final dosen = service.dosen.where((item) => item.prodiId == prodiId).toList();
  final ruangan = service.ruangan;
  String? selectedMataKuliah = mataKuliah.isEmpty
      ? null
      : mataKuliah.first.kode;
  final selectedDosenIds = <String>{};
  String? selectedRuangan = ruangan.isEmpty ? null : ruangan.first.kodeRuangan;
  String selectedHari = 'Senin';
  final kapasitasController = TextEditingController(text: '30');
  final jamController = TextEditingController(text: '08.00 - 10.00');

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Buka Kelas'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedMataKuliah,
                    decoration: const InputDecoration(labelText: 'Mata Kuliah'),
                    items: [
                      for (final item in mataKuliah)
                        DropdownMenuItem(
                          value: item.kode,
                          child: Text('${item.nama} (${item.kode})'),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedMataKuliah = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  _DosenMultiSelectField(
                    dosen: dosen,
                    selectedIds: selectedDosenIds,
                    onChanged: (value) {
                      setState(() {
                        selectedDosenIds
                          ..clear()
                          ..addAll(value);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRuangan,
                    decoration: const InputDecoration(labelText: 'Ruangan'),
                    items: [
                      for (final item in ruangan)
                        DropdownMenuItem(
                          value: item.kodeRuangan,
                          child: Text(
                            '${item.namaRuangan} (${item.kapasitasRuangan})',
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedRuangan = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedHari,
                    decoration: const InputDecoration(labelText: 'Hari'),
                    items: const [
                      DropdownMenuItem(value: 'Senin', child: Text('Senin')),
                      DropdownMenuItem(value: 'Selasa', child: Text('Selasa')),
                      DropdownMenuItem(value: 'Rabu', child: Text('Rabu')),
                      DropdownMenuItem(value: 'Kamis', child: Text('Kamis')),
                      DropdownMenuItem(value: 'Jumat', child: Text('Jumat')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => selectedHari = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: jamController,
                    decoration: const InputDecoration(
                      labelText: 'Jam (ex: 08.00 - 10.00)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: kapasitasController,
                    decoration: const InputDecoration(
                      labelText: 'Kapasitas Peserta',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (selectedMataKuliah == null ||
                  selectedDosenIds.isEmpty ||
                  selectedRuangan == null) {
                showAppMessage(
                  context,
                  'Lengkapi mata kuliah, dosen, dan ruangan terlebih dahulu',
                );
                return;
              }
              vm.open(
                mataKuliahId: selectedMataKuliah!,
                dosenIds: selectedDosenIds.toList(),
                kapasitas: int.tryParse(kapasitasController.text) ?? 0,
                hari: selectedHari,
                jam: jamController.text,
                ruangan: selectedRuangan!,
              );
              showAppMessage(context, vm.message);
              if ((vm.message ?? '').startsWith('Kelas berhasil')) {
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

Future<void> _editKelas(BuildContext context, Kelas item) async {
  final vm = context.read<KelasViewModel>();
  final service = context.read<MockService>();
  final kapasitasController = TextEditingController(
    text: item.kapasitas.toString(),
  );
  String selectedHari = item.hari;
  final jamController = TextEditingController(text: item.jam);
  String selectedRuangan = item.ruangan;
  final mataKuliah = service.mataKuliah.firstWhere(
    (mk) => mk.kode == item.mataKuliahId,
  );
  final dosen = service.dosen
      .where((lecturer) => lecturer.prodiId == mataKuliah.prodiId)
      .toList();
  final selectedDosenIds = service
      .getDosenPengajarKelas(item.id)
      .map((pengajar) => pengajar.nidnDosen)
      .toSet();

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Ubah Kelas ${item.id}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DosenMultiSelectField(
                    dosen: dosen,
                    selectedIds: selectedDosenIds,
                    onChanged: (value) {
                      setState(() {
                        selectedDosenIds
                          ..clear()
                          ..addAll(value);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRuangan,
                    decoration: const InputDecoration(labelText: 'Ruangan'),
                    items: [
                      for (final room in service.ruangan)
                        DropdownMenuItem(
                          value: room.kodeRuangan,
                          child: Text(
                            '${room.namaRuangan} (${room.kapasitasRuangan})',
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedRuangan = value);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedHari,
                    decoration: const InputDecoration(labelText: 'Hari'),
                    items: const [
                      DropdownMenuItem(value: 'Senin', child: Text('Senin')),
                      DropdownMenuItem(value: 'Selasa', child: Text('Selasa')),
                      DropdownMenuItem(value: 'Rabu', child: Text('Rabu')),
                      DropdownMenuItem(value: 'Kamis', child: Text('Kamis')),
                      DropdownMenuItem(value: 'Jumat', child: Text('Jumat')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => selectedHari = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: jamController,
                    decoration: const InputDecoration(
                      labelText: 'Jam (ex: 08.00 - 10.00)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: kapasitasController,
                    decoration: const InputDecoration(
                      labelText: 'Kapasitas Peserta',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (selectedDosenIds.isEmpty) {
                showAppMessage(context, 'Pilih minimal satu dosen pengajar');
                return;
              }
              vm.update(
                id: item.id,
                mataKuliahId: item.mataKuliahId,
                dosenIds: selectedDosenIds.toList(),
                kapasitas: int.tryParse(kapasitasController.text) ?? 0,
                hari: selectedHari,
                jam: jamController.text,
                ruangan: selectedRuangan,
              );
              showAppMessage(context, vm.message);
              if ((vm.message ?? '').startsWith('Kelas berhasil')) {
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

Future<void> _deleteKelas(BuildContext context, String id) async {
  final vm = context.read<KelasViewModel>();
  final confirmed = await _confirmDelete(context, 'Hapus kelas $id?');
  if (!confirmed) return;
  vm.delete(id);
  if (context.mounted) showAppMessage(context, vm.message);
}

Future<void> _addRuangan(BuildContext context) async {
  final vm = context.read<RuanganViewModel>();
  final kodeController = TextEditingController();
  final namaController = TextEditingController();
  final kapasitasController = TextEditingController(text: '40');
  final lokasiController = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Tambah Ruangan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: kodeController,
                decoration: const InputDecoration(labelText: 'Kode Ruangan'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Ruangan'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: kapasitasController,
                decoration: const InputDecoration(labelText: 'Kapasitas'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi/Gedung'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              vm.add(
                kodeRuangan: kodeController.text,
                namaRuangan: namaController.text,
                kapasitasRuangan: int.tryParse(kapasitasController.text) ?? 0,
                lokasi: lokasiController.text,
              );
              showAppMessage(context, vm.message);
              if ((vm.message ?? '').startsWith('Ruangan berhasil')) {
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

Future<void> _editRuangan(BuildContext context, Ruangan item) async {
  final vm = context.read<RuanganViewModel>();
  final namaController = TextEditingController(text: item.namaRuangan);
  final kapasitasController = TextEditingController(
    text: item.kapasitasRuangan.toString(),
  );
  final lokasiController = TextEditingController(text: item.lokasi);

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Ubah Ruangan ${item.kodeRuangan}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Ruangan'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: kapasitasController,
                decoration: const InputDecoration(labelText: 'Kapasitas'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi/Gedung'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              vm.update(
                kodeRuangan: item.kodeRuangan,
                namaRuangan: namaController.text,
                kapasitasRuangan: int.tryParse(kapasitasController.text) ?? 0,
                lokasi: lokasiController.text,
              );
              showAppMessage(context, vm.message);
              if ((vm.message ?? '').startsWith('Ruangan berhasil')) {
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

Future<void> _deleteRuangan(BuildContext context, String kodeRuangan) async {
  final vm = context.read<RuanganViewModel>();
  final confirmed = await _confirmDelete(
    context,
    'Hapus ruangan $kodeRuangan?',
  );
  if (!confirmed) return;
  vm.delete(kodeRuangan);
  if (context.mounted) showAppMessage(context, vm.message);
}

Future<bool> _confirmDelete(BuildContext context, String message) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          );
        },
      ) ??
      false;
}

Future<void> _quickAddMahasiswa(BuildContext context, String prodiId) async {
  final vm = context.read<MahasiswaViewModel>();
  final service = context.read<MockService>();
  final nimController = TextEditingController();
  final nameController = TextEditingController();
  String jenisKelamin = 'Laki-laki';
  final dosenProdi = service.dosen
      .where((dosen) => dosen.prodiId == prodiId)
      .toList();
  String? pembimbingAkademikId = dosenProdi.isEmpty
      ? null
      : dosenProdi.first.nidn;

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Tambah Mahasiswa'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nimController,
                  decoration: const InputDecoration(labelText: 'NIM'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Mahasiswa',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: jenisKelamin,
                  decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Laki-laki',
                      child: Text('Laki-laki'),
                    ),
                    DropdownMenuItem(
                      value: 'Perempuan',
                      child: Text('Perempuan'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => jenisKelamin = value);
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: pembimbingAkademikId,
                  decoration: const InputDecoration(labelText: 'Dosen PA'),
                  items: [
                    for (final dosen in dosenProdi)
                      DropdownMenuItem(
                        value: dosen.nidn,
                        child: Text(dosen.nama),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() => pembimbingAkademikId = value);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (nimController.text.isNotEmpty &&
                  nameController.text.isNotEmpty &&
                  pembimbingAkademikId != null) {
                try {
                  vm.add(
                    nimController.text,
                    nameController.text,
                    jenisKelamin,
                    prodiId,
                    pembimbingAkademikId!,
                  );
                  showAppMessage(context, vm.message);
                  Navigator.pop(context);
                } catch (e) {
                  showAppMessage(context, e.toString());
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

Future<void> _quickAddDosen(BuildContext context, String prodiId) async {
  final vm = context.read<DosenViewModel>();
  final nidnController = TextEditingController();
  final nameController = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Tambah Dosen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nidnController,
              decoration: const InputDecoration(labelText: 'NIDN'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Dosen'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (nidnController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                try {
                  vm.add(nidnController.text, nameController.text, prodiId);
                  showAppMessage(context, vm.message);
                  Navigator.pop(context);
                } catch (e) {
                  showAppMessage(context, e.toString());
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  );
}

Future<void> _quickAddMataKuliah(BuildContext context, String prodiId) async {
  final vm = context.read<MataKuliahViewModel>();
  final kodeController = TextEditingController();
  final nameController = TextEditingController();
  final sksController = TextEditingController();
  final tugasController = TextEditingController(text: '25');
  final utsController = TextEditingController(text: '25');
  final uasController = TextEditingController(text: '35');
  final softskillController = TextEditingController(text: '15');
  var kategori = KategoriMataKuliah.reguler;

  await showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Mata Kuliah'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: kodeController,
                    decoration: const InputDecoration(
                      labelText: 'Kode Mata Kuliah',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Mata Kuliah',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: sksController,
                    decoration: const InputDecoration(labelText: 'Jumlah SKS'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<KategoriMataKuliah>(
                    initialValue: kategori,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: [
                      for (final value in KategoriMataKuliah.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        kategori = value;
                        _applyBobotPreset(
                          value,
                          tugasController,
                          utsController,
                          uasController,
                          softskillController,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _BobotNilaiFields(
                    tugasController: tugasController,
                    utsController: utsController,
                    uasController: uasController,
                    softskillController: softskillController,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final sks = int.tryParse(sksController.text) ?? 0;
                if (kodeController.text.isNotEmpty &&
                    nameController.text.isNotEmpty &&
                    sks > 0) {
                  vm.add(
                    kodeController.text,
                    nameController.text,
                    sks,
                    prodiId,
                    kategori: kategori,
                    bobotTugas: double.tryParse(tugasController.text) ?? -1,
                    bobotUts: double.tryParse(utsController.text) ?? -1,
                    bobotUas: double.tryParse(uasController.text) ?? -1,
                    bobotSoftskill:
                        double.tryParse(softskillController.text) ?? -1,
                  );
                  showAppMessage(context, vm.message);
                  if ((vm.message ?? '').contains('berhasil')) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    },
  );
}
