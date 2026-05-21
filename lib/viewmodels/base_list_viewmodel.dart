import 'package:flutter/foundation.dart';

abstract class BaseListViewModel extends ChangeNotifier {
  String? message;

  bool runAction(String Function() action) {
    // Semua aksi CRUD lewat helper ini supaya sukses/error punya pola sama:
    // service menjalankan validasi, ViewModel menyimpan pesan, lalu UI refresh.
    try {
      message = action();
      notifyListeners();
      return true;
    } on StateError catch (error) {
      message = error.message;
      notifyListeners();
      return false;
    }
  }
}
