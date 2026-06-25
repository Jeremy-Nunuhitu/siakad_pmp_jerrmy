import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "tmp"
STATE_PATH = OUT_DIR / "siakad_bulk_state.json"
SQL_PATH = OUT_DIR / "siakad_bulk_seed.sql"


def iso(day: int, hour: int = 8) -> str:
    return f"2026-03-{day:02d}T{hour:02d}:00:00.000"


def grade(score: float) -> str:
    if score >= 85:
        return "A"
    if score >= 78:
        return "B+"
    if score >= 70:
        return "B"
    if score >= 62:
        return "C+"
    if score >= 55:
        return "C"
    return "D"


faculty_names = [
    ("f-01", "Fakultas Teknik dan Informatika"),
    ("f-02", "Fakultas Ekonomi dan Bisnis"),
    ("f-03", "Fakultas Ilmu Sosial dan Politik"),
    ("f-04", "Fakultas Keguruan dan Ilmu Pendidikan"),
    ("f-05", "Fakultas Kesehatan"),
]

program_names = [
    ["Informatika", "Sistem Informasi", "Teknik Elektro", "Teknik Sipil", "Arsitektur"],
    ["Manajemen", "Akuntansi", "Ekonomi Pembangunan", "Bisnis Digital", "Kewirausahaan"],
    ["Ilmu Administrasi Publik", "Ilmu Komunikasi", "Hubungan Internasional", "Sosiologi", "Ilmu Pemerintahan"],
    ["Pendidikan Matematika", "Pendidikan Bahasa Indonesia", "Pendidikan Bahasa Inggris", "Pendidikan Biologi", "PGSD"],
    ["Keperawatan", "Kesehatan Masyarakat", "Farmasi", "Gizi", "Kebidanan"],
]

course_names = [
    "Pengantar Keilmuan",
    "Metodologi Riset",
    "Sistem Informasi Akademik",
    "Analisis Data",
    "Etika Profesi",
]

first_names = [
    "Alya", "Bagas", "Citra", "Dimas", "Elisa", "Farhan", "Gita", "Hafiz",
    "Intan", "Joko", "Kartika", "Lukman", "Maya", "Naufal", "Olivia", "Prasetyo",
    "Qori", "Rania", "Satria", "Tiara", "Umar", "Vina", "Wahyu", "Yasmin", "Zaki",
]
last_names = [
    "Pratama", "Lestari", "Saputra", "Wijaya", "Putri", "Santoso", "Hidayat",
    "Ramadhan", "Permata", "Nugroho", "Mahendra", "Salsabila", "Firmansyah",
    "Anggraini", "Kusuma", "Utami", "Setiawan", "Maulana", "Azzahra", "Pangestu",
]
lecturer_titles = ["Dr.", "Prof.", "Ir.", "Dra.", "Drs.", "Ns."]
lecturer_suffixes = ["M.Kom", "M.Si", "M.M", "M.Pd", "M.T", "M.Kes"]

state = {
    "users": [
        {
            "id": "u-admin-univ",
            "username": "univ",
            "password": "password",
            "role": "adminUniversitas",
            "name": "Admin Universitas",
            "scopeId": "global",
            "tingkatPimpinan": None,
        },
        {
            "id": "u-rektor",
            "username": "rektor@siakad.com",
            "password": "123456",
            "role": "pimpinan",
            "name": "Rektor Universitas",
            "scopeId": "global",
            "tingkatPimpinan": "rektor",
        },
    ],
    "fakultas": [],
    "prodi": [],
    "tahunAjaran": [
        {
            "id": "ta-2025-ganjil",
            "nama": "2025/2026",
            "semester": "ganjil",
            "tanggalMulai": "2025-08-01T00:00:00.000",
            "tanggalSelesai": "2026-01-31T00:00:00.000",
            "aktif": False,
        },
        {
            "id": "ta-2025-genap",
            "nama": "2025/2026",
            "semester": "genap",
            "tanggalMulai": "2026-02-01T00:00:00.000",
            "tanggalSelesai": "2026-07-31T00:00:00.000",
            "aktif": True,
        },
    ],
    "faseKrs": [
        {
            "tahunAjaranId": "ta-2025-genap",
            "mulai": "2026-02-01T00:00:00.000",
            "berakhir": "2026-07-31T23:59:59.999",
            "aktif": True,
        }
    ],
    "mahasiswa": [],
    "riwayatStatusMahasiswa": [],
    "dosen": [],
    "mataKuliah": [],
    "ruangan": [],
    "kelas": [],
    "dosenPengajar": [],
    "krs": [],
    "nilai": [],
    "tugas": [],
    "skripsi": [],
    "magang": [],
    "kkn": [],
    "pertemuan": [],
    "presensi": [],
    "presensiDosen": [],
}

