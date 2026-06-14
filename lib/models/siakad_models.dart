enum Role {
  mahasiswa,
  dosen,
  pimpinan,
  adminProdi,
  adminFakultas,
  adminUniversitas,
}

enum TingkatPimpinan { rektor, dekan, korpro }

extension TingkatPimpinanLabel on TingkatPimpinan {
  String get label {
    switch (this) {
      case TingkatPimpinan.rektor:
        return 'Rektor';
      case TingkatPimpinan.dekan:
        return 'Dekan';
      case TingkatPimpinan.korpro:
        return 'Koordinator Program Studi';
    }
  }
}

// Extension ini menerjemahkan nilai enum role menjadi teks yang tampil di UI.
extension RoleLabel on Role {
  String get label {
    switch (this) {
      case Role.mahasiswa:
        return 'Mahasiswa';
      case Role.dosen:
        return 'Dosen';
      case Role.pimpinan:
        return 'Pimpinan';
      case Role.adminProdi:
        return 'Operator Prodi';
      case Role.adminFakultas:
        return 'Admin Fakultas';
      case Role.adminUniversitas:
        return 'Admin Universitas';
    }
  }
}

class User {
  const User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.name,
    required this.scopeId,
    this.tingkatPimpinan,
  });

  final String id;
  final String username;
  final String password;
  final Role role;
  final String name;
  // scopeId membatasi area kerja user:
  // NIM untuk mahasiswa, NIDN untuk dosen, id prodi/fakultas untuk admin.
  final String scopeId;
  final TingkatPimpinan? tingkatPimpinan;
}

class Fakultas {
  const Fakultas({required this.id, required this.nama});

  final String id;
  final String nama;
}

class Prodi {
  const Prodi({required this.id, required this.nama, required this.fakultasId});

  final String id;
  final String nama;
  final String fakultasId;
}

enum SemesterAkademik { ganjil, genap }

extension SemesterAkademikLabel on SemesterAkademik {
  String get label => this == SemesterAkademik.ganjil ? 'Ganjil' : 'Genap';
}

class TahunAjaran {
  const TahunAjaran({
    required this.id,
    required this.nama,
    required this.semester,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    this.aktif = false,
  });

  final String id;
  final String nama;
  final SemesterAkademik semester;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final bool aktif;

  String get label => '$nama ${semester.label}';
}

class FaseKrs {
  const FaseKrs({
    required this.tahunAjaranId,
    required this.mulai,
    required this.berakhir,
    this.aktif = true,
  });

  final String tahunAjaranId;
  final DateTime mulai;
  final DateTime berakhir;
  final bool aktif;

  bool berlangsungPada(DateTime waktu) =>
      aktif && !waktu.isBefore(mulai) && !waktu.isAfter(berakhir);

  String statusPada(DateTime waktu) {
    if (!aktif) return 'Ditutup';
    if (waktu.isBefore(mulai)) return 'Terjadwal';
    if (waktu.isAfter(berakhir)) return 'Berakhir';
    return 'Berlangsung';
  }

  FaseKrs copyWith({
    String? tahunAjaranId,
    DateTime? mulai,
    DateTime? berakhir,
    bool? aktif,
  }) {
    return FaseKrs(
      tahunAjaranId: tahunAjaranId ?? this.tahunAjaranId,
      mulai: mulai ?? this.mulai,
      berakhir: berakhir ?? this.berakhir,
      aktif: aktif ?? this.aktif,
    );
  }
}

enum StatusMahasiswa { aktif, cuti, nonaktif, lulus, dropOut }

extension StatusMahasiswaLabel on StatusMahasiswa {
  String get label {
    switch (this) {
      case StatusMahasiswa.aktif:
        return 'Aktif';
      case StatusMahasiswa.cuti:
        return 'Cuti';
      case StatusMahasiswa.nonaktif:
        return 'Nonaktif';
      case StatusMahasiswa.lulus:
        return 'Lulus';
      case StatusMahasiswa.dropOut:
        return 'Drop Out';
    }
  }
}

