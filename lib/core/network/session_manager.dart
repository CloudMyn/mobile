import 'package:get/get.dart';
import '../../features/auth/data/models/user_model.dart';

/// Menyimpan data user yang sedang login dalam memory.
///
/// Di-set oleh [AuthController] setelah login berhasil dan oleh
/// [HomeController] setelah load dashboard. Semua controller lain
/// baca dari sini — tidak perlu fetch ulang ke API.
class SessionManager extends GetxService {
  final currentUser = Rx<UserModel?>(null);

  bool get isLoggedIn => currentUser.value != null;

  void setUser(UserModel user) => currentUser.value = user;

  void clear() => currentUser.value = null;
}
