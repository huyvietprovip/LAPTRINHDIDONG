import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repo/auth_repo.dart';

/// Provider quản lý trạng thái tài khoản người dùng.
class AuthProvider extends ChangeNotifier {
  final AuthRepo _authRepo;

  AuthProvider({AuthRepo? authRepo}) : _authRepo = authRepo ?? AuthRepo();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  /// Kiểm tra phiên đăng nhập khi mở ứng dụng.
  Future<void> checkAuthState() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authRepo.getCurrentUser();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _authRepo.signIn(email, password);
      return true;
    } catch (e) {
      _errorMessage = 'Đăng nhập thất bại: ${_cleanError(e)}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String email,
    String password,
    String displayName,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _authRepo.register(email, password, displayName);
      return true;
    } catch (e) {
      _errorMessage = 'Đăng ký thất bại: ${_cleanError(e)}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String displayName) async {
    if (_user == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _authRepo.updateProfile(_user!, displayName);
      return true;
    } catch (e) {
      _errorMessage = 'Cập nhật thất bại: ${_cleanError(e)}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    _user = null;
    notifyListeners();
  }

  String _cleanError(Object e) {
    return e.toString().replaceAll('Exception: ', '');
  }
}