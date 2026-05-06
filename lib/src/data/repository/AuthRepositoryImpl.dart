import 'package:image_picker/image_picker.dart';
import 'package:indriver_clone_flutter/src/data/dataSource/local/SharefPref.dart';
import 'package:indriver_clone_flutter/src/data/dataSource/remote/services/AuthService.dart';
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/domain/repository/AuthRepository.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class AuthRepositoryImpl implements AuthRepository {
  
  AuthService authService;
  SharefPref sharefPref;

  AuthRepositoryImpl(this.authService, this.sharefPref);

  @override
  Future<Resource<AuthResponse>> login(String email, String password) {
    return authService.login(email, password);
  }

  @override
  Future<Resource<AuthResponse>> register(User user, XFile? image) {
    return authService.register(user, image);
  }
  
  @override
  Future<AuthResponse?> getUserSession() async {
    final data = await sharefPref.read('user');
    if (data != null) {
      AuthResponse authResponse = AuthResponse.fromJson(data);
      return authResponse;
    }
    return null;
  }
  
  @override
  Future<void> saveUserSession(AuthResponse authResponse) async {
    sharefPref.save('user', authResponse.toJson());
  }
  
  @override
  Future<bool> logout() async {
    return await sharefPref.remove('user');
  }

  @override
  Future<Resource<bool>> forgotPassword(String email) {
    return authService.forgotPassword(email);
  }

  @override
  Future<Resource<bool>> validateResetCode(String email, String code) {
    return authService.validateResetCode(email, code);
  }

  @override
  Future<Resource<bool>> resetPassword(String email, String code, String newPassword) {
    return authService.resetPassword(email, code, newPassword);
  }

}