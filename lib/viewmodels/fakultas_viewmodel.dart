import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import 'base_list_viewmodel.dart';

class FakultasViewModel extends BaseListViewModel {
  FakultasViewModel(this._service);

  final MockService _service;

  // Data fakultas dibaca dari service dan ditampilkan oleh halaman admin.
  List<Fakultas> get items => _service.fakultas;

  void add(String nama, String adminUsername, String adminPassword) {
    // Aksi tambah diteruskan ke service agar validasi tetap terpusat.
    runAction(() => _service.addFakultas(nama, adminUsername, adminPassword));
  }
}
