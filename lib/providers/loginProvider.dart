import 'package:ecommerce/providers/Inspector.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginProvider {
  Future<dynamic> customerLogin(username, password) async {
    final Map<String, dynamic> requestData = {
      'username': username,
      'password': password,
    };
    final http.Response response =
        await http.post(Inspector.baseAPIUrl + "/api-token-auth/",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: json.encode(requestData));
    return response;
  }
}
