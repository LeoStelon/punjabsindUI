import 'package:ecommerce/constant/strings.dart';
import 'package:ecommerce/providers/Inspector.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ordersProvider {
  Future<dynamic> getAllOrders(token) async {
    final http.Response response = await http.get(
      Inspector.baseAPIUrl + "/order/",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Token " + token
      },
    );
    return response;
  }

  Future<dynamic> orderPlaced(
      token,
      userId,
      productsList,
      subTotal,
      deliveryCharges,
      taxCharges,
      discount,
      discountCouponCode,
      grandTotal,
      deliveryAddress,
      payment_mode) async {
    Map<String, dynamic> resquestData = {
      "user_id": userId,
      "products": productsList,
      "subTotal": subTotal,
      "deliveryCharges": deliveryCharges,
      "taxCharges": taxCharges,
      "discount": discount,
      "discountCouponCode": discountCouponCode.toString(),
      "grandTotal": grandTotal,
      "deliveryAddress": deliveryAddress,
      "payment_mode": payment_mode.toString()
    };
    final http.Response response =
        await http.post(Inspector.baseAPIUrl + "/placeOrderView/",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Token " + token
            },
            body: json.encode(resquestData));
    return response;
  }
}
