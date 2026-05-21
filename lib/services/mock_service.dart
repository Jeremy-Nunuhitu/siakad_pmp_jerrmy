import 'dart:collection';

import '../models/siakad_models.dart';

class MockService {
  // Data di bawah berperan sebagai database sementara selama aplikasi berjalan.
  // Karena tersimpan di memory, data akan kembali ke default saat app direstart.
  final List<User> _users = [
    const User(
      id: 'u-001',
      username: 'univ',
      password: 'password',
      role: Role.adminUniversitas,
      name: 'Admin Universitas',
      scopeId: 'global',
    ),
    const User(
      id: 'u-002',
      username: 'fakultas',
      password: 'password',
      role: Role.adminFakultas,
      name: 'Admin Fakultas Teknik',
      scopeId: 'f-01',
    ),
    const User(
      id: 'u-003',
      username: 'operator',
      password: 'password',
      role: Role.adminProdi,
      name: 'Operator Prodi Informatika',
      scopeId: 'p-01',
    ),
  ];

  final List<Fakultas> _fakultas = [
    const Fakultas(id: 'f-01', nama: 'Fakultas Teknik'),
    const Fakultas(id: 'f-02', nama: 'Fakultas Ekonomi dan Bisnis'),
  ];

  final List<Prodi> _prodi = [
    const Prodi(id: 'p-01', nama: 'Informatika', fakultasId: 'f-01'),
    const Prodi(id: 'p-02', nama: 'Sistem Informasi', fakultasId: 'f-01'),
    const Prodi(id: 'p-03', nama: 'Manajemen', fakultasId: 'f-02'),
  ];

  final List<Mahasiswa> _mahasiswa = [
    const Mahasiswa(
      nim: '2406080046',
      nama: 'Jeremy Nunuhitu',
      jenisKelamin: 'Laki-laki',
      prodiId: 'p-01',
      password: 'password',
      pembimbingAkademikId: 'd-01',
      semester: 5,
      email: 'jeremy.nunuhitu@student.ac.id',
      noHp: '081234567890',
      alamat: 'Jl. Pendidikan No. 46',
    ),
    const Mahasiswa(
      nim: '221110124',
      nama: 'Aulia Putri',
      jenisKelamin: 'Perempuan',
      prodiId: 'p-01',
      password: 'password',
      pembimbingAkademikId: 'd-01',
      semester: 5,
      email: 'aulia.putri@student.ac.id',
      noHp: '081298765432',
      alamat: 'Jl. Merdeka No. 12',
    ),
    const Mahasiswa(
      nim: '221110125',
      nama: 'Rafi Mahendra',
      jenisKelamin: 'Laki-laki',
      prodiId: 'p-02',
      password: 'password',
      pembimbingAkademikId: 'd-03',
      semester: 3,
      email: 'rafi.mahendra@student.ac.id',
      noHp: '081377778888',
      alamat: 'Jl. Kampus No. 8',
    ),
  ];

  final List<Dosen> _dosen = [
    const Dosen(
      nidn: 'd-01',
      nama: 'Dr. Andi Pratama',
      prodiId: 'p-01',
      password: 'password',
      email: 'andi.pratama@kampus.ac.id',
      noHp: '081245670001',
      alamat: 'Jl. Dosen Informatika No. 1',
      keahlian: 'Mobile Computing',
    ),
    const Dosen(
      nidn: 'd-02',
      nama: 'Nadia Rahma, M.Kom',
      prodiId: 'p-01',
      password: 'password',
      email: 'nadia.rahma@kampus.ac.id',
      noHp: '081245670002',
      alamat: 'Jl. Basis Data No. 2',
      keahlian: 'Database Systems',
    ),
    const Dosen(
      nidn: 'd-03',
      nama: 'Fitri Lestari, M.Cs',
      prodiId: 'p-02',
      password: 'password',
      email: 'fitri.lestari@kampus.ac.id',
      noHp: '081245670003',
      alamat: 'Jl. Sistem Informasi No. 3',
      keahlian: 'Software Engineering',
    ),
  ];

  final List<MataKuliah> _mataKuliah = [
    const MataKuliah(
      kode: 'IF401',
      nama: 'Pemrograman Mobile',
      sks: 3,
      prodiId: 'p-01',
    ),
    const MataKuliah(
      kode: 'IF402',
      nama: 'Basis Data Lanjut',
      sks: 3,
      prodiId: 'p-01',
    ),
    const MataKuliah(
      kode: 'IF403',
      nama: 'Rekayasa Perangkat Lunak',
      sks: 3,
      prodiId: 'p-01',
    ),
  ];

