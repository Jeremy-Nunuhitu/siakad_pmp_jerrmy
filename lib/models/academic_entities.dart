import 'mata_kuliah.dart';

class Fakultas {
  const Fakultas({
    required this.id,
    required this.nama,
    required this.dekan,
    required this.jumlahProdi,
  });

  final String id;
  final String nama;
  final String dekan;
  final int jumlahProdi;
}

class Prodi {
  const Prodi({
    required this.id,
    required this.nama,
    required this.fakultas,
    required this.kaprodi,
  });

  final String id;
  final String nama;
  final String fakultas;
  final String kaprodi;
}

class Dosen {
  const Dosen({
    required this.id,
    required this.nama,
    required this.nidn,
    required this.prodi,
  });

  final String id;
  final String nama;
  final String nidn;
  final String prodi;
}

class KelasKuliah {
  const KelasKuliah({
    required this.id,
    required this.namaKelas,
    required this.mataKuliah,
    required this.dosen,
    required this.kuota,
    required this.terisi,
  });

  final String id;
  final String namaKelas;
  final MataKuliah mataKuliah;
  final Dosen dosen;
  final int kuota;
  final int terisi;
}
