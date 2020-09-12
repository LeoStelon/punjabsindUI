import 'dart:convert';

import 'package:ecommerce/providers/Inspector.dart';
import 'package:http/http.dart' as http;

class subscriptionProvider {
  Future<dynamic> getAllSubscriptionProducts(token) async {
    final http.Response response = await http.get(
      Inspector.baseAPIUrl + "/ProductSubscribe/",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Token " + token
      },
    );
    return response;
  }

  Future<dynamic> newProductSubscription(token, userId, productId, scheduleType,
      subscriptionStartDate, subscriptionEndDate) async {
    Map<String, dynamic> requestData = {
      "user_id": userId,
      "product_id": productId.toString(),
      "schedule_type": scheduleType,
      "subscription_start_date": subscriptionStartDate,
      "subscription_end_date": subscriptionEndDate
    };

    final http.Response response =
        await http.post(Inspector.baseAPIUrl + "/ProductSubscribe/",
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Token " + token
            },
            body: json.encode(requestData));
    return response;
  }

  Future<dynamic> updateProductSubscription(token, productId, scheduleType,
      subscriptionStartDate, subscriptionEndDate) async {
    Map<String, dynamic> requestData = {
      "schedule_type": scheduleType,
      "subscription_start_date": subscriptionStartDate,
      "subscription_end_date": subscriptionEndDate
    };

    final http.Response response = await http.put(
        Inspector.baseAPIUrl +
            "/ProductSubscribe/" +
            productId.toString() +
            "/",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Token " + token
        },
        body: json.encode(requestData));
    return response;
  }

  Future<dynamic> deleteProductSubscription(token, productId) async {
    final http.Response response = await http.delete(
        Inspector.baseAPIUrl +
            "/ProductSubscribe/" +
            productId.toString() +
            "/",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Token " + token
        });
    return response;
  }

  Future<dynamic> stopProductSubscription(token, productId) async {
    final http.Response response = await http.post(
        Inspector.baseAPIUrl +
            "/ProductSubscribeStopeAndResume/" +
            productId.toString() +
            "/",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Token " + token
        });
    return response;
  }

  Future<dynamic> getProductSubscriptionDetails(token, productId) async {
    final http.Response response = await http.get(
        Inspector.baseAPIUrl + "/ProductSubscribe/" + productId + "/",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Token " + token
        });
    return response;
  }
}
