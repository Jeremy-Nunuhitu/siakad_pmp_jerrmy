import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import 'base_list_viewmodel.dart';

class KelasViewModel extends BaseListViewModel {
  KelasViewModel(this._service);

  final MockService _service;

  List<Kelas> items({String? prodiId, String? dosenId}) {
    // Kelas bisa dilihat dari dua sudut: prodi untuk operator,
    // atau dosenId untuk dashboard dosen.
    return _filteredItems(prodiId: prodiId, dosenId: dosenId).toList();
  }

  PagedResult<Kelas> pagedItems({
    String? prodiId,
    String? dosenId,
    int page = 0,
    int pageSize = BaseListViewModel.defaultPageSize,
    String query = '',
    String Function(Kelas item)? searchableText,
    Comparator<Kelas>? sortBy,
    bool descending = false,
  }) {
    return paginate(
      _filteredItems(prodiId: prodiId, dosenId: dosenId),
      page: page,
      pageSize: pageSize,
      query: query,
      searchableText: searchableText,
      sortBy: sortBy,
      descending: descending,
    );
  }

  Iterable<Kelas> _filteredItems({String? prodiId, String? dosenId}) {
    return _service.kelas.where((kelas) {
      final mk = _service.mataKuliah.firstWhere(
        (item) => item.kode == kelas.mataKuliahId,
      );
      final matchProdi = prodiId == null || mk.prodiId == prodiId;
      final matchDosen =
          dosenId == null || _service.isDosenMengajarKelas(dosenId, kelas.id);
      return matchProdi && matchDosen;
    });
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
    required List<String> dosenIds,
    required int kapasitas,
    required String hari,
    required String jam,
    required String ruangan,
  }) {
    // Membuka kelas membuat jadwal sekaligus slot 16 pertemuan di service.
    runAction(
      () => _service.openKelas(
        mataKuliahId: mataKuliahId,
        dosenIds: dosenIds,
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
    required List<String> dosenIds,
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
        dosenIds: dosenIds,
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
