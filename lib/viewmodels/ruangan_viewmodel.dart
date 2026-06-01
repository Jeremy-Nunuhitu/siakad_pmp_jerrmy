import '../models/siakad_models.dart';
import '../services/mock_service.dart';
import 'base_list_viewmodel.dart';

class RuanganViewModel extends BaseListViewModel {
  RuanganViewModel(this._service);

  final MockService _service;

  List<Ruangan> get items => _service.ruangan;

  void add({
    required String kodeRuangan,
    required String namaRuangan,
    required int kapasitasRuangan,
    required String lokasi,
  }) {
    runAction(
      () => _service.addRuangan(
        kodeRuangan: kodeRuangan,
        namaRuangan: namaRuangan,
        kapasitasRuangan: kapasitasRuangan,
        lokasi: lokasi,
      ),
    );
  }

  void update({
    required String kodeRuangan,
    required String namaRuangan,
    required int kapasitasRuangan,
    required String lokasi,
  }) {
    runAction(
      () => _service.updateRuangan(
        kodeRuangan: kodeRuangan,
        namaRuangan: namaRuangan,
        kapasitasRuangan: kapasitasRuangan,
        lokasi: lokasi,
      ),
    );
  }

  void delete(String kodeRuangan) {
    runAction(() => _service.deleteRuangan(kodeRuangan));
  }
}
