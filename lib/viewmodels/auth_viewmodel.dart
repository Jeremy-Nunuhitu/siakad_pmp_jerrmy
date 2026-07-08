import 'package:flutter/foundation.dart';

import '../models/siakad_models.dart';
import '../services/mock_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._service);

  final MockService _service;
  User? currentUser;
  String? errorMessage;

  bool get isLoggedIn => currentUser != null;

  bool login(String username, String password) {
    // View memanggil method ini saat tombol login ditekan.
    // Hasil dari MockService disimpan sebagai currentUser untuk menentukan role.
    final user = _service.login(username, password);
    if (user == null) {
      errorMessage = 'Username atau password salah';
      notifyListeners();
      return false;
    }
    currentUser = user;
    errorMessage = null;
    _service.recordActivity(
      actor: user,
      action: 'Login',
      target: 'Sesi Pengguna',
      description: '${user.name} masuk ke sistem',
    );
    notifyListeners();
    return true;
  }

  void logout() {
    // Logout menghapus sesi user lalu memberi tahu UI agar kembali ke login.
    final user = currentUser;
    if (user != null) {
      _service.recordActivity(
        actor: user,
        action: 'Logout',
        target: 'Sesi Pengguna',
        description: '${user.name} keluar dari sistem',
      );
    }
    currentUser = null;
    errorMessage = null;
    notifyListeners();
  }
}
