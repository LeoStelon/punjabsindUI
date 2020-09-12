import 'package:ecommerce/providers/Inspector.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class homepageProvider {
  Future<dynamic> getHomePageContent() async {
    final http.Response response =
        await http.get(Inspector.baseAPIUrl + "/HomePageContentAPI/", headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });
    return response;
  }

  Future<dynamic> searchProducts(searchTerm) async {
    final http.Response response = await http.get(
        Inspector.baseAPIUrl + "/ProductSearchAPI/?search=" + searchTerm,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        });
    return response;
  }
}
