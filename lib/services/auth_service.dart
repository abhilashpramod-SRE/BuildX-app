import '../models/role.dart';
import '../models/user.dart';

class AuthService {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser> login({
    required String identity,
    required String password,
    required UserRole role,
  }) async {
    // Placeholder for Firebase Auth / Supabase Auth.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    _currentUser = AppUser(
      id: identity,
      name: identity.split('@').first,
      email: identity,
      role: role,
    );

    return _currentUser!;
  }

  void logout() {
    _currentUser = null;
  }
}
