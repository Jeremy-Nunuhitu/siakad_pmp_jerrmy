import 'package:flutter/material.dart';
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
            children: [
              for (int i = 0; i < vm.items.length; i++)
                AnimatedEntrance(
                  delay: Duration(milliseconds: i * 80),
                  child: InfoTile(
                    icon: Icons.account_balance_outlined,
                    title: vm.items[i].nama,
                    subtitle: 'ID: ${vm.items[i].id}',
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
                children: [
                  for (int i = 0; i < items.length; i++)
                    AnimatedEntrance(
                      delay: Duration(milliseconds: i * 80),
                      child: InfoTile(
                        icon: Icons.apartment_outlined,
                        title: items[i].nama,
                        subtitle: 'Fakultas: ${items[i].fakultasId}',
                        trailing: _CrudMenu(
                          onEdit: () => _editProdi(context, items[i]),
                          onDelete: () => _deleteProdi(context, items[i].id),
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

class GlobalDataView extends StatelessWidget {
  const GlobalDataView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ringkasan data global untuk admin universitas.
    // Semua angka diambil dari MockService agar selalu mengikuti data terbaru.
    final service = context.watch<MockService>();
    return AppScaffold(
      title: 'Data Global',
      child: Column(
        children: [
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

class ProdiCoreDataView extends StatelessWidget {
  const ProdiCoreDataView({required this.prodiId, super.key});

  final String prodiId;

  @override
  Widget build(BuildContext context) {
    // Operator prodi mengelola data inti akademik:
    // mahasiswa, dosen, dan mata kuliah.
    final mahasiswaVm = context.watch<MahasiswaViewModel>();
    final dosenVm = context.watch<DosenViewModel>();
    final mkVm = context.watch<MataKuliahViewModel>();

    return AppScaffold(
      title: 'Data Prodi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Mahasiswa'),
          for (final item in mahasiswaVm.items(prodiId: prodiId))
            InfoTile(
              icon: Icons.groups_outlined,
              title: item.nama,
              subtitle:
                  '${item.nim} - ${item.jenisKelamin} - PA: ${context.read<MockService>().getDosenName(item.pembimbingAkademikId)}',
              trailing: _CrudMenu(
                onEdit: () => _editMahasiswa(context, item),
                onDelete: () => _deleteMahasiswa(context, item.nim),
              ),
            ),
          FilledButton.icon(
            onPressed: () => _quickAddMahasiswa(context, prodiId),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Mahasiswa'),
          ),
          const SizedBox(height: 18),
          _SectionTitle('Dosen'),
          for (final item in dosenVm.items(prodiId: prodiId))
            InfoTile(
              icon: Icons.co_present_outlined,
              title: item.nama,
              subtitle: '${item.nidn} - Prodi: ${item.prodiId}',
              trailing: _CrudMenu(
                onEdit: () => _editDosen(context, item),
                onDelete: () => _deleteDosen(context, item.nidn),
              ),
            ),
          FilledButton.icon(
            onPressed: () => _quickAddDosen(context, prodiId),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Dosen'),
          ),
          const SizedBox(height: 18),
          _SectionTitle('Mata Kuliah'),
          for (final item in mkVm.items(prodiId: prodiId))
            InfoTile(
              icon: Icons.menu_book_outlined,
              title: item.nama,
              subtitle: '${item.kode} - ${item.sks} SKS',
              trailing: _CrudMenu(
                onEdit: () => _editMataKuliah(context, item),
                onDelete: () => _deleteMataKuliah(context, item.kode),
              ),
            ),
          FilledButton.icon(
            onPressed: () => _quickAddMataKuliah(context, prodiId),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Mata Kuliah'),
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
    // Kelas dibuka oleh operator prodi dari kombinasi mata kuliah dan dosen.
    final kelasVm = context.watch<KelasViewModel>();
    final ruanganVm = context.watch<RuanganViewModel>();
    final service = context.watch<MockService>();
    final kelas = kelasVm.items(prodiId: prodiId);

    return AppScaffold(
      title: 'Kelola Kelas',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openKelasDialog(context, prodiId),
        icon: const Icon(Icons.add),
        label: const Text('Buka Kelas'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle('Ruangan'),
          for (final item in ruanganVm.items)
            InfoTile(
              icon: Icons.meeting_room_outlined,
              title: '${item.kodeRuangan} - ${item.namaRuangan}',
              subtitle: 'Kapasitas: ${item.kapasitasRuangan} - ${item.lokasi}',
              trailing: _CrudMenu(
                onEdit: () => _editRuangan(context, item),
                onDelete: () => _deleteRuangan(context, item.kodeRuangan),
              ),
            ),
          FilledButton.icon(
            onPressed: () => _addRuangan(context),
            icon: const Icon(Icons.add_business_outlined),
            label: const Text('Tambah Ruangan'),
          ),
          const SizedBox(height: 18),
          _SectionTitle('Kelas Kuliah'),
          for (int i = 0; i < kelas.length; i++)
            AnimatedEntrance(
              delay: Duration(milliseconds: i * 80),
              child: InfoTile(
                icon: Icons.event_available_outlined,
                title: kelas[i].id,
                subtitle:
                    '${service.getMataKuliahName(kelas[i].mataKuliahId)}\nDosen: ${service.getDosenPengajarNames(kelas[i].id)}\n${kelas[i].hari}, ${kelas[i].jam} - ${service.getRuanganName(kelas[i].ruangan)}\nKapasitas: ${service.getJumlahPesertaKelas(kelas[i].id)}/${kelas[i].kapasitas}',
                trailing: _CrudMenu(
                  onEdit: () => _editKelas(context, kelas[i]),
                  onDelete: () => _deleteKelas(context, kelas[i].id),
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
        children: [
          for (final user in service.users.where(
            (item) =>
                item.role == Role.dosen ||
                item.role == Role.mahasiswa ||
                item.role == Role.adminProdi,
          ))
            InfoTile(
              icon: Icons.person_outline,
              title: user.name,
              subtitle: '${user.username} - ${user.role.label}',
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
        children: [
          for (final user in visibleUsers)
            InfoTile(
              icon: Icons.admin_panel_settings_outlined,
              title: user.name,
              subtitle: '${user.username} - ${user.role.label}',
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
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
  String? selectedDosen = dosen.isEmpty ? null : dosen.first.nidn;
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
                  DropdownButtonFormField<String>(
                    initialValue: selectedDosen,
                    decoration: const InputDecoration(
                      labelText: 'Dosen Pengajar',
                    ),
                    items: [
                      for (final item in dosen)
                        DropdownMenuItem(
                          value: item.nidn,
                          child: Text('${item.nama} (${item.nidn})'),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedDosen = value);
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
                  selectedDosen == null ||
                  selectedRuangan == null) {
                showAppMessage(
                  context,
                  'Lengkapi mata kuliah, dosen, dan ruangan terlebih dahulu',
                );
                return;
              }
              vm.open(
                mataKuliahId: selectedMataKuliah!,
                dosenId: selectedDosen!,
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
              vm.update(
                id: item.id,
                mataKuliahId: item.mataKuliahId,
                dosenId: item.dosenId,
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
