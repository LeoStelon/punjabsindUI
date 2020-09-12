import 'package:ecommerce/providers/Inspector.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccountProvider {
  String AUTH_TOKEN;

  Future<String> getToken() async {
    Global _global = Global();
    AUTH_TOKEN = await _global.getAuthToken();
    return AUTH_TOKEN;
  }

  Future<dynamic> customerDetails() async {
    final http.Response response = await http.post(
      Inspector.baseAPIUrl + "/UserAPI/",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Token " + AUTH_TOKEN
      },
    );
    return response;
  }

  Future<dynamic> customerCheckForgotPassword(mob_no) async {
    final Map<String, dynamic> requestData = {
      "mob_no": mob_no,
    };
    final http.Response response =
        await http.post(Inspector.baseAPIUrl + "/AddUserEmail/",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: json.encode(requestData));
    return response;
  }
}