for i in range(1, 101):
    state["ruangan"].append(
        {
            "kodeRuangan": f"R-{i:03d}",
            "namaRuangan": f"Ruang Kuliah {i:03d}",
            "kapasitasRuangan": 45 + (i % 6) * 5,
            "lokasi": f"Gedung {chr(65 + (i % 5))} Lantai {(i % 4) + 1}",
        }
    )

all_students_by_prodi = {}
all_lecturers_by_prodi = {}
kelas_by_prodi = {}

for f_idx, (f_id, f_name) in enumerate(faculty_names, start=1):
    state["fakultas"].append({"id": f_id, "nama": f_name})
    state["users"].append(
        {
            "id": f"u-admin-{f_id}",
            "username": f"admin-{f_id}",
            "password": "password",
            "role": "adminFakultas",
            "name": f"Admin {f_name}",
            "scopeId": f_id,
            "tingkatPimpinan": None,
        }
    )
    state["users"].append(
        {
            "id": f"u-dekan-{f_id}",
            "username": f"dekan-{f_id}",
            "password": "password",
            "role": "pimpinan",
            "name": f"Dekan {f_name}",
            "scopeId": f_id,
            "tingkatPimpinan": "dekan",
        }
    )

    for p_idx, prodi_name in enumerate(program_names[f_idx - 1], start=1):
        prodi_id = f"p-{f_idx:02d}{p_idx:02d}"
        state["prodi"].append({"id": prodi_id, "nama": prodi_name, "fakultasId": f_id})
        state["users"].append(
            {
                "id": f"u-op-{prodi_id}",
                "username": f"operator-{prodi_id}",
                "password": "password",
                "role": "adminProdi",
                "name": f"Operator {prodi_name}",
                "scopeId": prodi_id,
                "tingkatPimpinan": None,
            }
        )
        state["users"].append(
            {
                "id": f"u-korpro-{prodi_id}",
                "username": f"korpro-{prodi_id}",
                "password": "password",
                "role": "pimpinan",
                "name": f"Korpro {prodi_name}",
                "scopeId": prodi_id,
                "tingkatPimpinan": "korpro",
            }
        )

        lecturers = []
        for d_idx in range(1, 16):
            nidn = f"D{f_idx:02d}{p_idx:02d}{d_idx:03d}"
            name = (
                f"{lecturer_titles[(d_idx + p_idx) % len(lecturer_titles)]} "
                f"{first_names[(d_idx * 2 + f_idx) % len(first_names)]} "
                f"{last_names[(d_idx * 3 + p_idx) % len(last_names)]}, "
                f"{lecturer_suffixes[(d_idx + f_idx) % len(lecturer_suffixes)]}"
            )
            lecturers.append(nidn)
            state["dosen"].append(
                {
                    "nidn": nidn,
                    "nama": name,
                    "prodiId": prodi_id,
                    "password": "password",
                    "email": f"{nidn.lower()}@kampus.ac.id",
                    "noHp": f"0812{f_idx:02d}{p_idx:02d}{d_idx:04d}",
                    "alamat": f"Kompleks Dosen {prodi_name} No. {d_idx}",
                    "keahlian": course_names[(d_idx - 1) % len(course_names)],
                }
            )
            state["users"].append(
                {
                    "id": f"u-{nidn.lower()}",
                    "username": nidn.lower(),
                    "password": "password",
                    "role": "dosen",
                    "name": name,
                    "scopeId": nidn,
                    "tingkatPimpinan": None,
                }
            )
        all_lecturers_by_prodi[prodi_id] = lecturers

        students = []
        for m_idx in range(1, 201):
            nim = f"25{f_idx:02d}{p_idx:02d}{m_idx:04d}"
            full_name = (
                f"{first_names[(m_idx + p_idx) % len(first_names)]} "
                f"{last_names[(m_idx + f_idx) % len(last_names)]}"
            )
            pa = lecturers[(m_idx - 1) % len(lecturers)]
            status = "cuti" if m_idx % 97 == 0 else "aktif"
            students.append(nim)
            state["mahasiswa"].append(
                {
                    "nim": nim,
                    "nama": full_name,
                    "jenisKelamin": "Perempuan" if m_idx % 2 == 0 else "Laki-laki",
                    "prodiId": prodi_id,
                    "password": "password",
                    "pembimbingAkademikId": pa,
                    "semester": (m_idx % 8) + 1,
                    "email": f"{nim}@student.ac.id",
                    "noHp": f"0821{f_idx:02d}{p_idx:02d}{m_idx:04d}",
                    "alamat": f"Jl. Mahasiswa {prodi_name} No. {m_idx}",
                    "status": status,
                }
            )
            state["users"].append(
                {
                    "id": f"u-{nim}",
                    "username": nim,
                    "password": "password",
                    "role": "mahasiswa",
                    "name": full_name,
                    "scopeId": nim,
                    "tingkatPimpinan": None,
                }
            )
            if status != "aktif":
                state["riwayatStatusMahasiswa"].append(
                    {
                        "id": f"rsm-{nim}",
                        "mahasiswaId": nim,
                        "statusSebelumnya": "aktif",
                        "statusBaru": status,
                        "namaBukti": "surat-cuti.pdf",
                        "tipeBukti": "application/pdf",
                        "ukuranBukti": 128000,
                        "buktiBase64": "",
                        "diubahPada": "2026-03-01T09:00:00.000",
                    }
                )
        all_students_by_prodi[prodi_id] = students

        kelas_ids = []
        for c_idx, course_name in enumerate(course_names, start=1):
            kode = f"MK{f_idx:02d}{p_idx:02d}{c_idx:02d}"
            state["mataKuliah"].append(
                {
                    "kode": kode,
                    "nama": f"{course_name} {prodi_name}",
                    "sks": 2 + (c_idx % 3),
                    "prodiId": prodi_id,
                }
            )
            for section in range(1, 3):
                kelas_id = f"K{f_idx:02d}{p_idx:02d}{c_idx:02d}{section}"
                dosen_id = lecturers[(c_idx + section - 2) % len(lecturers)]
                room = state["ruangan"][(f_idx * 19 + p_idx * 7 + c_idx * 2 + section) % len(state["ruangan"])]
                kelas_ids.append(kelas_id)
                state["kelas"].append(
                    {
                        "id": kelas_id,
                        "mataKuliahId": kode,
                        "dosenId": dosen_id,
                        "kapasitas": 45,
                        "hari": ["Senin", "Selasa", "Rabu", "Kamis", "Jumat"][(c_idx + section) % 5],
                        "jam": f"{7 + ((c_idx + section) % 6):02d}:00-{9 + ((c_idx + section) % 6):02d}:00",
                        "ruangan": room["kodeRuangan"],
                        "tahunAjaranId": "ta-2025-genap",
                    }
                )
                state["dosenPengajar"].append(
                    {
                        "id": f"dp-{kelas_id}-1",
                        "idKelas": kelas_id,
                        "nidnDosen": dosen_id,
                        "peranMengajar": "Dosen Utama",
                    }
                )
                state["dosenPengajar"].append(
                    {
                        "id": f"dp-{kelas_id}-2",
                        "idKelas": kelas_id,
                        "nidnDosen": lecturers[(c_idx + section + 3) % len(lecturers)],
                        "peranMengajar": "Asisten Dosen",
                    }
                )
                for meeting in range(1, 17):
                    pertemuan_id = f"PTM-{kelas_id}-{meeting:02d}"
                    status = "selesai" if meeting <= 8 else "belumDimulai"
                    state["pertemuan"].append(
                        {
                            "id": pertemuan_id,
                            "kelasId": kelas_id,
                            "pertemuanKe": meeting,
                            "status": status,
                            "materi": f"Materi pertemuan {meeting}" if meeting <= 8 else None,
                            "waktuMulai": iso(min(meeting + 1, 28), 8 + (meeting % 6)) if meeting <= 8 else None,
                        }
                    )
                    if meeting <= 8:
                        state["presensiDosen"].append(
                            {
                                "id": f"PD-{pertemuan_id}",
                                "pertemuanId": pertemuan_id,
                                "dosenId": dosen_id,
                                "statusKehadiran": "Hadir",
                                "waktuPresensi": iso(min(meeting + 1, 28), 8 + (meeting % 6)),
                                "catatan": "",
                            }
                        )
        kelas_by_prodi[prodi_id] = kelas_ids

