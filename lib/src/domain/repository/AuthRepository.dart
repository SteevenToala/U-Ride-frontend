import 'package:image_picker/image_picker.dart';
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

abstract class AuthRepository {

  Future<Resource<AuthResponse>> login(String email, String password);
  Future<Resource<AuthResponse>> register(User user, XFile? image);
  Future<void> saveUserSession(AuthResponse authResponse);
  Future<AuthResponse?> getUserSession();
  Future<bool> logout();
  Future<Resource<bool>> forgotPassword(String email);
  Future<Resource<bool>> validateResetCode(String email, String code);
  Future<Resource<bool>> resetPassword(String email, String code, String newPassword);
  Future<Resource<bool>> verifyAccount(String email, String code);
}