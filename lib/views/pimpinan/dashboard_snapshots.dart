part of '../pimpinan_views.dart';

class DashboardCacheKey {
  const DashboardCacheKey({
    required this.revision,
    required this.tahunAjaranId,
    this.semester,
    this.fakultasId,
    this.prodiId,
    this.mataKuliahId,
    this.dosenId,
    this.statusKrs,
    this.statusPresensi,
  });

  final int revision;
  final String tahunAjaranId;
  final SemesterAkademik? semester;
  final String? fakultasId;
  final String? prodiId;
  final String? mataKuliahId;
  final String? dosenId;
  final KrsStatus? statusKrs;
  final String? statusPresensi;

  @override
  bool operator ==(Object other) =>
      other is DashboardCacheKey &&
      revision == other.revision &&
      tahunAjaranId == other.tahunAjaranId &&
      semester == other.semester &&
      fakultasId == other.fakultasId &&
      prodiId == other.prodiId &&
      mataKuliahId == other.mataKuliahId &&
      dosenId == other.dosenId &&
      statusKrs == other.statusKrs &&
      statusPresensi == other.statusPresensi;

  @override
  int get hashCode => Object.hash(
    revision,
    tahunAjaranId,
    semester,
    fakultasId,
    prodiId,
    mataKuliahId,
    dosenId,
    statusKrs,
    statusPresensi,
  );
}

class _RektorDashboardSnapshot {
  _RektorDashboardSnapshot._({
    required this.key,
    required this.tahun,
    required this.prodi,
    required this.prodiIds,
    required this.mahasiswa,
    required this.mahasiswaIds,
    required this.dosen,
    required this.mataKuliah,
    required this.mataKuliahIds,
    required this.kelas,
    required this.kelasIds,
    required this.krs,
    required this.pertemuan,
    required this.presensiMahasiswa,
    required this.presensiDosen,
    required this.hadirMahasiswa,
    required this.hadirDosen,
    required this.sudahKrs,
    required this.krsApproved,
    required this.ruangTerpakai,
    required this.fakultasMetrics,
    required this.topFakultas,
    required this.topProdi,
    required this.krsApprovalRate,
    required this.presensiMahasiswaRate,
    required this.presensiDosenRate,
    required this.kapasitasKelasRate,
    required this.ruangTerpakaiRate,
    required this.campusHealth,
    required this.waitingKrs,
    required this.unusedRooms,
    required this.fullClasses,
    required this.activeFilters,
  });