class Mahasiswa {
  const Mahasiswa({
    required this.nim,
    required this.nama,
    required this.jenisKelamin,
    required this.prodiId,
    required this.password,
    required this.pembimbingAkademikId,
    this.semester = 1,
    this.email = '',
    this.noHp = '',
    this.alamat = '',
    this.status = StatusMahasiswa.aktif,
  });

  final String nim;
  final String nama;
  final String jenisKelamin;
  final String prodiId;
  final String password;
  final String pembimbingAkademikId;
  final int semester;
  final String email;
  final String noHp;
  final String alamat;
  final StatusMahasiswa status;

  Mahasiswa copyWith({
    String? nim,
    String? nama,
    String? jenisKelamin,
    String? prodiId,
    String? password,
    String? pembimbingAkademikId,
    int? semester,
    String? email,
    String? noHp,
    String? alamat,
    StatusMahasiswa? status,
  }) {
    return Mahasiswa(
      nim: nim ?? this.nim,
      nama: nama ?? this.nama,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      prodiId: prodiId ?? this.prodiId,
      password: password ?? this.password,
      pembimbingAkademikId: pembimbingAkademikId ?? this.pembimbingAkademikId,
      semester: semester ?? this.semester,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      alamat: alamat ?? this.alamat,
      status: status ?? this.status,
    );
  }
}

class RiwayatStatusMahasiswa {
  const RiwayatStatusMahasiswa({
    required this.id,
    required this.mahasiswaId,
    required this.statusSebelumnya,
    required this.statusBaru,
    required this.namaBukti,
    required this.tipeBukti,
    required this.ukuranBukti,
    required this.buktiBase64,
    required this.diubahPada,
  });

  final String id;
  final String mahasiswaId;
  final StatusMahasiswa statusSebelumnya;
  final StatusMahasiswa statusBaru;
  final String namaBukti;
  final String tipeBukti;
  final int ukuranBukti;
  final String buktiBase64;
  final DateTime diubahPada;
}

class Dosen {
  const Dosen({
    required this.nidn,
    required this.nama,
    required this.prodiId,
    required this.password,
    this.email = '',
    this.noHp = '',
    this.alamat = '',
    this.keahlian = '',
  });

  final String nidn;
  final String nama;
  final String prodiId;
  final String password;
  final String email;
  final String noHp;
  final String alamat;
  final String keahlian;

  Dosen copyWith({
    String? nidn,
    String? nama,
    String? prodiId,
    String? password,
    String? email,
    String? noHp,
    String? alamat,
    String? keahlian,
  }) {
    return Dosen(
      nidn: nidn ?? this.nidn,
      nama: nama ?? this.nama,
      prodiId: prodiId ?? this.prodiId,
      password: password ?? this.password,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      alamat: alamat ?? this.alamat,
      keahlian: keahlian ?? this.keahlian,
    );
  }
}

class MataKuliah {
  const MataKuliah({
    required this.kode,
    required this.nama,
    required this.sks,
    required this.prodiId,
  });

  final String kode;
  final String nama;
  final int sks;
  final String prodiId;
}

class Kelas {
  const Kelas({
    required this.id,
    required this.mataKuliahId,
    required this.dosenId,
    required this.kapasitas,
    required this.hari,
    required this.jam,
    required this.ruangan,
    this.tahunAjaranId = 'ta-2025-genap',
  });

  final String id;
  final String mataKuliahId;
  // Kelas menghubungkan mata kuliah dengan dosen pengampu dan jadwal.
  final String dosenId;
  final int kapasitas;
  final String hari;
  final String jam;
  // Field ini menyimpan kode ruangan. Nama/lokasi ruangan dibaca dari model
  // Ruangan agar kelas bisa divalidasi terhadap kapasitas dan bentrok jadwal.
  final String ruangan;
  final String tahunAjaranId;
}

class Ruangan {
  const Ruangan({
    required this.kodeRuangan,
    required this.namaRuangan,
    required this.kapasitasRuangan,
    required this.lokasi,
  });

  final String kodeRuangan;
  final String namaRuangan;
  final int kapasitasRuangan;
  final String lokasi;