  final List<Kelas> _kelas = [
    const Kelas(
      id: 'k-01',
      mataKuliahId: 'IF401',
      dosenId: 'd-01',
      kapasitas: 30,
      hari: 'Senin',
      jam: '08.00 - 10.30',
      ruangan: 'Lab Mobile',
    ),
    const Kelas(
      id: 'k-02',
      mataKuliahId: 'IF402',
      dosenId: 'd-02',
      kapasitas: 1,
      hari: 'Selasa',
      jam: '10.40 - 13.10',
      ruangan: 'Ruang 204',
    ),
  ];

  final List<KRS> _krs = [
    const KRS(
      id: 'krs-01',
      mahasiswaId: '2406080046',
      kelasId: 'k-01',
      semester: 5,
      isSubmitted: true,
      isValidated: true,
    ),
    const KRS(
      id: 'krs-02',
      mahasiswaId: '2406080046',
      kelasId: 'k-02',
      semester: 4,
      isSubmitted: true,
      isValidated: true,
    ),
  ];

  final List<Nilai> _nilai = [
    const Nilai(
      id: 'n-01',
      mahasiswaId: '2406080046',
      kelasId: 'k-01',
      nilaiAngka: 88,
      nilaiHuruf: 'A',
      semester: 5,
      nilaiTugas: 90,
      nilaiUts: 84,
      nilaiUas: 88,
      nilaiSoftskill: 92,
      bobotTugas: 25,
      bobotUts: 25,
      bobotUas: 35,
      bobotSoftskill: 15,
    ),
    const Nilai(
      id: 'n-02',
      mahasiswaId: '2406080046',
      kelasId: 'k-02',
      nilaiAngka: 82,
      nilaiHuruf: 'B+',
      semester: 4,
      nilaiTugas: 86,
      nilaiUts: 78,
      nilaiUas: 80,
      nilaiSoftskill: 88,
      bobotTugas: 25,
      bobotUts: 25,
      bobotUas: 35,
      bobotSoftskill: 15,
    ),
  ];

  final List<Tugas> _tugas = [
    Tugas(
      id: 't-01',
      kelasId: 'k-01',
      judul: 'Tugas 1: UI/UX Design',
      deskripsi: 'Membuat rancangan UI/UX menggunakan Figma.',
      deadline: DateTime.now().add(const Duration(days: 3)),
    ),
    Tugas(
      id: 't-02',
      kelasId: 'k-01',
      judul: 'Tugas 2: Flutter Layout',
      deskripsi: 'Implementasi rancangan UI ke Flutter.',
      deadline: DateTime.now().add(const Duration(days: 7)),
    ),
  ];
  final List<Skripsi> _skripsi = [];
  final List<Magang> _magang = [];
  final List<Kkn> _kkn = [];

  final List<Pertemuan> _pertemuan = [];
  final List<Presensi> _presensi = [];

  // View read-only dibuat sekali agar build UI tidak terus membuat list baru.
  late final List<User> users = UnmodifiableListView(_users);
  late final List<Fakultas> fakultas = UnmodifiableListView(_fakultas);
  late final List<Prodi> prodi = UnmodifiableListView(_prodi);
  late final List<Mahasiswa> mahasiswa = UnmodifiableListView(_mahasiswa);
  late final List<Dosen> dosen = UnmodifiableListView(_dosen);
  late final List<MataKuliah> mataKuliah = UnmodifiableListView(_mataKuliah);
  late final List<Kelas> kelas = UnmodifiableListView(_kelas);
  late final List<KRS> krs = UnmodifiableListView(_krs);
  late final List<Nilai> nilai = UnmodifiableListView(_nilai);
  late final List<Tugas> tugas = UnmodifiableListView(_tugas);
  late final List<Skripsi> skripsi = UnmodifiableListView(_skripsi);
  late final List<Magang> magang = UnmodifiableListView(_magang);
  late final List<Kkn> kkn = UnmodifiableListView(_kkn);
  late final List<Pertemuan> pertemuan = UnmodifiableListView(_pertemuan);
  late final List<Presensi> presensi = UnmodifiableListView(_presensi);

  MockService() {
    // Saat service dibuat, setiap kelas default langsung disiapkan
    // dengan 16 pertemuan agar dosen bisa mengelola presensi.
    for (final k in _kelas) {
      for (int i = 1; i <= 16; i++) {
        _pertemuan.add(
          Pertemuan(
            id: 'ptm-${k.id}-$i',
            kelasId: k.id,
            pertemuanKe: i,
            status: StatusPertemuan.belumDimulai,
          ),
        );
      }
    }
  }