  factory _RektorDashboardSnapshot.build({
    required MockService service,
    required String tahunId,
    required SemesterAkademik? semester,
    required String? fakultasId,
    required String? prodiId,
    required String? mataKuliahId,
    required String? dosenId,
    required KrsStatus? statusKrs,
    required String? statusPresensi,
  }) {
    final key = DashboardCacheKey(
      revision: service.dataRevision,
      tahunAjaranId: tahunId,
      semester: semester,
      fakultasId: fakultasId,
      prodiId: prodiId,
      mataKuliahId: mataKuliahId,
      dosenId: dosenId,
      statusKrs: statusKrs,
      statusPresensi: statusPresensi,
    );
    final tahun = service.tahunAjaran.firstWhere((item) => item.id == tahunId);
    final prodi =
        (fakultasId == null
                ? service.prodi
                : service.prodiByFakultasId(fakultasId))
            .where((item) => prodiId == null || item.id == prodiId)
            .toList(growable: false);
    final prodiIds = prodi.map((item) => item.id).toSet();
    final mahasiswa = service.mahasiswaByProdiIds(prodiIds);
    final mahasiswaIds = mahasiswa.map((item) => item.nim).toSet();
    final dosen = service
        .dosenByProdiIds(prodiIds)
        .where((item) => dosenId == null || item.nidn == dosenId)
        .toList(growable: false);
    final mataKuliah = service
        .mataKuliahByProdiIds(prodiIds)
        .where((item) => mataKuliahId == null || item.kode == mataKuliahId)
        .toList(growable: false);
    final mataKuliahIds = mataKuliah.map((item) => item.kode).toSet();
    final kelas = service
        .kelasByTahunAjaran(tahunId)
        .where(
          (item) =>
              mataKuliahIds.contains(item.mataKuliahId) &&
              (semester == null || tahun.semester == semester) &&
              (dosenId == null ||
                  service.isDosenMengajarKelas(dosenId, item.id)),
        )
        .toList(growable: false);
    final kelasIds = kelas.map((item) => item.id).toSet();
    final krs = service
        .krsByKelasIds(kelasIds)
        .where(
          (item) =>
              mahasiswaIds.contains(item.mahasiswaId) &&
              item.tahunAjaranId == tahunId &&
              (statusKrs == null || item.status == statusKrs),
        )
        .toList(growable: false);
    final pertemuan = service.pertemuanByKelasIds(kelasIds);
    final pertemuanIds = pertemuan.map((item) => item.id).toSet();
    final presensiMahasiswa = service
        .presensiByPertemuanIds(pertemuanIds)
        .where(
          (item) =>
              statusPresensi == null ||
              _sameStatus(item.statusKehadiran, statusPresensi),
        )
        .toList(growable: false);
    final presensiDosen = service
        .presensiDosenByPertemuanIds(pertemuanIds)
        .where(
          (item) =>
              statusPresensi == null ||
              _sameStatus(item.statusKehadiran, statusPresensi),
        )
        .toList(growable: false);
    final hadirMahasiswa = _countStatus(presensiMahasiswa, 'Hadir');
    final hadirDosen = _countDosenStatus(presensiDosen, 'Hadir');
    final sudahKrs = krs.map((item) => item.mahasiswaId).toSet().length;
    final krsApproved = krs.where((item) => item.isValidated).length;
    final ruangTerpakai = kelas.map((item) => item.ruangan).toSet();
    final fakultasMetrics = service.fakultas
        .map((item) => _fakultasMetric(service, item.id, tahunId))
        .toList(growable: false);
    final topFakultas = fakultasMetrics.isEmpty
        ? '-'
        : (fakultasMetrics.toList()
                ..sort((a, b) => b.mahasiswa.compareTo(a.mahasiswa)))
              .first
              .nama;
    final topProdi = service.prodi.isEmpty
        ? '-'
        : (service.prodi.toList()..sort(
                (a, b) => service
                    .mahasiswaByProdiId(b.id)
                    .length
                    .compareTo(service.mahasiswaByProdiId(a.id).length),
              ))
              .first
              .nama;
    final krsApprovalRate = krs.isEmpty ? 0.0 : krsApproved / krs.length;
    final presensiMahasiswaRate = presensiMahasiswa.isEmpty
        ? 0.0
        : hadirMahasiswa / presensiMahasiswa.length;
    final presensiDosenRate = presensiDosen.isEmpty
        ? 0.0
        : hadirDosen / presensiDosen.length;
    final fullClasses = kelas.where((e) => service.isKelasPenuh(e.id)).length;
    final kapasitasKelasRate = kelas.isEmpty ? 0.0 : fullClasses / kelas.length;
    final ruangTerpakaiRate = service.ruangan.isEmpty
        ? 0.0
        : ruangTerpakai.length / service.ruangan.length;
    final campusHealth =
        ((krsApprovalRate * 0.28) +
            (presensiMahasiswaRate * 0.30) +
            (presensiDosenRate * 0.24) +
            ((1 - kapasitasKelasRate).clamp(0.0, 1.0).toDouble() * 0.10) +
            (ruangTerpakaiRate * 0.08)) *
        100;
    final waitingKrs = krs
        .where((e) => e.isSubmitted && !e.isValidated && !e.isRejected)
        .length;
    final unusedRooms = (service.ruangan.length - ruangTerpakai.length).clamp(
      0,
      99999,
    );
    final activeFilters = <String>[tahun.label];
    if (semester != null) activeFilters.add(semester.label);
    if (fakultasId != null) {
      activeFilters.add(
        service.fakultas.firstWhere((item) => item.id == fakultasId).nama,
      );
    }
    if (prodiId != null) {
      activeFilters.add(
        service.prodi.firstWhere((item) => item.id == prodiId).nama,
      );
    }
    if (mataKuliahId != null) {
      activeFilters.add(
        service.mataKuliah.firstWhere((item) => item.kode == mataKuliahId).nama,
      );
    }
    if (dosenId != null) {
      activeFilters.add(
        service.dosen.firstWhere((item) => item.nidn == dosenId).nama,
      );
    }
    if (statusKrs != null) activeFilters.add(statusKrs.label);
    if (statusPresensi != null) activeFilters.add(statusPresensi);

    return _RektorDashboardSnapshot._(
      key: key,
      tahun: tahun,
      prodi: prodi,
      prodiIds: prodiIds,
      mahasiswa: mahasiswa,
      mahasiswaIds: mahasiswaIds,
      dosen: dosen,
      mataKuliah: mataKuliah,
      mataKuliahIds: mataKuliahIds,
      kelas: kelas,
      kelasIds: kelasIds,
      krs: krs,
      pertemuan: pertemuan,
      presensiMahasiswa: presensiMahasiswa,
      presensiDosen: presensiDosen,
      hadirMahasiswa: hadirMahasiswa,
      hadirDosen: hadirDosen,
      sudahKrs: sudahKrs,
      krsApproved: krsApproved,
      ruangTerpakai: ruangTerpakai,
      fakultasMetrics: fakultasMetrics,
      topFakultas: topFakultas,
      topProdi: topProdi,
      krsApprovalRate: krsApprovalRate,
      presensiMahasiswaRate: presensiMahasiswaRate,
      presensiDosenRate: presensiDosenRate,
      kapasitasKelasRate: kapasitasKelasRate,
      ruangTerpakaiRate: ruangTerpakaiRate,
      campusHealth: campusHealth,
      waitingKrs: waitingKrs,
      unusedRooms: unusedRooms,
      fullClasses: fullClasses,
      activeFilters: activeFilters,
    );
  }

