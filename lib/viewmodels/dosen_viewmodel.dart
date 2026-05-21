import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import 'base_list_viewmodel.dart';

class DosenViewModel extends BaseListViewModel {
  DosenViewModel(this._service);

  final MockService _service;

  List<Dosen> items({String? prodiId}) {
    // Filter prodi menjaga operator hanya melihat dosen di area kerjanya.
    return _service.dosen
        .where((item) => prodiId == null || item.prodiId == prodiId)
        .toList();
  }

  Dosen? byId(String nidn) {
    // NIDN menjadi identifier utama dosen di seluruh relasi kelas.
    for (final item in _service.dosen) {
      if (item.nidn == nidn) return item;
    }
    return null;
  }

  void add(String nidn, String nama, String prodiId) {
    // Service akan memberi password default dan memastikan NIDN belum dipakai.
    runAction(() => _service.addDosen(nidn, nama, prodiId));
  }

  void update(String nidn, String nama, String prodiId) {
    runAction(
      () => _service.updateDosen(nidn: nidn, nama: nama, prodiId: prodiId),
    );
  }

  void updateProfile({
    required String nidn,
    required String email,
    required String noHp,
    required String alamat,
    required String keahlian,
  }) {
    runAction(
      () => _service.updateProfilDosen(
        nidn: nidn,
        email: email,
        noHp: noHp,
        alamat: alamat,
        keahlian: keahlian,
      ),
    );
  }

  void delete(String nidn) {
    runAction(() => _service.deleteDosen(nidn));
  }
}
