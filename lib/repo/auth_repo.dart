import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Repository quản lý nghiệp vụ tài khoản người dùng.
class AuthRepo {
  final AuthService _authService;

  AuthRepo({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<UserModel?> getCurrentUser() => _authService.getCurrentUser();

  Future<UserModel> signIn(String email, String password) =>
      _authService.signIn(email: email, password: password);

  Future<UserModel> register(
    String email,
    String password,
    String displayName,
  ) =>
      _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );

  Future<UserModel> updateProfile(UserModel currentUser, String displayName) =>
      _authService.updateProfile(
        currentUser: currentUser,
        displayName: displayName,
      );

  Future<void> signOut() => _authService.signOut();
}