  final DashboardCacheKey key;
  final TahunAjaran tahun;
  final List<Prodi> prodi;
  final Set<String> prodiIds;
  final List<Mahasiswa> mahasiswa;
  final Set<String> mahasiswaIds;
  final List<Dosen> dosen;
  final List<MataKuliah> mataKuliah;
  final Set<String> mataKuliahIds;
  final List<Kelas> kelas;
  final Set<String> kelasIds;
  final List<KRS> krs;
  final List<Pertemuan> pertemuan;
  final List<Presensi> presensiMahasiswa;
  final List<PresensiDosen> presensiDosen;
  final int hadirMahasiswa;
  final int hadirDosen;
  final int sudahKrs;
  final int krsApproved;
  final Set<String> ruangTerpakai;
  final List<_FakultasMetric> fakultasMetrics;
  final String topFakultas;
  final String topProdi;
  final double krsApprovalRate;
  final double presensiMahasiswaRate;
  final double presensiDosenRate;
  final double kapasitasKelasRate;
  final double ruangTerpakaiRate;
  final double campusHealth;
  final int waitingKrs;
  final int unusedRooms;
  final int fullClasses;
  final List<String> activeFilters;
}

class _DekanDashboardSnapshot {
  _DekanDashboardSnapshot._({
    required this.key,
    required this.fakultas,
    required this.tahun,
    required this.prodiFakultas,
    required this.scopedProdiIds,
    required this.mahasiswa,
    required this.mahasiswaIds,
    required this.dosen,
    required this.mataKuliah,
    required this.kelas,
    required this.kelasIds,
    required this.krs,
    required this.sudahKrs,
    required this.pertemuan,
    required this.presensiMahasiswa,
    required this.presensiDosen,
    required this.hadirMahasiswa,
    required this.hadirDosen,
    required this.ruangTerpakai,
    required this.kelasAktif,
    required this.dosenBelumPresensi,
    required this.mataKuliahPresensiRendah,
  });

