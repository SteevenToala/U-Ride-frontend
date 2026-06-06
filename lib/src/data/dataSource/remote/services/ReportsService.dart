import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indriver_clone_flutter/src/data/api/ApiConfig.dart';
import 'package:indriver_clone_flutter/src/domain/models/Report.dart';
import 'package:indriver_clone_flutter/src/domain/utils/ListToString.dart';
import 'package:indriver_clone_flutter/src/domain/utils/Resource.dart';

class ReportsService {
  Future<String> token;

  ReportsService(this.token);

  Future<Resource<Report>> createReport(Report report) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/reports');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token,
      };
      String body = json.encode(report.toJson());
      final response = await http.post(url, headers: headers, body: body);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(Report.fromJson(data));
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<List<Report>>> getReports() async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/reports');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token,
      };
      final response = await http.get(url, headers: headers);
      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<Report> reports = List<Report>.from(data.map((x) => Report.fromJson(x)));
        return Success(reports);
      } else {
        return ErrorData(listToString(data['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }

  Future<Resource<Report>> resolveReport(
    int id, {
    required String status,
    String? adminNotes,
    String? suspendUntil,
    required int adminUserId,
  }) async {
    try {
      Uri url = Uri.http(ApiConfig.API_PROJECT, '/reports/$id/resolve');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': await token,
      };
      Map<String, dynamic> body = {
        'admin_user_id': adminUserId,
        'status': status,
        if (adminNotes != null && adminNotes.isNotEmpty) 'admin_notes': adminNotes,
        if (suspendUntil != null) 'suspend_user_until': suspendUntil,
      };
      final response = await http.put(url, headers: headers, body: json.encode(body));
      final responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Success(Report.fromJson(responseData));
      } else {
        return ErrorData(listToString(responseData['message']));
      }
    } catch (e) {
      return ErrorData(e.toString());
    }
  }
}