  User? login(String username, String password) {
    final uname = username.trim();

    // Alur login dicek berurutan: admin, mahasiswa, lalu dosen.
    // Jika cocok, service mengembalikan User dengan role yang sesuai.
    for (final user in _users) {
      if (user.username == uname && user.password == password) {
        return user;
      }
    }

    // Mahasiswa login memakai NIM atau nama.
    for (final m in _mahasiswa) {
      if ((m.nim == uname || m.nama == uname) && m.password == password) {
        return User(
          id: 'u-m-${m.nim}',
          username: m.nim,
          password: m.password,
          role: Role.mahasiswa,
          name: m.nama,
          scopeId: m.nim,
        );
      }
    }

    // Dosen login memakai NIDN atau nama.
    for (final d in _dosen) {
      if ((d.nidn == uname || d.nama == uname) && d.password == password) {
        return User(
          id: 'u-d-${d.nidn}',
          username: d.nidn,
          password: d.password,
          role: Role.dosen,
          name: d.nama,
          scopeId: d.nidn,
        );
      }
    }

    return null;
  }

  String addFakultas(String nama, String adminUsername, String adminPassword) {
    // Admin universitas menambah fakultas sekaligus akun admin fakultasnya.
    _ensureNotBlank(nama, 'Nama fakultas');
    _ensureNotBlank(adminUsername, 'Username admin fakultas');
    _ensureNotBlank(adminPassword, 'Password admin fakultas');
    if (_fakultas.any(
      (item) => item.nama.toLowerCase() == nama.toLowerCase(),
    )) {
      throw StateError('Fakultas sudah ada');
    }
    if (_users.any(
      (item) => item.username.toLowerCase() == adminUsername.toLowerCase(),
    )) {
      throw StateError('Username admin sudah terdaftar');
    }
    final fakultasId = _nextId('f', _fakultas.length);
    _fakultas.add(Fakultas(id: fakultasId, nama: nama));

    _users.add(
      User(
        id: _nextId('u', _users.length),
        username: adminUsername,
        password: adminPassword,
        role: Role.adminFakultas,
        name: 'Admin $nama',
        scopeId: fakultasId,
      ),
    );
    return 'Fakultas dan Admin berhasil ditambahkan';
  }

  String addProdi(
    String nama,
    String fakultasId,
    String adminUsername,
    String adminPassword,
  ) {
    // Admin fakultas menambah prodi dan membuat akun operator prodi.
    _ensureNotBlank(nama, 'Nama prodi');
    _ensureNotBlank(adminUsername, 'Username admin prodi');
    _ensureNotBlank(adminPassword, 'Password admin prodi');
    _ensureExists(_fakultas.any((item) => item.id == fakultasId), 'Fakultas');
    if (_prodi.any(
      (item) =>
          item.fakultasId == fakultasId &&
          item.nama.toLowerCase() == nama.toLowerCase(),
    )) {
      throw StateError('Prodi sudah ada di fakultas ini');
    }
    if (_users.any(
      (item) => item.username.toLowerCase() == adminUsername.toLowerCase(),
    )) {
      throw StateError('Username admin sudah terdaftar');
    }
    final prodiId = _nextId('p', _prodi.length);
    _prodi.add(Prodi(id: prodiId, nama: nama, fakultasId: fakultasId));

    _users.add(
      User(
        id: _nextId('u', _users.length),
        username: adminUsername,
        password: adminPassword,
        role: Role.adminProdi,
        name: 'Admin $nama',
        scopeId: prodiId,
      ),
    );
    return 'Prodi dan Admin berhasil ditambahkan';
  }

  String updateProdi(String id, String nama, String fakultasId) {
    _ensureNotBlank(nama, 'Nama prodi');
    final index = _prodi.indexWhere((item) => item.id == id);
    if (index == -1) throw StateError('Prodi tidak ditemukan');
    _ensureExists(_fakultas.any((item) => item.id == fakultasId), 'Fakultas');
    _prodi[index] = Prodi(id: id, nama: nama, fakultasId: fakultasId);
    return 'Prodi berhasil diperbarui';
  }

  String deleteProdi(String id) {
    // Prodi tidak boleh dihapus jika masih dipakai oleh data akademik.
    if (_mahasiswa.any((item) => item.prodiId == id) ||
        _dosen.any((item) => item.prodiId == id) ||
        _mataKuliah.any((item) => item.prodiId == id)) {
      throw StateError('Prodi masih memiliki data akademik');
    }
    _prodi.removeWhere((item) => item.id == id);
    _users.removeWhere(
      (item) => item.role == Role.adminProdi && item.scopeId == id,
    );
    return 'Prodi berhasil dihapus';
  }

  String addMahasiswa(
    String nim,
    String nama,
    String jenisKelamin,
    String prodiId,
  ) {
    // Operator prodi menambahkan mahasiswa dengan password awal default.
    _ensureNotBlank(nim, 'NIM');
    _ensureNotBlank(nama, 'Nama mahasiswa');
    _ensureNotBlank(jenisKelamin, 'Jenis kelamin');
    _ensureExists(_prodi.any((item) => item.id == prodiId), 'Prodi');
    if (_mahasiswa.any((item) => item.nim == nim)) {
      throw StateError('NIM mahasiswa sudah terdaftar');
    }
    _mahasiswa.add(
      Mahasiswa(
        nim: nim,
        nama: nama,
        jenisKelamin: jenisKelamin,
        prodiId: prodiId,
        password: 'password',
        pembimbingAkademikId: _defaultPembimbingAkademikId(prodiId),
        semester: 1,
      ),
    );

    return 'Mahasiswa berhasil ditambahkan (Password default: password)';
  }

