import 'package:ecommerce/providers/Inspector.dart';
import 'package:http/http.dart' as http;

class productProvider {
  Future<dynamic> getAllProducts() async {
    final http.Response response =
        await http.get(Inspector.baseAPIUrl + "/HomePageContentAPI/", headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });
    return response;
  }

  Future<dynamic> productbyCategory(categoryId) async {
    final http.Response response = await http.get(
        Inspector.baseAPIUrl +
            "/GetProductByCategory/" +
            categoryId.toString() +
            "/",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        });
    return response;
  }

  Future<dynamic> allProducts() async {
    final http.Response response =
        await http.get(Inspector.baseAPIUrl + "/product/", headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });
    return response;
  }
}
