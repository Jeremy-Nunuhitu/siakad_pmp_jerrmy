import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import 'base_list_viewmodel.dart';

class ProdiViewModel extends BaseListViewModel {
  ProdiViewModel(this._service);

  final MockService _service;

  List<Prodi> items({String? fakultasId}) {
    // Jika fakultasId dikirim, UI hanya melihat prodi milik fakultas tersebut.
    return _service.prodi
        .where((item) => fakultasId == null || item.fakultasId == fakultasId)
        .toList();
  }

  void add(
    String nama,
    String fakultasId,
    String adminUsername,
    String adminPassword,
  ) {
    // Tambah prodi sekaligus akun admin/operator prodi.
    runAction(
      () => _service.addProdi(nama, fakultasId, adminUsername, adminPassword),
    );
  }

  void update(String id, String nama, String fakultasId) {
    // Update hanya mengubah identitas prodi, bukan data akademik di bawahnya.
    runAction(() => _service.updateProdi(id, nama, fakultasId));
  }

  void delete(String id) {
    // Service akan menolak hapus jika prodi masih punya mahasiswa/dosen/MK.
    runAction(() => _service.deleteProdi(id));
  }
}
