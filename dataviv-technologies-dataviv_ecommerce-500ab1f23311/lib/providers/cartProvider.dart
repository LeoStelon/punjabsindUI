import 'dart:convert';

import 'package:ecommerce/providers/Inspector.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class cartProvider {
  Future applyPromoCode(
      int userId, int cartQuantity, String promoCode, String token) async {
    Map<String, dynamic> requestData = {
      "user_id": userId,
      "cartQuantity": cartQuantity,
      "promo_code": promoCode
    };
    http.Response response = await http.post(
        Inspector.baseAPIUrl + "/Offer_Apply/",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token " + token
        },
        body: json.encode(requestData));
    return response;
  }
}
