import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import 'base_list_viewmodel.dart';

class NilaiViewModel extends BaseListViewModel {
  NilaiViewModel(this._service);

  static const defaultWindowSize = 1000;

  final MockService _service;

  List<Nilai> items({String? mahasiswaId, String? kelasId}) {
    // Nilai dapat difilter untuk KHS mahasiswa atau daftar nilai per kelas.
    return _service.nilai
        .where((item) {
          final matchMahasiswa =
              mahasiswaId == null || item.mahasiswaId == mahasiswaId;
          final matchKelas = kelasId == null || item.kelasId == kelasId;
          return matchMahasiswa && matchKelas;
        })
        .take(mahasiswaId == null && kelasId == null ? defaultWindowSize : 500)
        .toList();
  }

  void input({
    required String dosenId,
    required String mahasiswaId,
    required String kelasId,
    required double angka,
    double? tugas,
    double? uts,
    double? uas,
    double? softskill,
  }) {
    // Dosen mengirim nilai angka; service mengubahnya menjadi nilai huruf.
    runAction(
      () => _service.inputNilai(
        dosenId: dosenId,
        mahasiswaId: mahasiswaId,
        kelasId: kelasId,
        angka: angka,
        tugas: tugas,
        uts: uts,
        uas: uas,
        softskill: softskill,
      ),
    );
  }
}