  factory _DekanDashboardSnapshot.build({
    required MockService service,
    required String fakultasId,
    required String tahunId,
    required SemesterAkademik? semester,
    required String? prodiId,
  }) {
    final key = DashboardCacheKey(
      revision: service.dataRevision,
      tahunAjaranId: tahunId,
      semester: semester,
      fakultasId: fakultasId,
      prodiId: prodiId,
    );
    final fakultas = service.fakultas.firstWhere(
      (item) => item.id == fakultasId,
    );
    final tahun = service.tahunAjaran.firstWhere((item) => item.id == tahunId);
    final prodiFakultas = service.prodiByFakultasId(fakultasId);
    final scopedProdiIds = prodiFakultas
        .where((item) => prodiId == null || item.id == prodiId)
        .map((item) => item.id)
        .toSet();
    final mahasiswa = service
        .mahasiswaByProdiIds(scopedProdiIds)
        .where((item) => item.status == StatusMahasiswa.aktif)
        .toList(growable: false);
    final mahasiswaIds = mahasiswa.map((item) => item.nim).toSet();
    final dosen = service.dosenByProdiIds(scopedProdiIds);
    final mataKuliah = service.mataKuliahByProdiIds(scopedProdiIds);
    final mataKuliahIds = mataKuliah.map((item) => item.kode).toSet();
    final kelas = service
        .kelasByTahunAjaran(tahunId)
        .where(
          (item) =>
              mataKuliahIds.contains(item.mataKuliahId) &&
              (semester == null || tahun.semester == semester),
        )
        .toList(growable: false);
    final kelasIds = kelas.map((item) => item.id).toSet();
    final krs = service
        .krsByKelasIds(kelasIds)
        .where(
          (item) =>
              mahasiswaIds.contains(item.mahasiswaId) &&
              item.tahunAjaranId == tahunId,
        )
        .toList(growable: false);
    final sudahKrs = krs.map((item) => item.mahasiswaId).toSet().length;
    final pertemuan = service.pertemuanByKelasIds(kelasIds);
    final pertemuanIds = pertemuan.map((item) => item.id).toSet();
    final presensiMahasiswa = service.presensiByPertemuanIds(pertemuanIds);
    final presensiDosen = service.presensiDosenByPertemuanIds(pertemuanIds);
    final hadirMahasiswa = _countStatus(presensiMahasiswa, 'Hadir');
    final hadirDosen = _countDosenStatus(presensiDosen, 'Hadir');
    final ruangTerpakai = kelas.map((item) => item.ruangan).toSet();
    final kelasAktif = pertemuan
        .where((item) => item.status == StatusPertemuan.berlangsung)
        .map((item) => item.kelasId)
        .toSet()
        .length;
    final dosenBelumPresensi = dosen
        .where(
          (item) =>
              kelas.any(
                (kelas) => service.isDosenMengajarKelas(item.nidn, kelas.id),
              ) &&
              !presensiDosen.any((presensi) => presensi.dosenId == item.nidn),
        )
        .length;
    final mataKuliahPresensiRendah = mataKuliah.where((mk) {
      final ids = kelas
          .where((item) => item.mataKuliahId == mk.kode)
          .map((item) => item.id)
          .toSet();
      final ptmIds = pertemuan
          .where((item) => ids.contains(item.kelasId))
          .map((item) => item.id)
          .toSet();
      final items = presensiMahasiswa
          .where((item) => ptmIds.contains(item.pertemuanId))
          .toList();
      if (items.isEmpty) return false;
      return _countStatus(items, 'Hadir') / items.length < 0.75;
    }).length;

    return _DekanDashboardSnapshot._(
      key: key,
      fakultas: fakultas,
      tahun: tahun,
      prodiFakultas: prodiFakultas,
      scopedProdiIds: scopedProdiIds,
      mahasiswa: mahasiswa,
      mahasiswaIds: mahasiswaIds,
      dosen: dosen,
      mataKuliah: mataKuliah,
      kelas: kelas,
      kelasIds: kelasIds,
      krs: krs,
      sudahKrs: sudahKrs,
      pertemuan: pertemuan,
      presensiMahasiswa: presensiMahasiswa,
      presensiDosen: presensiDosen,
      hadirMahasiswa: hadirMahasiswa,
      hadirDosen: hadirDosen,
      ruangTerpakai: ruangTerpakai,
      kelasAktif: kelasAktif,
      dosenBelumPresensi: dosenBelumPresensi,
      mataKuliahPresensiRendah: mataKuliahPresensiRendah,
    );
  }

