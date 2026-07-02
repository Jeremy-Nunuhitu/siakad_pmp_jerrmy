import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import 'base_list_viewmodel.dart';

class MahasiswaViewModel extends BaseListViewModel {
  MahasiswaViewModel(this._service);

  final MockService _service;

  List<Mahasiswa> items({String? prodiId}) {
    // Daftar mahasiswa bisa difilter per prodi sesuai scope operator.
    return _service.mahasiswa
        .where((item) => prodiId == null || item.prodiId == prodiId)
        .toList();
  }

  PagedResult<Mahasiswa> pagedItems({
    String? prodiId,
    int page = 0,
    int pageSize = BaseListViewModel.defaultPageSize,
    String query = '',
    String Function(Mahasiswa item)? searchableText,
    Comparator<Mahasiswa>? sortBy,
    bool descending = false,
  }) {
    return paginate(
      _service.mahasiswa.where(
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

  Mahasiswa? byNim(String nim) {
    // Dipakai halaman detail/form untuk mengambil satu mahasiswa dari NIM.
    for (final item in _service.mahasiswa) {
      if (item.nim == nim) return item;
    }
    return null;
  }

  void add(
    String nim,
    String nama,
    String jenisKelamin,
    String prodiId,
    String pembimbingAkademikId,
  ) {
    // Input dari form dikirim ke service, lalu UI mendapat pesan hasil aksi.
    runAction(
      () => _service.addMahasiswa(
        nim,
        nama,
        jenisKelamin,
        prodiId,
        pembimbingAkademikId,
      ),
    );
  }

  void update(
    String nim,
    String nama,
    String jenisKelamin,
    String prodiId,
    String pembimbingAkademikId,
  ) {
    runAction(
      () => _service.updateMahasiswa(
        nim: nim,
        nama: nama,
        jenisKelamin: jenisKelamin,
        prodiId: prodiId,
        pembimbingAkademikId: pembimbingAkademikId,
      ),
    );
  }

  void updateProfile({
    required String nim,
    required String jenisKelamin,
    required int semester,
    required String email,
    required String noHp,
    required String alamat,
  }) {
    runAction(
      () => _service.updateProfilMahasiswa(
        nim: nim,
        jenisKelamin: jenisKelamin,
        semester: semester,
        email: email,
        noHp: noHp,
        alamat: alamat,
      ),
    );
  }

  void delete(String nim) {
    runAction(() => _service.deleteMahasiswa(nim));
  }

  void ubahStatus({
    required String nim,
    required StatusMahasiswa statusBaru,
    required String namaBukti,
    required List<int> buktiBytes,
  }) {
    runAction(
      () => _service.ubahStatusMahasiswa(
        nim: nim,
        statusBaru: statusBaru,
        namaBukti: namaBukti,
        buktiBytes: buktiBytes,
      ),
    );
  }
}