  Ruangan copyWith({
    String? kodeRuangan,
    String? namaRuangan,
    int? kapasitasRuangan,
    String? lokasi,
  }) {
    return Ruangan(
      kodeRuangan: kodeRuangan ?? this.kodeRuangan,
      namaRuangan: namaRuangan ?? this.namaRuangan,
      kapasitasRuangan: kapasitasRuangan ?? this.kapasitasRuangan,
      lokasi: lokasi ?? this.lokasi,
    );
  }
}

class DosenPengajar {
  const DosenPengajar({
    required this.id,
    required this.idKelas,
    required this.nidnDosen,
    this.peranMengajar = 'Dosen Utama',
  });

  final String id;
  final String idKelas;
  final String nidnDosen;
  final String peranMengajar;
}

enum KrsStatus { draft, diajukan, disetujui, ditolak }

extension KrsStatusLabel on KrsStatus {
  String get label {
    switch (this) {
      case KrsStatus.draft:
        return 'Draft';
      case KrsStatus.diajukan:
        return 'Diajukan';
      case KrsStatus.disetujui:
        return 'Disetujui';
      case KrsStatus.ditolak:
        return 'Ditolak';
    }
  }
}

class KRS {
  const KRS({
    required this.id,
    required this.mahasiswaId,
    required this.kelasId,
    this.semester = 1,
    this.isSubmitted = false,
    this.isValidated = false,
    this.isRejected = false,
    this.catatanDosenPa = '',
    this.tahunAjaranId = 'ta-2025-genap',
  });

  final String id;
  // Relasi mahasiswa-kelas disimpan di KRS.
  // Dari data ini aplikasi bisa membentuk jadwal dan daftar peserta.
  final String mahasiswaId;
  final String kelasId;
  final int semester;
  final bool isSubmitted;
  final bool isValidated;
  final bool isRejected;
  final String catatanDosenPa;
  final String tahunAjaranId;

  KrsStatus get status {
    if (isValidated) return KrsStatus.disetujui;
    if (isRejected) return KrsStatus.ditolak;
    if (isSubmitted) return KrsStatus.diajukan;
    return KrsStatus.draft;
  }

  String get statusLabel => status.label;

  KRS copyWith({
    String? id,
    String? mahasiswaId,
    String? kelasId,
    int? semester,
    bool? isSubmitted,
    bool? isValidated,
    bool? isRejected,
    String? catatanDosenPa,
    String? tahunAjaranId,
  }) {
    return KRS(
      id: id ?? this.id,
      mahasiswaId: mahasiswaId ?? this.mahasiswaId,
      kelasId: kelasId ?? this.kelasId,
      semester: semester ?? this.semester,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isValidated: isValidated ?? this.isValidated,
      isRejected: isRejected ?? this.isRejected,
      catatanDosenPa: catatanDosenPa ?? this.catatanDosenPa,
      tahunAjaranId: tahunAjaranId ?? this.tahunAjaranId,
    );
  }
}

class Nilai {
  const Nilai({
    required this.id,
    required this.mahasiswaId,
    required this.kelasId,
    required this.nilaiAngka,
    required this.nilaiHuruf,
    this.semester = 1,
    this.nilaiTugas = 0,
    this.nilaiUts = 0,
    this.nilaiUas = 0,
    this.nilaiSoftskill = 0,
    this.bobotTugas = 25,
    this.bobotUts = 25,
    this.bobotUas = 35,
    this.bobotSoftskill = 15,
    this.tahunAjaranId = 'ta-2025-genap',
  });

  final String id;
  final String mahasiswaId;
  final String kelasId;
  final double nilaiAngka;
  final String nilaiHuruf;
  final int semester;
  final double nilaiTugas;
  final double nilaiUts;
  final double nilaiUas;
  final double nilaiSoftskill;
  final double bobotTugas;
  final double bobotUts;
  final double bobotUas;
  final double bobotSoftskill;
  final String tahunAjaranId;

  double get subBobotTugas => nilaiTugas * bobotTugas / 100;
  double get subBobotUts => nilaiUts * bobotUts / 100;
  double get subBobotUas => nilaiUas * bobotUas / 100;
  double get subBobotSoftskill => nilaiSoftskill * bobotSoftskill / 100;
  double get finalBobot =>
      subBobotTugas + subBobotUts + subBobotUas + subBobotSoftskill;
  double get totalBobot => bobotTugas + bobotUts + bobotUas + bobotSoftskill;
}

