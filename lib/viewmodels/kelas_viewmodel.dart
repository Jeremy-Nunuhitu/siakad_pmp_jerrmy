import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import 'base_list_viewmodel.dart';

class KelasViewModel extends BaseListViewModel {
  KelasViewModel(this._service);

  final MockService _service;

  List<Kelas> items({String? prodiId, String? dosenId}) {
    // Kelas bisa dilihat dari dua sudut: prodi untuk operator,
    // atau dosenId untuk dashboard dosen.
    return _service.kelas.where((kelas) {
      final mk = _service.mataKuliah.firstWhere(
        (item) => item.kode == kelas.mataKuliahId,
      );
      final matchProdi = prodiId == null || mk.prodiId == prodiId;
      final matchDosen = dosenId == null || kelas.dosenId == dosenId;
      return matchProdi && matchDosen;
    }).toList();
  }

  Kelas? byId(String id) {
    // Detail kelas dicari memakai id kelas yang tersimpan pada KRS/nilai.
    for (final item in _service.kelas) {
      if (item.id == id) return item;
    }
    return null;
  }

  void open({
    required String mataKuliahId,
    required String dosenId,
    required int kapasitas,
    required String hari,
    required String jam,
    required String ruangan,
  }) {
    // Membuka kelas membuat jadwal sekaligus slot 16 pertemuan di service.
    runAction(
      () => _service.openKelas(
        mataKuliahId: mataKuliahId,
        dosenId: dosenId,
        kapasitas: kapasitas,
        hari: hari,
        jam: jam,
        ruangan: ruangan,
      ),
    );
  }

  void update({
    required String id,
    required String mataKuliahId,
    required String dosenId,
    required int kapasitas,
    required String hari,
    required String jam,
    required String ruangan,
  }) {
    // Update kelas tetap melewati service agar kapasitas dan relasi divalidasi.
    runAction(
      () => _service.updateKelas(
        id: id,
        mataKuliahId: mataKuliahId,
        dosenId: dosenId,
        kapasitas: kapasitas,
        hari: hari,
        jam: jam,
        ruangan: ruangan,
      ),
    );
  }

  void delete(String id) {
    // Service akan menolak hapus jika kelas sudah punya peserta KRS.
    runAction(() => _service.deleteKelas(id));
  }
}
