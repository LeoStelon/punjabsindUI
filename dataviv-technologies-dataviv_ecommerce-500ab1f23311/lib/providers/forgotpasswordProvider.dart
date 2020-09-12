import 'dart:convert';
import 'package:ecommerce/providers/Inspector.dart';
import 'package:http/http.dart' as http;

class forgotpasswordProvider {
  Future<dynamic> checkForgotPassword(mob_no) async {
    final Map<String, dynamic> requestData = {
      'mob_no': mob_no,
    };
    final http.Response response =
        await http.post(Inspector.baseAPIUrl + "/ForgotPasswordView/",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: json.encode(requestData));
    return response;
  }

  Future<dynamic> forgotPassword(user_id, password) async {
    final Map<String, dynamic> requestData = {
      "userId": user_id,
      "new_password": password
    };
    final http.Response response =
        await http.post(Inspector.baseAPIUrl + "/ForgotPasswordResetView/",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: json.encode(requestData));
    return response;
  }
}