  final DashboardCacheKey key;
  final Fakultas fakultas;
  final TahunAjaran tahun;
  final List<Prodi> prodiFakultas;
  final Set<String> scopedProdiIds;
  final List<Mahasiswa> mahasiswa;
  final Set<String> mahasiswaIds;
  final List<Dosen> dosen;
  final List<MataKuliah> mataKuliah;
  final List<Kelas> kelas;
  final Set<String> kelasIds;
  final List<KRS> krs;
  final int sudahKrs;
  final List<Pertemuan> pertemuan;
  final List<Presensi> presensiMahasiswa;
  final List<PresensiDosen> presensiDosen;
  final int hadirMahasiswa;
  final int hadirDosen;
  final Set<String> ruangTerpakai;
  final int kelasAktif;
  final int dosenBelumPresensi;
  final int mataKuliahPresensiRendah;
}

class _KorproDashboardSnapshot {
  _KorproDashboardSnapshot._({
    required this.key,
    required this.prodi,
    required this.tahunAktif,
    required this.mahasiswa,
    required this.mahasiswaMetrics,
    required this.mataKuliahIds,
    required this.kelas,
    required this.ruangKelas,
    required this.kelasAktif,
    required this.kelasMetrics,
    required this.krs,
    required this.approvedKrs,
    required this.krsRate,
    required this.activeStudents,
    required this.avgIpk,
    required this.avgPresensi,
    required this.avgSks,
    required this.riskStudents,
    required this.completedMeetings,
    required this.totalMeetingSlots,
    required this.meetingProgress,
    required this.healthScore,
    required this.rankedStudents,
    required this.rankedClasses,
    required this.points,
  });