  String updateMahasiswa({
    required String nim,
    required String nama,
    required String jenisKelamin,
    required String prodiId,
  }) {
    _ensureNotBlank(nama, 'Nama mahasiswa');
    _ensureNotBlank(jenisKelamin, 'Jenis kelamin');
    final index = _mahasiswa.indexWhere((item) => item.nim == nim);
    if (index == -1) throw StateError('Mahasiswa tidak ditemukan');
    _mahasiswa[index] = Mahasiswa(
      nim: nim,
      nama: nama,
      jenisKelamin: jenisKelamin,
      prodiId: prodiId,
      password: _mahasiswa[index].password,
      pembimbingAkademikId: _mahasiswa[index].pembimbingAkademikId,
      semester: _mahasiswa[index].semester,
      email: _mahasiswa[index].email,
      noHp: _mahasiswa[index].noHp,
      alamat: _mahasiswa[index].alamat,
    );
    return 'Mahasiswa berhasil diperbarui';
  }

  String updateProfilMahasiswa({
    required String nim,
    required String jenisKelamin,
    required int semester,
    required String email,
    required String noHp,
    required String alamat,
  }) {
    _ensureNotBlank(jenisKelamin, 'Jenis kelamin');
    if (semester < 1 || semester > 14) {
      throw StateError('Semester harus berada di rentang 1-14');
    }
    final index = _mahasiswa.indexWhere((item) => item.nim == nim);
    if (index == -1) throw StateError('Mahasiswa tidak ditemukan');

    _mahasiswa[index] = _mahasiswa[index].copyWith(
      jenisKelamin: jenisKelamin,
      semester: semester,
      email: email.trim(),
      noHp: noHp.trim(),
      alamat: alamat.trim(),
    );
    return 'Profil berhasil diperbarui';
  }

  String deleteMahasiswa(String nim) {
    // Mahasiswa hanya bisa dihapus jika belum punya KRS aktif.
    _ensureExists(
      !_krs.any((item) => item.mahasiswaId == nim),
      'Mahasiswa tanpa KRS aktif',
    );
    _mahasiswa.removeWhere((item) => item.nim == nim);
    _nilai.removeWhere((item) => item.mahasiswaId == nim);
    _presensi.removeWhere((item) => item.mahasiswaId == nim);
    return 'Mahasiswa berhasil dihapus';
  }

  String addDosen(String nidn, String nama, String prodiId) {
    // Dosen baru didaftarkan ke prodi dan diberi password awal default.
    _ensureNotBlank(nidn, 'NIDN');
    _ensureNotBlank(nama, 'Nama dosen');
    _ensureExists(_prodi.any((item) => item.id == prodiId), 'Prodi');
    if (_dosen.any((item) => item.nidn == nidn)) {
      throw StateError('NIDN dosen sudah terdaftar');
    }
    _dosen.add(
      Dosen(nidn: nidn, nama: nama, prodiId: prodiId, password: 'password'),
    );

    return 'Dosen berhasil ditambahkan (Password default: password)';
  }

  String updateDosen({
    required String nidn,
    required String nama,
    required String prodiId,
  }) {
    _ensureNotBlank(nama, 'Nama dosen');
    final index = _dosen.indexWhere((item) => item.nidn == nidn);
    if (index == -1) throw StateError('Dosen tidak ditemukan');
    _dosen[index] = Dosen(
      nidn: nidn,
      nama: nama,
      prodiId: prodiId,
      password: _dosen[index].password,
      email: _dosen[index].email,
      noHp: _dosen[index].noHp,
      alamat: _dosen[index].alamat,
      keahlian: _dosen[index].keahlian,
    );
    return 'Dosen berhasil diperbarui';
  }

  String updateProfilDosen({
    required String nidn,
    required String email,
    required String noHp,
    required String alamat,
    required String keahlian,
  }) {
    final index = _dosen.indexWhere((item) => item.nidn == nidn);
    if (index == -1) throw StateError('Dosen tidak ditemukan');

    _dosen[index] = _dosen[index].copyWith(
      email: email.trim(),
      noHp: noHp.trim(),
      alamat: alamat.trim(),
      keahlian: keahlian.trim(),
    );
    return 'Profil dosen berhasil diperbarui';
  }

  String deleteDosen(String nidn) {
    // Dosen tidak boleh dihapus jika masih menjadi pengampu kelas.
    _ensureExists(
      !_kelas.any((item) => item.dosenId == nidn),
      'Dosen tanpa kelas aktif',
    );
    _dosen.removeWhere((item) => item.nidn == nidn);
    return 'Dosen berhasil dihapus';
  }

