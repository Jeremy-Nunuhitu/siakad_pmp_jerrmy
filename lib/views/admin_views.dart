import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import '../utils/app_helpers.dart';
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
          _SearchableList<Mahasiswa>(
            items: mahasiswaVm.items(prodiId: prodiId),
            hintText: 'Cari nama, NIM, jenis kelamin, atau dosen PA',
            searchableText: (item) =>
                '${item.nama} ${item.nim} ${item.jenisKelamin} ${service.getDosenName(item.pembimbingAkademikId)}',
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
    final mahasiswa = mahasiswaVm.items(prodiId: prodiId);

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
          _SearchableList<Mahasiswa>(
            items: mahasiswa,
            hintText: 'Cari nama, NIM, atau status mahasiswa',
            searchableText: (item) =>
                '${item.nama} ${item.nim} ${item.status.label}',
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
                        final result = await FilePicker.platform.pickFiles(
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
          _SearchableList<Dosen>(
            items: dosenVm.items(prodiId: prodiId),
            hintText: 'Cari nama, NIDN, email, atau keahlian',
            searchableText: (item) =>
                '${item.nama} ${item.nidn} ${item.email} ${item.noHp} ${item.keahlian}',
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
          _SearchableList<MataKuliah>(
            items: mkVm.items(prodiId: prodiId),
            hintText: 'Cari kode, nama mata kuliah, atau jumlah SKS',
            searchableText: (item) => '${item.kode} ${item.nama} ${item.sks}',
            itemBuilder: (context, item, index) => InfoTile(
              icon: Icons.menu_book_outlined,
              title: item.nama,
              subtitle: '${item.kode} - ${item.sks} SKS',
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
          _SearchableList<Ruangan>(
            items: ruanganVm.items,
            hintText: 'Cari kode, nama ruangan, kapasitas, atau lokasi',
            searchableText: (item) =>
                '${item.kodeRuangan} ${item.namaRuangan} ${item.kapasitasRuangan} ${item.lokasi}',
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
    final kelas = kelasVm.items(prodiId: prodiId);

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
          _SearchableList<Kelas>(
            items: kelas,
            hintText: 'Cari ID, mata kuliah, dosen, hari, jam, atau ruangan',
            searchableText: (item) =>
                '${item.id} ${service.getMataKuliahName(item.mataKuliahId)} ${service.getDosenPengajarNames(item.id)} ${item.hari} ${item.jam} ${service.getRuanganName(item.ruangan)}',
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
    final users = service.users
        .where(
          (item) =>
              item.role == Role.dosen ||
              item.role == Role.mahasiswa ||
              item.role == Role.adminProdi,
        )
        .toList();

    return AppScaffold(
      title: 'User Prodi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SearchableList<User>(
            items: users,
            hintText: 'Cari nama, username, role, atau scope',
            searchableText: (user) =>
                '${user.name} ${user.username} ${user.role.label} ${user.scopeId}',
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
          _SearchableList<User>(
            items: visibleUsers,
            hintText: 'Cari nama, username, role, atau scope',
            searchableText: (user) =>
                '${user.name} ${user.username} ${user.role.label} ${user.scopeId}',
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

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Ubah Mata Kuliah ${item.kode}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Mata Kuliah'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: sksController,
              decoration: const InputDecoration(labelText: 'Jumlah SKS'),
              keyboardType: TextInputType.number,
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
              vm.update(
                item.kode,
                nameController.text,
                int.tryParse(sksController.text) ?? 0,
                item.prodiId,
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

Future<void> _deleteMataKuliah(BuildContext context, String kode) async {
  final vm = context.read<MataKuliahViewModel>();
  final confirmed = await _confirmDelete(context, 'Hapus mata kuliah $kode?');
  if (!confirmed) return;
  vm.delete(kode);
  if (context.mounted) showAppMessage(context, vm.message);
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

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Tambah Mata Kuliah'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kodeController,
              decoration: const InputDecoration(labelText: 'Kode Mata Kuliah'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Mata Kuliah'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: sksController,
              decoration: const InputDecoration(labelText: 'Jumlah SKS'),
              keyboardType: TextInputType.number,
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
              final sks = int.tryParse(sksController.text) ?? 0;
              if (kodeController.text.isNotEmpty &&
                  nameController.text.isNotEmpty &&
                  sks > 0) {
                try {
                  vm.add(
                    kodeController.text,
                    nameController.text,
                    sks,
                    prodiId,
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
