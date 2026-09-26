import 'package:get/get.dart';

/// Holds whether the user is signed in.
///
/// Registered as a permanent service so the session outlives individual
/// controllers, controllers and routes being torn down and rebuilt.
///
/// The session is in-memory only: a fresh install (or a restart) starts signed
/// out. Persisting it needs storage, which is not wired up yet.
class AuthService extends GetxService {
  final RxBool isLoggedIn = false.obs;

  /// Marks the user as signed in.
  void login() => isLoggedIn.value = true;

  /// Marks the user as signed out. The next protected route will bounce to the
  /// login form.
  void logout() => isLoggedIn.value = false;
}