  String addAdmin(String username, String nama, Role role, String scopeId) {
    _ensureNotBlank(username, 'Username');
    _ensureNotBlank(nama, 'Nama admin');
    if (_users.any((item) => item.username == username)) {
      throw StateError('Username sudah terdaftar');
    }
    _users.add(
      User(
        id: _nextId('u', _users.length),
        username: username,
        password: 'password', // Default password
        role: role,
        name: nama,
        scopeId: scopeId,
      ),
    );
    return '${role.label} berhasil ditambahkan';
  }

  String addMataKuliah(String kode, String nama, int sks, String prodiId) {
    // Mata kuliah menjadi dasar pembukaan kelas kuliah.
    _ensureNotBlank(kode, 'Kode mata kuliah');
    _ensureNotBlank(nama, 'Nama mata kuliah');
    if (sks <= 0) throw StateError('SKS harus lebih dari 0');
    _ensureExists(_prodi.any((item) => item.id == prodiId), 'Prodi');
    if (_mataKuliah.any((item) => item.kode == kode)) {
      throw StateError('Kode mata kuliah sudah ada');
    }
    _mataKuliah.add(
      MataKuliah(kode: kode, nama: nama, sks: sks, prodiId: prodiId),
    );
    return 'Mata kuliah berhasil ditambahkan';
  }

  String updateMataKuliah({
    required String kode,
    required String nama,
    required int sks,
    required String prodiId,
  }) {
    _ensureNotBlank(nama, 'Nama mata kuliah');
    if (sks <= 0) throw StateError('SKS harus lebih dari 0');
    final index = _mataKuliah.indexWhere((item) => item.kode == kode);
    if (index == -1) throw StateError('Mata kuliah tidak ditemukan');
    _mataKuliah[index] = MataKuliah(
      kode: kode,
      nama: nama,
      sks: sks,
      prodiId: prodiId,
    );
    return 'Mata kuliah berhasil diperbarui';
  }

  String deleteMataKuliah(String kode) {
    // Mata kuliah yang sudah dipakai kelas tidak boleh dihapus.
    if (_kelas.any((item) => item.mataKuliahId == kode)) {
      throw StateError('Mata kuliah masih dipakai pada kelas kuliah');
    }
    _mataKuliah.removeWhere((item) => item.kode == kode);
    return 'Mata kuliah berhasil dihapus';
  }

  String openKelas({
    required String mataKuliahId,
    required String dosenId,
    required int kapasitas,
    required String hari,
    required String jam,
    required String ruangan,
  }) {
    // Membuka kelas berarti memilih mata kuliah, dosen, kapasitas, dan jadwal.
    _ensureExists(
      _mataKuliah.any((item) => item.kode == mataKuliahId),
      'Mata kuliah',
    );
    _ensureExists(_dosen.any((item) => item.nidn == dosenId), 'Dosen');
    if (kapasitas <= 0) throw StateError('Kapasitas harus lebih dari 0');
    _ensureNotBlank(hari, 'Hari');
    _ensureNotBlank(jam, 'Jam');
    _ensureNotBlank(ruangan, 'Ruangan');
    final newKelasId = _nextId('k', _kelas.length);
    _kelas.add(
      Kelas(
        id: newKelasId,
        mataKuliahId: mataKuliahId,
        dosenId: dosenId,
        kapasitas: kapasitas,
        hari: hari,
        jam: jam,
        ruangan: ruangan,
      ),
    );

    // Setelah kelas dibuat, 16 slot pertemuan ikut dibuat untuk presensi.
    for (int i = 1; i <= 16; i++) {
      _pertemuan.add(
        Pertemuan(
          id: 'ptm-$newKelasId-$i',
          kelasId: newKelasId,
          pertemuanKe: i,
          status: StatusPertemuan.belumDimulai,
        ),
      );
    }

    return 'Kelas berhasil dibuka';
  }

  String updateKelas({
    required String id,
    required String mataKuliahId,
    required String dosenId,
    required int kapasitas,
    required String hari,
    required String jam,
    required String ruangan,
  }) {
    final index = _kelas.indexWhere((item) => item.id == id);
    if (index == -1) throw StateError('Kelas tidak ditemukan');
    final jumlahPeserta = getJumlahPesertaKelas(id);
    if (kapasitas < jumlahPeserta) {
      throw StateError('Kapasitas tidak boleh kurang dari jumlah peserta');
    }
    _ensureExists(
      _mataKuliah.any((item) => item.kode == mataKuliahId),
      'Mata kuliah',
    );
    _ensureExists(_dosen.any((item) => item.nidn == dosenId), 'Dosen');
    _kelas[index] = Kelas(
      id: id,
      mataKuliahId: mataKuliahId,
      dosenId: dosenId,
      kapasitas: kapasitas,
      hari: hari,
      jam: jam,
      ruangan: ruangan,
    );
    return 'Kelas berhasil diperbarui';
  }