class Tugas {
  const Tugas({
    required this.id,
    required this.kelasId,
    required this.judul,
    required this.deskripsi,
    required this.deadline,
  });

  final String id;
  final String kelasId;
  final String judul;
  final String deskripsi;
  final DateTime deadline;
}

enum StatusPengajuan { diajukan, disetujui, selesai }

extension StatusPengajuanLabel on StatusPengajuan {
  String get label {
    switch (this) {
      case StatusPengajuan.diajukan:
        return 'Diajukan';
      case StatusPengajuan.disetujui:
        return 'Disetujui';
      case StatusPengajuan.selesai:
        return 'Selesai';
    }
  }
}

class Skripsi {
  const Skripsi({
    required this.id,
    required this.mahasiswaId,
    required this.judul,
    required this.topik,
    required this.pembimbingId,
    required this.dibuatPada,
    this.status = StatusPengajuan.diajukan,
    this.catatan = const [],
  });

  final String id;
  final String mahasiswaId;
  final String judul;
  final String topik;
  final String pembimbingId;
  final DateTime dibuatPada;
  final StatusPengajuan status;
  final List<String> catatan;

  Skripsi copyWith({StatusPengajuan? status, List<String>? catatan}) {
    return Skripsi(
      id: id,
      mahasiswaId: mahasiswaId,
      judul: judul,
      topik: topik,
      pembimbingId: pembimbingId,
      dibuatPada: dibuatPada,
      status: status ?? this.status,
      catatan: catatan ?? this.catatan,
    );
  }
}

class Magang {
  const Magang({
    required this.id,
    required this.mahasiswaId,
    required this.instansi,
    required this.posisi,
    required this.dibuatPada,
    this.status = StatusPengajuan.diajukan,
  });

  final String id;
  final String mahasiswaId;
  final String instansi;
  final String posisi;
  final DateTime dibuatPada;
  final StatusPengajuan status;
}

class Kkn {
  const Kkn({
    required this.id,
    required this.mahasiswaId,
    required this.lokasi,
    required this.tema,
    required this.dibuatPada,
    this.status = StatusPengajuan.diajukan,
  });

  final String id;
  final String mahasiswaId;
  final String lokasi;
  final String tema;
  final DateTime dibuatPada;
  final StatusPengajuan status;
}

enum StatusPertemuan { belumDimulai, berlangsung, selesai }

class Pertemuan {
  const Pertemuan({
    required this.id,
    required this.kelasId,
    required this.pertemuanKe,
    required this.status,
    this.materi,
    this.waktuMulai,
  });

  final String id;
  final String kelasId;
  final int pertemuanKe;
  final StatusPertemuan status;
  final String? materi;
  final DateTime? waktuMulai;

  // copyWith dipakai saat status pertemuan berubah tanpa membuat seluruh
  // object dari nol di setiap update presensi.
  Pertemuan copyWith({
    StatusPertemuan? status,
    String? materi,
    DateTime? waktuMulai,
  }) {
    return Pertemuan(
      id: id,
      kelasId: kelasId,
      pertemuanKe: pertemuanKe,
      status: status ?? this.status,
      materi: materi ?? this.materi,
      waktuMulai: waktuMulai ?? this.waktuMulai,
    );
  }
}

class Presensi {
  const Presensi({
    required this.id,
    required this.pertemuanId,
    required this.mahasiswaId,
    required this.statusKehadiran,
    this.waktuPresensi,
    this.catatan = '',
  });

  final String id;
  final String pertemuanId;
  final String mahasiswaId;
  final String statusKehadiran; // 'Hadir', 'Ijin', 'Sakit', 'Alpa'
  final DateTime? waktuPresensi;
  final String catatan;
}

class PresensiDosen {
  const PresensiDosen({
    required this.id,
    required this.pertemuanId,
    required this.dosenId,
    required this.statusKehadiran,
    required this.waktuPresensi,
    this.catatan = '',
  });

  final String id;
  final String pertemuanId;
  final String dosenId;
  final String statusKehadiran;
  final DateTime waktuPresensi;
  final String catatan;
}