for prodi_id, students in all_students_by_prodi.items():
    kelas_ids = kelas_by_prodi[prodi_id]
    for index, nim in enumerate(students, start=1):
        selected = [kelas_ids[(index + offset * 3) % len(kelas_ids)] for offset in range(3)]
        for offset, kelas_id in enumerate(selected, start=1):
            krs_id = f"KRS-{nim}-{offset}"
            state["krs"].append(
                {
                    "id": krs_id,
                    "mahasiswaId": nim,
                    "kelasId": kelas_id,
                    "semester": ((index - 1) % 8) + 1,
                    "isSubmitted": True,
                    "isValidated": index % 11 != 0,
                    "isRejected": index % 11 == 0,
                    "catatanDosenPa": "Perbaiki pilihan kelas" if index % 11 == 0 else "",
                    "tahunAjaranId": "ta-2025-genap",
                }
            )
            tugas = 65 + ((index + offset) % 31)
            uts = 60 + ((index * 2 + offset) % 36)
            uas = 62 + ((index * 3 + offset) % 35)
            soft = 70 + ((index + offset * 5) % 26)
            total = round(tugas * 0.25 + uts * 0.25 + uas * 0.35 + soft * 0.15, 2)
            state["nilai"].append(
                {
                    "id": f"N-{krs_id}",
                    "mahasiswaId": nim,
                    "kelasId": kelas_id,
                    "nilaiAngka": total,
                    "nilaiHuruf": grade(total),
                    "semester": ((index - 1) % 8) + 1,
                    "nilaiTugas": tugas,
                    "nilaiUts": uts,
                    "nilaiUas": uas,
                    "nilaiSoftskill": soft,
                    "bobotTugas": 25,
                    "bobotUts": 25,
                    "bobotUas": 35,
                    "bobotSoftskill": 15,
                    "tahunAjaranId": "ta-2025-genap",
                }
            )
            for meeting in range(1, 5):
                state["presensi"].append(
                    {
                        "id": f"PR-{nim}-{kelas_id}-{meeting:02d}",
                        "pertemuanId": f"PTM-{kelas_id}-{meeting:02d}",
                        "mahasiswaId": nim,
                        "statusKehadiran": ["Hadir", "Hadir", "Hadir", "Ijin", "Sakit", "Alpa"][(index + meeting + offset) % 6],
                        "waktuPresensi": iso(min(meeting + 1, 28), 9 + (meeting % 5)),
                        "catatan": "",
                    }
                )