  String deleteKelas(String id) {
    if (_krs.any((item) => item.kelasId == id)) {
      throw StateError('Kelas masih memiliki peserta KRS');
    }
    _kelas.removeWhere((item) => item.id == id);
    _pertemuan.removeWhere((item) => item.kelasId == id);
    _tugas.removeWhere((item) => item.kelasId == id);
    return 'Kelas berhasil dihapus';
  }

  String takeKrs(String mahasiswaId, String kelasId) {
    // Alur KRS: pastikan mahasiswa dan kelas valid, prodinya sama,
    // kapasitas belum penuh, lalu simpan relasi mahasiswa-kelas.
    _ensureExists(
      _mahasiswa.any((item) => item.nim == mahasiswaId),
      'Mahasiswa',
    );
    _ensureExists(_kelas.any((item) => item.id == kelasId), 'Kelas');
    final mahasiswa = _mahasiswa.firstWhere((item) => item.nim == mahasiswaId);
    final kelas = _kelas.firstWhere((item) => item.id == kelasId);
    final mataKuliah = _mataKuliah.firstWhere(
      (item) => item.kode == kelas.mataKuliahId,
    );
    if (mahasiswa.prodiId != mataKuliah.prodiId) {
      throw StateError('Mahasiswa hanya bisa mengambil kelas dari prodinya');
    }
    if (isKelasPenuh(kelasId)) {
      throw StateError('Kapasitas kelas sudah penuh');
    }
    if (_krs.any(
      (item) => item.mahasiswaId == mahasiswaId && item.kelasId == kelasId,
    )) {
      throw StateError('Kelas sudah ada di KRS');
    }
    _krs.add(
      KRS(
        id: _nextId('krs', _krs.length),
        mahasiswaId: mahasiswaId,
        kelasId: kelasId,
        semester: mahasiswa.semester,
        isSubmitted: false,
        isValidated: false,
      ),
    );
    return 'KRS berhasil disimpan sebagai draft';
  }

  String submitKrs(String mahasiswaId, int semester) {
    final indexList = <int>[];
    for (int i = 0; i < _krs.length; i++) {
      final item = _krs[i];
      if (item.mahasiswaId == mahasiswaId && item.semester == semester) {
        indexList.add(i);
      }
    }
    if (indexList.isEmpty) {
      throw StateError('Isi KRS terlebih dahulu sebelum diajukan');
    }
    if (indexList.every((index) => _krs[index].isValidated)) {
      throw StateError('KRS semester ini sudah disetujui');
    }
    for (final index in indexList) {
      _krs[index] = _krs[index].copyWith(isSubmitted: true);
    }
    return 'KRS berhasil diajukan ke dosen pembimbing akademik';
  }

  String validateKrs(String krsId, String dosenId) {
    final index = _krs.indexWhere((item) => item.id == krsId);
    if (index == -1) throw StateError('KRS tidak ditemukan');
    final mahasiswa = _mahasiswa.firstWhere(
      (item) => item.nim == _krs[index].mahasiswaId,
    );
    if (mahasiswa.pembimbingAkademikId != dosenId) {
      throw StateError('KRS hanya dapat disetujui dosen pembimbing akademik');
    }
    if (!_krs[index].isSubmitted) {
      throw StateError('KRS belum diajukan mahasiswa');
    }
    _krs[index] = _krs[index].copyWith(isValidated: true);
    return 'KRS berhasil disetujui';
  }

  String inputNilai({
    required String dosenId,
    required String mahasiswaId,
    required String kelasId,
    required double angka,
    double? tugas,
    double? uts,
    double? uas,
    double? softskill,
  }) {
    // Nilai hanya bisa diinput oleh dosen pengampu dan untuk mahasiswa
    // yang benar-benar mengambil kelas tersebut di KRS.
    final kelas = _kelas.firstWhere((item) => item.id == kelasId);
    if (kelas.dosenId != dosenId) {
      throw StateError('Dosen hanya bisa input nilai kelas yang diajar');
    }
    _ensureExists(
      _krs.any(
        (item) => item.mahasiswaId == mahasiswaId && item.kelasId == kelasId,
      ),
      'KRS mahasiswa untuk kelas ini',
    );
    _nilai.removeWhere(
      (item) => item.mahasiswaId == mahasiswaId && item.kelasId == kelasId,
    );
    _nilai.add(
      Nilai(
        id: _nextId('n', _nilai.length),
        mahasiswaId: mahasiswaId,
        kelasId: kelasId,
        nilaiAngka: angka,
        nilaiHuruf: _huruf(angka),
        semester: _mahasiswa
            .firstWhere((item) => item.nim == mahasiswaId)
            .semester,
        nilaiTugas: tugas ?? angka,
        nilaiUts: uts ?? angka,
        nilaiUas: uas ?? angka,
        nilaiSoftskill: softskill ?? angka,
      ),
    );
    return 'Nilai berhasil disimpan';
  }

