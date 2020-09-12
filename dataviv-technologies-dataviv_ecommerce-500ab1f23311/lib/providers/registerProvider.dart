import 'package:ecommerce/providers/Inspector.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterProvider {
  Future<dynamic> customerRegistration(fullname, mob_no, password) async {
    final Map<String, dynamic> requestData = {
      'full_name': fullname,
      'mob_no': mob_no,
      'password': password,
    };
    final http.Response response =
        await http.post(Inspector.baseAPIUrl + "/CreateUserRegister/",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: json.encode(requestData));
    return response;
  }

  Future<dynamic> customerAddEmailAddress(token, user_id, email) async {
    final Map<String, dynamic> requestData = {
      "userId": user_id,
      "email": email
    };
    final http.Response response =
        await http.post(Inspector.baseAPIUrl + "/AddUserEmail/",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Token " + token
            },
            body: json.encode(requestData));
    return response;
  }

  Future<dynamic> checkRegister(email, mob_no) async {
    final Map<String, dynamic> requestData = {'email': email, 'mob_no': mob_no};
    final http.Response response = await http.post(
        Inspector.baseAPIUrl + "/EmaiId_Mobile_no_Verification/",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode(requestData));
    return response;
  }
}