for kelas in state["kelas"]:
    for no in range(1, 3):
        state["tugas"].append(
            {
                "id": f"T-{kelas['id']}-{no}",
                "kelasId": kelas["id"],
                "judul": f"Tugas {no} - {kelas['mataKuliahId']}",
                "deskripsi": "Kerjakan studi kasus dan unggah laporan.",
                "deadline": f"2026-04-{10 + no:02d}T23:59:00.000",
            }
        )

for idx, mahasiswa in enumerate(state["mahasiswa"][:300], start=1):
    state["skripsi"].append(
        {
            "id": f"SKR-{idx:04d}",
            "mahasiswaId": mahasiswa["nim"],
            "judul": f"Analisis Sistem Akademik Berbasis Data {idx}",
            "topik": "Sistem Informasi Akademik",
            "pembimbingId": mahasiswa["pembimbingAkademikId"],
            "dibuatPada": "2026-03-15T10:00:00.000",
            "status": "diajukan" if idx % 3 else "disetujui",
            "catatan": ["Proposal diterima untuk ditinjau."] if idx % 3 == 0 else [],
        }
    )

for idx, mahasiswa in enumerate(state["mahasiswa"][300:600], start=1):
    state["magang"].append(
        {
            "id": f"MG-{idx:04d}",
            "mahasiswaId": mahasiswa["nim"],
            "instansi": f"PT Mitra Kampus {idx:03d}",
            "posisi": ["Data Analyst", "Web Developer", "Administrasi", "Asisten Riset"][idx % 4],
            "dibuatPada": "2026-03-20T10:00:00.000",
            "status": "diajukan" if idx % 4 else "disetujui",
        }
    )

