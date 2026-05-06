import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:indriver_clone_flutter/src/data/api/ApiConfig.dart';
import 'package:indriver_clone_flutter/src/domain/models/user.dart';
import 'package:indriver_clone_flutter/src/domain/utils/ListToString.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';
import 'package:path/path.dart';

class UsersService {

  Future<String> token;

  UsersService(this.token);

  Future<Resource<User>> update(int id, User user) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/users/$id');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      String body = json.encode({
        'name': user.name,
        'lastname': user.lastname,
        'phone': user.phone,
        'career': user.career,
        'reference_zone': user.referenceZone,
      });
      final response = await http.put(url, headers: headers, body: body);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        User userResponse = User.fromJson(data);
        return Success(userResponse);
      }
      else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<User>> updateNotificationToken(int id, String notificationToken) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/users/notification_token/$id');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      String body = json.encode({
        'notification_token': notificationToken,
      });
      final response = await http.put(url, headers: headers, body: body);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        User userResponse = User.fromJson(data);
        return Success(userResponse);
      }
      else {
        print('ERROR ${listToString(data['message'])}');
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<User>> updateImage(int id, User user, XFile file) async { 
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/users/upload/$id');
      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = await token;
      
      final bytes = await file.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: basename(file.path),
        contentType: MediaType('image', 'jpg')
      ));
      
      request.fields['name'] = user.name;
      request.fields['lastname'] = user.lastname;
      request.fields['phone'] = user.phone ?? '';
      request.fields['career'] = user.career ?? '';
      request.fields['reference_zone'] = user.referenceZone ?? '';
      final response = await request.send();
      final data = json.decode(await response.stream.transform(utf8.decoder).first);
      if (response.statusCode == 200 || response.statusCode == 201) {
        User userResponse = User.fromJson(data);
        return Success(userResponse);
      }
      else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<User>> requestDriverRole(int id) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/users/request-driver/$id');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      final response = await http.put(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        User userResponse = User.fromJson(data);
        return Success(userResponse);
      }
      else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<List<User>>> getPendingDrivers() async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/users/pending-drivers');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<User> users = List<User>.from(data.map((x) => User.fromJson(x)));
        return Success(users);
      }
      else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<User>> approveDriverRole(int id) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/users/approve-driver/$id');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      final response = await http.put(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        User userResponse = User.fromJson(data);
        return Success(userResponse);
      }
      else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<List<User>>> getUsers() async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/users');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<User> users = List<User>.from(data.map((x) => User.fromJson(x)));
        return Success(users);
      }
      else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

  Future<Resource<User>> suspendUser(int id) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/users/suspend/$id');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token
      };
      final response = await http.put(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        User userResponse = User.fromJson(data);
        return Success(userResponse);
      }
      else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      print('Error: $e');
      return ErrorData(e.toString());
    }
  }

}