  String getMataKuliahName(String kode) {
    return _mataKuliah.firstWhere((item) => item.kode == kode).nama;
  }

  String getDosenName(String nidn) {
    return _dosen.firstWhere((item) => item.nidn == nidn).nama;
  }

  String getMahasiswaName(String nim) {
    return _mahasiswa.firstWhere((item) => item.nim == nim).nama;
  }

  int getJumlahPesertaKelas(String kelasId) {
    return _krs.where((item) => item.kelasId == kelasId).length;
  }

  bool isKelasPenuh(String kelasId) {
    final kelas = _kelas.firstWhere((item) => item.id == kelasId);
    return getJumlahPesertaKelas(kelasId) >= kelas.kapasitas;
  }

  int getTotalSksDosen(String nidn) {
    final kelasDosen = _kelas.where((k) => k.dosenId == nidn);
    int total = 0;
    for (final k in kelasDosen) {
      final mk = _mataKuliah.firstWhere((mk) => mk.kode == k.mataKuliahId);
      total += mk.sks;
    }
    return total;
  }

  String getDosenFullInfo(String nidn) {
    try {
      final d = _dosen.firstWhere((item) => item.nidn == nidn);
      final p = _prodi.firstWhere((item) => item.id == d.prodiId);
      final f = _fakultas.firstWhere((item) => item.id == p.fakultasId);
      return '${p.nama}, ${f.nama}';
    } catch (_) {
      return '-';
    }
  }

  String _defaultPembimbingAkademikId(String prodiId) {
    final matches = _dosen.where((item) => item.prodiId == prodiId);
    if (matches.isEmpty) {
      throw StateError('Belum ada dosen pembimbing akademik untuk prodi ini');
    }
    return matches.first.nidn;
  }

  String addTugas({
    required String dosenId,
    required String kelasId,
    required String judul,
    required String deskripsi,
    required DateTime deadline,
  }) {
    // Tugas hanya dapat dibuat oleh dosen untuk kelas yang dia ampu.
    final kelas = _kelas.firstWhere((item) => item.id == kelasId);
    if (kelas.dosenId != dosenId) {
      throw StateError('Dosen hanya bisa memberi tugas pada kelas yang diajar');
    }
    _ensureNotBlank(judul, 'Judul tugas');
    _ensureNotBlank(deskripsi, 'Deskripsi tugas');

    _tugas.add(
      Tugas(
        id: _nextId('t', _tugas.length),
        kelasId: kelasId,
        judul: judul,
        deskripsi: deskripsi,
        deadline: deadline,
      ),
    );
    return 'Tugas berhasil ditambahkan';
  }

  String mulaiSkripsi({
    required String mahasiswaId,
    required String judul,
    required String topik,
  }) {
    _ensureNotBlank(judul, 'Judul skripsi');
    _ensureNotBlank(topik, 'Topik skripsi');
    final mahasiswa = _mahasiswa.firstWhere((item) => item.nim == mahasiswaId);
    if (_skripsi.any(
      (item) =>
          item.mahasiswaId == mahasiswaId &&
          item.status != StatusPengajuan.selesai,
    )) {
      throw StateError('Skripsi aktif sudah pernah diajukan');
    }
    _skripsi.add(
      Skripsi(
        id: _nextId('skr', _skripsi.length),
        mahasiswaId: mahasiswaId,
        judul: judul,
        topik: topik,
        pembimbingId: mahasiswa.pembimbingAkademikId,
        dibuatPada: DateTime.now(),
      ),
    );
    return 'Skripsi berhasil diajukan ke dosen pembimbing';
  }

  String setujuiSkripsi(String skripsiId, String dosenId) {
    final index = _skripsi.indexWhere((item) => item.id == skripsiId);
    if (index == -1) throw StateError('Pengajuan skripsi tidak ditemukan');
    if (_skripsi[index].pembimbingId != dosenId) {
      throw StateError('Hanya dosen pembimbing yang bisa menyetujui skripsi');
    }
    _skripsi[index] = _skripsi[index].copyWith(
      status: StatusPengajuan.disetujui,
    );
    return 'Skripsi berhasil disetujui';
  }