for idx, mahasiswa in enumerate(state["mahasiswa"][600:900], start=1):
    state["kkn"].append(
        {
            "id": f"KKN-{idx:04d}",
            "mahasiswaId": mahasiswa["nim"],
            "lokasi": f"Desa Binaan {idx:03d}",
            "tema": "Pemberdayaan Masyarakat Digital",
            "dibuatPada": "2026-03-25T10:00:00.000",
            "status": "diajukan" if idx % 5 else "disetujui",
        }
    )

OUT_DIR.mkdir(exist_ok=True)
STATE_PATH.write_text(json.dumps(state, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")

table_map = {
    "siakad_users": ("users", ["id", "username", "password", "role", "name", "scopeId", "tingkatPimpinan"]),
    "fakultas": ("fakultas", ["id", "nama"]),
    "prodi": ("prodi", ["id", "nama", "fakultasId"]),
    "tahun_ajaran": ("tahunAjaran", ["id", "nama", "semester", "tanggalMulai", "tanggalSelesai", "aktif"]),
    "fase_krs": ("faseKrs", ["tahunAjaranId", "mulai", "berakhir", "aktif"]),
    "mahasiswa": ("mahasiswa", ["nim", "nama", "jenisKelamin", "prodiId", "password", "pembimbingAkademikId", "semester", "email", "noHp", "alamat", "status"]),
    "riwayat_status_mahasiswa": ("riwayatStatusMahasiswa", ["id", "mahasiswaId", "statusSebelumnya", "statusBaru", "namaBukti", "tipeBukti", "ukuranBukti", "buktiBase64", "diubahPada"]),
    "dosen": ("dosen", ["nidn", "nama", "prodiId", "password", "email", "noHp", "alamat", "keahlian"]),
    "mata_kuliah": ("mataKuliah", ["kode", "nama", "sks", "prodiId"]),
    "ruangan": ("ruangan", ["kodeRuangan", "namaRuangan", "kapasitasRuangan", "lokasi"]),
    "kelas": ("kelas", ["id", "mataKuliahId", "dosenId", "kapasitas", "hari", "jam", "ruangan", "tahunAjaranId"]),
    "dosen_pengajar": ("dosenPengajar", ["id", "idKelas", "nidnDosen", "peranMengajar"]),
    "krs": ("krs", ["id", "mahasiswaId", "kelasId", "semester", "isSubmitted", "isValidated", "isRejected", "catatanDosenPa", "tahunAjaranId"]),
    "nilai": ("nilai", ["id", "mahasiswaId", "kelasId", "nilaiAngka", "nilaiHuruf", "semester", "nilaiTugas", "nilaiUts", "nilaiUas", "nilaiSoftskill", "bobotTugas", "bobotUts", "bobotUas", "bobotSoftskill", "tahunAjaranId"]),
    "tugas": ("tugas", ["id", "kelasId", "judul", "deskripsi", "deadline"]),
    "skripsi": ("skripsi", ["id", "mahasiswaId", "judul", "topik", "pembimbingId", "dibuatPada", "status"]),
    "magang": ("magang", ["id", "mahasiswaId", "instansi", "posisi", "dibuatPada", "status"]),
    "kkn": ("kkn", ["id", "mahasiswaId", "lokasi", "tema", "dibuatPada", "status"]),
    "pertemuan": ("pertemuan", ["id", "kelasId", "pertemuanKe", "status", "materi", "waktuMulai"]),
    "presensi": ("presensi", ["id", "pertemuanId", "mahasiswaId", "statusKehadiran", "waktuPresensi", "catatan"]),
    "presensi_dosen": ("presensiDosen", ["id", "pertemuanId", "dosenId", "statusKehadiran", "waktuPresensi", "catatan"]),
}

column_name = {
    "scopeId": "scope_id", "tingkatPimpinan": "tingkat_pimpinan", "fakultasId": "fakultas_id",
    "tahunAjaranId": "tahun_ajaran_id", "tanggalMulai": "tanggal_mulai", "tanggalSelesai": "tanggal_selesai",
    "jenisKelamin": "jenis_kelamin", "prodiId": "prodi_id", "pembimbingAkademikId": "pembimbing_akademik_id",
    "mahasiswaId": "mahasiswa_id", "statusSebelumnya": "status_sebelumnya", "statusBaru": "status_baru",
    "namaBukti": "nama_bukti", "tipeBukti": "tipe_bukti", "ukuranBukti": "ukuran_bukti", "buktiBase64": "bukti_base64",
    "diubahPada": "diubah_pada", "noHp": "no_hp", "mataKuliahId": "mata_kuliah_id",
    "kodeRuangan": "kode_ruangan", "namaRuangan": "nama_ruangan", "kapasitasRuangan": "kapasitas_ruangan",
    "idKelas": "id_kelas", "nidnDosen": "nidn_dosen", "peranMengajar": "peran_mengajar", "kelasId": "kelas_id",
    "isSubmitted": "is_submitted", "isValidated": "is_validated", "isRejected": "is_rejected",
    "catatanDosenPa": "catatan_dosen_pa", "nilaiAngka": "nilai_angka", "nilaiHuruf": "nilai_huruf",
    "nilaiTugas": "nilai_tugas", "nilaiUts": "nilai_uts", "nilaiUas": "nilai_uas", "nilaiSoftskill": "nilai_softskill",
    "bobotTugas": "bobot_tugas", "bobotUts": "bobot_uts", "bobotUas": "bobot_uas", "bobotSoftskill": "bobot_softskill",
    "pembimbingId": "pembimbing_id", "dibuatPada": "dibuat_pada", "pertemuanKe": "pertemuan_ke",
    "waktuMulai": "waktu_mulai", "pertemuanId": "pertemuan_id", "statusKehadiran": "status_kehadiran",
    "waktuPresensi": "waktu_presensi", "dosenId": "dosen_id",
}


def sql_value(value):
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"


lines = [
    "BEGIN;",
    "TRUNCATE TABLE " + ", ".join(table_map.keys()) + ";",
    "DELETE FROM siakad_state WHERE key = 'app_state';",
    "INSERT INTO siakad_state (key, value) VALUES ('app_state', $state$" + STATE_PATH.read_text(encoding="utf-8") + "$state$);",
]

for table, (json_key, keys) in table_map.items():
    columns = [column_name.get(key, key) for key in keys] + ["data"]
    rows = []
    for row in state[json_key]:
        values = [sql_value(row.get(key)) for key in keys]
        values.append("$json$" + json.dumps(row, ensure_ascii=False, separators=(",", ":")) + "$json$::jsonb")
        rows.append("(" + ",".join(values) + ")")
    if rows:
        chunk_size = 500
        for start in range(0, len(rows), chunk_size):
            lines.append(f"INSERT INTO {table} ({', '.join(columns)}) VALUES")
            lines.append(",\n".join(rows[start:start + chunk_size]) + ";")

lines.append("COMMIT;")
SQL_PATH.write_text("\n".join(lines), encoding="utf-8")

print(json.dumps({key: len(value) for key, value in state.items() if isinstance(value, list)}, indent=2))
print(f"Wrote {STATE_PATH}")
print(f"Wrote {SQL_PATH}")
