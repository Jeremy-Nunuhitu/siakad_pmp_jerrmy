import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import 'base_list_viewmodel.dart';

class MataKuliahViewModel extends BaseListViewModel {
  MataKuliahViewModel(this._service);

  final MockService _service;

  List<MataKuliah> items({String? prodiId}) {
    // Mata kuliah difilter berdasarkan prodi sebelum dipilih untuk kelas.
    return _service.mataKuliah
        .where((item) => prodiId == null || item.prodiId == prodiId)
        .toList();
  }

  PagedResult<MataKuliah> pagedItems({
    String? prodiId,
    int page = 0,
    int pageSize = BaseListViewModel.defaultPageSize,
    String query = '',
    String Function(MataKuliah item)? searchableText,
    Comparator<MataKuliah>? sortBy,
    bool descending = false,
  }) {
    return paginate(
      _service.mataKuliah.where(
        (item) => prodiId == null || item.prodiId == prodiId,
      ),
      page: page,
      pageSize: pageSize,
      query: query,
      searchableText: searchableText,
      sortBy: sortBy,
      descending: descending,
    );
  }

  MataKuliah? byKode(String kode) {
    // Kode mata kuliah menjadi kunci relasi antara MK dan kelas.
    for (final item in _service.mataKuliah) {
      if (item.kode == kode) return item;
    }
    return null;
  }

  void add(
    String kode,
    String nama,
    int sks,
    String prodiId, {
    KategoriMataKuliah kategori = KategoriMataKuliah.reguler,
    double bobotTugas = 25,
    double bobotUts = 25,
    double bobotUas = 35,
    double bobotSoftskill = 15,
  }) {
    // Validasi kode, nama, SKS, dan prodi dilakukan di MockService.
    runAction(
      () => _service.addMataKuliah(
        kode,
        nama,
        sks,
        prodiId,
        kategori: kategori,
        bobotTugas: bobotTugas,
        bobotUts: bobotUts,
        bobotUas: bobotUas,
        bobotSoftskill: bobotSoftskill,
      ),
    );
  }

  void update(
    String kode,
    String nama,
    int sks,
    String prodiId, {
    required KategoriMataKuliah kategori,
    required double bobotTugas,
    required double bobotUts,
    required double bobotUas,
    required double bobotSoftskill,
  }) {
    runAction(
      () => _service.updateMataKuliah(
        kode: kode,
        nama: nama,
        sks: sks,
        prodiId: prodiId,
        kategori: kategori,
        bobotTugas: bobotTugas,
        bobotUts: bobotUts,
        bobotUas: bobotUas,
        bobotSoftskill: bobotSoftskill,
      ),
    );
  }

  void delete(String kode) {
    runAction(() => _service.deleteMataKuliah(kode));
  }
}
