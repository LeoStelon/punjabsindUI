import 'package:ecommerce/providers/Inspector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Global {
  Future<dynamic> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = await prefs.getString("AUTH_TOKEN");
    return token;
  }

  Future<dynamic> setAuthToken(token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isTokenStore = await prefs.setString("AUTH_TOKEN", token);
    return isTokenStore;
  }

  Future<dynamic> removeAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isTokenRemove = await prefs.remove("AUTH_TOKEN");
    return isTokenRemove;
  }

  Future<dynamic> isLoggedIn(token) async {
    final http.Response response =
        await http.post(Inspector.baseAPIUrl + "/UserAPI/", headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "token " + token,
    });
    return response;
  }
}
