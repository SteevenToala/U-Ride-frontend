import 'dart:convert';

import 'package:indriver_clone_flutter/src/data/api/ApiConfig.dart';
import 'package:http/http.dart' as http;
import 'package:indriver_clone_flutter/src/domain/models/AuthResponse.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/domain/utils/ListToString.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class AuthService {

  Future<Resource<AuthResponse>> login(String email, String password) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/auth/login');
      Map<String, String> headers = { 'Content-Type': 'application/json' };
      String body = json.encode({
        'email': email,
        'password': password
      });
      final response = await http.post(url, headers: headers, body: body);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        AuthResponse authResponse = AuthResponse.fromJson(data);
        print('Data Remote: ${authResponse.toJson()}');
        print('Token: ${authResponse.token}');
        return Success(authResponse);
      }
      else {
        return ErrorData(listToString(data['message']));
      }
      
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

   Future<Resource<AuthResponse>> register(User user, XFile? image) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/auth/register');
      
      if (image == null) {
        Map<String, String> headers = { 'Content-Type': 'application/json' };
        String body = json.encode(user);
        final response = await http.post(url, headers: headers, body: body);
        final data = json.decode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          AuthResponse authResponse = AuthResponse.fromJson(data);
          return Success(authResponse);
        }
        else {
          return ErrorData(listToString(data['message']));
        }
      }
      else {
        final bytes = await image.readAsBytes();
        final request = http.MultipartRequest('POST', url);
        request.files.add(http.MultipartFile.fromBytes(
          'file', 
          bytes,
          filename: path.basename(image.path),
          contentType: MediaType('image', 'jpeg')
        ));
        request.fields['name'] = user.name;
        request.fields['lastname'] = user.lastname;
        request.fields['email'] = user.email ?? '';
        request.fields['phone'] = user.phone ?? '';
        request.fields['password'] = user.password ?? '';
        request.fields['career'] = user.career ?? '';
        request.fields['reference_zone'] = user.referenceZone ?? '';
        request.fields['rolesIds'] = user.rolesIds?.join(',') ?? '';
        
        final response = await request.send();
        final responseData = await response.stream.transform(utf8.decoder).join();
        final data = json.decode(responseData);
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          AuthResponse authResponse = AuthResponse.fromJson(data);
          return Success(authResponse);
        }
        else {
          return ErrorData(listToString(data['message']));
        }
      }
      
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<bool>> forgotPassword(String email) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/auth/forgot-password');
      Map<String, String> headers = { 'Content-Type': 'application/json' };
      String body = json.encode({
        'email': email,
      });
      final response = await http.post(url, headers: headers, body: body);
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(true);
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<bool>> validateResetCode(String email, String code) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/auth/validate-reset-code');
      Map<String, String> headers = { 'Content-Type': 'application/json' };
      String body = json.encode({
        'email': email,
        'code': code,
      });
      final response = await http.post(url, headers: headers, body: body);
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(true);
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<bool>> resetPassword(String email, String code, String newPassword) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/auth/reset-password');
      Map<String, String> headers = { 'Content-Type': 'application/json' };
      String body = json.encode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      });
      final response = await http.post(url, headers: headers, body: body);
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(true);
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<bool>> verifyAccount(String email, String code) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/auth/verify-account');
      Map<String, String> headers = { 'Content-Type': 'application/json' };
      String body = json.encode({
        'email': email,
        'code': code,
      });
      final response = await http.post(url, headers: headers, body: body);
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(true);
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

}