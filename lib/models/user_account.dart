enum UserRole { mahasiswa, dosen, adminProdi, adminFakultas, adminUniversitas }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.mahasiswa:
        return 'Mahasiswa';
      case UserRole.dosen:
        return 'Dosen';
      case UserRole.adminProdi:
        return 'Admin Prodi';
      case UserRole.adminFakultas:
        return 'Admin Fakultas';
      case UserRole.adminUniversitas:
        return 'Admin Universitas';
    }
  }
}

class UserAccount {
  const UserAccount({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    required this.unit,
  });

  final String id;
  final String username;
  final String password;
  final String name;
  final UserRole role;
  final String unit;
}
