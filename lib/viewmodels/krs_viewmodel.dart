import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import 'base_list_viewmodel.dart';

class KRSViewModel extends BaseListViewModel {
  KRSViewModel(this._service);

  final MockService _service;

  List<KRS> items({String? mahasiswaId}) {
    // Mahasiswa hanya melihat KRS miliknya, sedangkan admin bisa membaca semua.
    return _service.krs
        .where((item) => mahasiswaId == null || item.mahasiswaId == mahasiswaId)
        .toList();
  }

  void take(String mahasiswaId, String kelasId) {
    // Ambil KRS memicu validasi prodi, kapasitas, dan duplikasi kelas.
    runAction(() => _service.takeKrs(mahasiswaId, kelasId));
  }

  void submit(String mahasiswaId, int semester) {
    runAction(() => _service.submitKrs(mahasiswaId, semester));
  }

  void validate(String krsId, String dosenId) {
    runAction(() => _service.validateKrs(krsId, dosenId));
  }

  void reject(String krsId, String dosenId, String catatan) {
    runAction(() => _service.rejectKrs(krsId, dosenId, catatan));
  }

  void remove(String krsId, String mahasiswaId) {
    runAction(() => _service.removeKrs(krsId, mahasiswaId));
  }
}