  factory _KorproDashboardSnapshot.build({
    required MockService service,
    required String prodiId,
  }) {
    final tahunAktif = service.tahunAjaran.firstWhere(
      (item) => item.aktif,
      orElse: () => service.tahunAjaran.last,
    );
    final key = DashboardCacheKey(
      revision: service.dataRevision,
      tahunAjaranId: tahunAktif.id,
      prodiId: prodiId,
    );
    final prodi = service.prodi.firstWhere((item) => item.id == prodiId);
    final mahasiswa = service.mahasiswaByProdiId(prodiId);
    final mahasiswaIds = mahasiswa.map((item) => item.nim).toSet();
    final mahasiswaMetrics = mahasiswa
        .map((item) => _korproMahasiswaMetric(service, item))
        .toList(growable: false);
    final mataKuliahIds = service
        .mataKuliahByProdiId(prodiId)
        .map((item) => item.kode)
        .toSet();
    final kelas = service.kelas
        .where((item) => mataKuliahIds.contains(item.mataKuliahId))
        .toList(growable: false);
    final ruangKelas = kelas.map((item) => item.ruangan).toSet();
    final kelasAktif = service
        .kelasByTahunAjaran(tahunAktif.id)
        .where((item) => mataKuliahIds.contains(item.mataKuliahId))
        .toList(growable: false);
    final kelasMetrics = _korproKelasAttendanceMetrics(
      service,
      prodiId,
      tahunAktif.id,
    );
    final kelasIds = kelasAktif.map((item) => item.id).toSet();
    final krs = service
        .krsByKelasIds(kelasIds)
        .where((item) => mahasiswaIds.contains(item.mahasiswaId))
        .toList(growable: false);
    final approvedKrs = krs.where((item) => item.isValidated).length;
    final krsRate = krs.isEmpty ? 0.0 : approvedKrs / krs.length;
    final activeStudents = mahasiswa
        .where((item) => item.status == StatusMahasiswa.aktif)
        .length;
    final avgIpk = mahasiswaMetrics.isEmpty
        ? 0.0
        : mahasiswaMetrics.fold<double>(0, (sum, item) => sum + item.ipk) /
              mahasiswaMetrics.length;
    final avgPresensi = mahasiswaMetrics.isEmpty
        ? 0.0
        : mahasiswaMetrics.fold<double>(
                0,
                (sum, item) => sum + item.presensiRate,
              ) /
              mahasiswaMetrics.length;
    final totalSks = mahasiswaMetrics.fold<int>(
      0,
      (sum, item) => sum + item.sksDisetujui,
    );
    final avgSks = mahasiswaMetrics.isEmpty
        ? 0.0
        : totalSks / mahasiswaMetrics.length;
    final riskStudents = mahasiswaMetrics
        .where((item) => item.riskLevel > 0)
        .length;
    final completedMeetings = kelasMetrics.fold<int>(
      0,
      (sum, item) =>
          sum + item.meetings.where((meeting) => meeting.hasData).length,
    );
    final totalMeetingSlots = kelasMetrics.length * 16;
    final meetingProgress = totalMeetingSlots == 0
        ? 0.0
        : completedMeetings / totalMeetingSlots;
    final healthScore =
        ((avgPresensi * 0.32) +
            ((avgIpk / 4).clamp(0.0, 1.0) * 0.26) +
            (krsRate * 0.22) +
            (meetingProgress * 0.20)) *
        100;
    final rankedStudents = mahasiswaMetrics.toList()
      ..sort((a, b) => b.riskLevel.compareTo(a.riskLevel));
    final rankedClasses =
        kelasMetrics.where((item) => item.totalMahasiswa > 0).toList()
          ..sort((a, b) => a.mahasiswaRate.compareTo(b.mahasiswaRate));
    final points = <_IpkTahunPoint>[];
    for (final tahun in service.tahunAjaran) {
      final nilai = service.nilai
          .where(
            (item) =>
                mahasiswaIds.contains(item.mahasiswaId) &&
                item.tahunAjaranId == tahun.id,
          )
          .toList();
      if (nilai.isEmpty) continue;
      final semester = nilai
          .map((item) => item.semester)
          .reduce((a, b) => a < b ? a : b);
      final rataRata =
          nilai
              .map((item) => _bobotNilai(item.nilaiHuruf))
              .reduce((a, b) => a + b) /
          nilai.length;
      points.add(
        _IpkTahunPoint(
          label:
              '${tahun.nama.replaceAll('20', '').replaceAll('/', '/')}\n${tahun.semester.label} S$semester',
          value: rataRata,
        ),
      );
    }

    return _KorproDashboardSnapshot._(
      key: key,
      prodi: prodi,
      tahunAktif: tahunAktif,
      mahasiswa: mahasiswa,
      mahasiswaMetrics: mahasiswaMetrics,
      mataKuliahIds: mataKuliahIds,
      kelas: kelas,
      ruangKelas: ruangKelas,
      kelasAktif: kelasAktif,
      kelasMetrics: kelasMetrics,
      krs: krs,
      approvedKrs: approvedKrs,
      krsRate: krsRate,
      activeStudents: activeStudents,
      avgIpk: avgIpk,
      avgPresensi: avgPresensi,
      avgSks: avgSks,
      riskStudents: riskStudents,
      completedMeetings: completedMeetings,
      totalMeetingSlots: totalMeetingSlots,
      meetingProgress: meetingProgress,
      healthScore: healthScore,
      rankedStudents: rankedStudents,
      rankedClasses: rankedClasses,
      points: points,
    );
  }

  final DashboardCacheKey key;
  final Prodi prodi;
  final TahunAjaran tahunAktif;
  final List<Mahasiswa> mahasiswa;
  final List<_KorproMahasiswaMetric> mahasiswaMetrics;
  final Set<String> mataKuliahIds;
  final List<Kelas> kelas;
  final Set<String> ruangKelas;
  final List<Kelas> kelasAktif;
  final List<_KorproKelasAttendanceMetric> kelasMetrics;
  final List<KRS> krs;
  final int approvedKrs;
  final double krsRate;
  final int activeStudents;
  final double avgIpk;
  final double avgPresensi;
  final double avgSks;
  final int riskStudents;
  final int completedMeetings;
  final int totalMeetingSlots;
  final double meetingProgress;
  final double healthScore;
  final List<_KorproMahasiswaMetric> rankedStudents;
  final List<_KorproKelasAttendanceMetric> rankedClasses;
  final List<_IpkTahunPoint> points;
}
