import 'dart:convert';

import 'package:ecommerce/providers/Inspector.dart';
import 'package:http/http.dart' as http;

class addressesProvider {
  Future<dynamic> getAllAddedAddresses(token) async {
    final http.Response response = await http.get(
      Inspector.baseAPIUrl + "/ShippingAddress/",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Token " + token
      },
    );
    return response;
  }

  Future<dynamic> addAddress(
      token, userId, latitude, longitude, address1, address2, pincode) async {
    Map<String, dynamic> requestData = {
      "user_id": userId,
      "loc_latitude": latitude,
      "loc_lonitude": longitude,
      "address1": address1.toString(),
      "address2": address2.toString(),
      "pincode": pincode,
      "address_category": "Delivey"
    };

    final http.Response response =
        await http.post(Inspector.baseAPIUrl + "/ShippingAddress/",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Token " + token
            },
            body: json.encode(requestData));
    return response;
  }

  Future<dynamic> updateAddress(token, addressId, userId, latitude, longitude,
      address1, address2, pincode) async {
    Map<String, dynamic> requestData = {
      "user_id": userId,
      "loc_latitude": latitude,
      "loc_lonitude": longitude,
      "address1": address1.toString(),
      "address2": address2.toString(),
      "pincode": pincode,
      "address_category": "shipping"
    };

    final http.Response response = await http.put(
        Inspector.baseAPIUrl + "/ShippingAddress/" + addressId.toString() + "/",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Token " + token
        },
        body: json.encode(requestData));
    return response;
  }

  Future<dynamic> deleteAddress(token, addressId) async {
    final http.Response response = await http.delete(
        Inspector.baseAPIUrl + "/ShippingAddress/" + addressId.toString() + "/",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Token " + token
        });
    return response;
  }
}