  String tambahCatatanBimbingan({
    required String skripsiId,
    required String dosenId,
    required String catatan,
  }) {
    _ensureNotBlank(catatan, 'Catatan bimbingan');
    final index = _skripsi.indexWhere((item) => item.id == skripsiId);
    if (index == -1) throw StateError('Data skripsi tidak ditemukan');
    if (_skripsi[index].pembimbingId != dosenId) {
      throw StateError('Hanya dosen pembimbing yang bisa memberi catatan');
    }
    _skripsi[index] = _skripsi[index].copyWith(
      catatan: [
        ..._skripsi[index].catatan,
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}: $catatan',
      ],
    );
    return 'Catatan bimbingan berhasil disimpan';
  }

  String ajukanMagang({
    required String mahasiswaId,
    required String instansi,
    required String posisi,
  }) {
    _ensureNotBlank(instansi, 'Instansi magang');
    _ensureNotBlank(posisi, 'Posisi magang');
    if (_magang.any(
      (item) =>
          item.mahasiswaId == mahasiswaId &&
          item.status != StatusPengajuan.selesai,
    )) {
      throw StateError('Pengajuan magang aktif sudah ada');
    }
    _magang.add(
      Magang(
        id: _nextId('mag', _magang.length),
        mahasiswaId: mahasiswaId,
        instansi: instansi,
        posisi: posisi,
        dibuatPada: DateTime.now(),
      ),
    );
    return 'Pengajuan magang berhasil disimpan';
  }

  String ajukanKkn({
    required String mahasiswaId,
    required String lokasi,
    required String tema,
  }) {
    _ensureNotBlank(lokasi, 'Lokasi KKN');
    _ensureNotBlank(tema, 'Tema KKN');
    if (_kkn.any(
      (item) =>
          item.mahasiswaId == mahasiswaId &&
          item.status != StatusPengajuan.selesai,
    )) {
      throw StateError('Pengajuan KKN aktif sudah ada');
    }
    _kkn.add(
      Kkn(
        id: _nextId('kkn', _kkn.length),
        mahasiswaId: mahasiswaId,
        lokasi: lokasi,
        tema: tema,
        dibuatPada: DateTime.now(),
      ),
    );
    return 'Pengajuan KKN berhasil disimpan';
  }

  void mulaiPertemuan(String pertemuanId, String materi) {
    // Pertemuan dimulai oleh dosen sebelum presensi bisa disimpan.
    final index = _pertemuan.indexWhere((p) => p.id == pertemuanId);
    if (index == -1) throw StateError('Pertemuan tidak ditemukan');

    final current = _pertemuan[index];
    if (current.status != StatusPertemuan.belumDimulai) {
      throw StateError('Pertemuan sudah dimulai sebelumnya');
    }

    _pertemuan[index] = current.copyWith(
      status: StatusPertemuan.berlangsung,
      materi: materi,
      waktuMulai: DateTime.now(),
    );
  }

  void selesaikanPertemuan(String pertemuanId) {
    final index = _pertemuan.indexWhere((p) => p.id == pertemuanId);
    if (index == -1) throw StateError('Pertemuan tidak ditemukan');

    final current = _pertemuan[index];
    if (current.status == StatusPertemuan.belumDimulai) {
      throw StateError('Pertemuan belum dimulai');
    }
    if (current.status == StatusPertemuan.selesai) {
      throw StateError('Pertemuan sudah selesai');
    }

    _pertemuan[index] = current.copyWith(status: StatusPertemuan.selesai);
  }

  void simpanPresensi(String pertemuanId, Map<String, String> statusMap) {
    // Presensi disimpan per pertemuan. Data lama untuk pertemuan yang sama
    // diganti supaya edit presensi tidak menghasilkan duplikasi.
    final index = _pertemuan.indexWhere((p) => p.id == pertemuanId);
    if (index == -1) throw StateError('Pertemuan tidak ditemukan');

    final current = _pertemuan[index];
    if (current.status == StatusPertemuan.belumDimulai) {
      throw StateError('Pertemuan belum dimulai');
    }

    _presensi.removeWhere((p) => p.pertemuanId == pertemuanId);

    statusMap.forEach((mahasiswaId, status) {
      _presensi.add(
        Presensi(
          id: _nextId('prs', _presensi.length),
          pertemuanId: pertemuanId,
          mahasiswaId: mahasiswaId,
          statusKehadiran: status,
        ),
      );
    });
  }

  void _ensureNotBlank(String value, String label) {
    // Helper validasi sederhana agar pesan error konsisten.
    if (value.trim().isEmpty) throw StateError('$label wajib diisi');
  }

  void _ensureExists(bool exists, String label) {
    // Dipakai untuk memastikan relasi data yang dipilih benar-benar ada.
    if (!exists) throw StateError('$label tidak ditemukan');
  }

  String _nextId(String prefix, int length) {
    return '$prefix-${(length + 1).toString().padLeft(2, '0')}';
  }

  String _huruf(double angka) {
    if (angka >= 85) return 'A';
    if (angka >= 75) return 'B+';
    if (angka >= 65) return 'B';
    if (angka >= 55) return 'C';
    return 'D';
  }
}
