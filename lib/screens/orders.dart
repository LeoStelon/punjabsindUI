import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:ecommerce/providers/ordersProvider.dart';
import 'package:ecommerce/screens/orderdetails.dart';
import 'package:ecommerce/screens/trackorder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Orders extends StatefulWidget {
  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  bool isLoading = true;
  bool isOrdersEmpty = false;
  List<dynamic> orderList = [];

  String returnOrderDateTime(dateTime) {
    DateTime datetime = DateTime.parse(dateTime);
    String formattedDate = DateFormat('MMM d, yyyy;  kk:mm a').format(datetime);
    return formattedDate;
  }

  void getOrders() async {
    ordersProvider _ordersProvider = ordersProvider();
    Global _global = Global();
    _global.getAuthToken().then((dynamic token) {
      if (token != null) {
        _ordersProvider.getAllOrders(token).then((dynamic response) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody);
          if (response.statusCode == 200) {
            if (responseBody["message"] == "OK" &&
                responseBody["status"] == "success") {
              setState(() {
                orderList = responseBody["data"];
              });
            } else if (responseBody["message"] == "Order Not Created Yet" &&
                responseBody["status"] == "error") {
              setState(() {
                isOrdersEmpty = true;
              });
            }
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isOrdersEmpty ? Colors.white : null,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Order History",
          style: TextStyle(color: ThemeColors.blueColor),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isOrdersEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Image.asset("images/s5.jpeg"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Order Not Created Yet",
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: Column(
                      children: orderList
                          .map(
                            (order) => GestureDetector(
                              child: Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                elevation: 2,
                                shape: Border(left: BorderSide.none),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 10, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: 100,
                                        height: 30,
                                        color: Colors.green,
                                        child: Center(
                                            child: Text(
                                          order["order_status"]
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        )),
                                      ),
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "#" + order["order_id"],
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromRGBO(
                                                      121, 119, 119, 1)),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  returnOrderDateTime(
                                                          order["created_at"])
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
//                                              Text(
//                                                "9 Items",
//                                                style: TextStyle(
//                                                    fontSize: 14,
//                                                    fontWeight:
//                                                        FontWeight.w500),
//                                              ),
                                              ],
                                            ),
                                            Divider(
                                              height: 20,
                                              thickness: 2,
                                              color: Colors.grey[200],
                                            ),
                                            Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "Payable Amount : ₹ " +
                                                        order["grandTotal"]
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  Text(
                                                    order["payment_mode"]
                                                        .toString()
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OrderDetails(order["order_id"])));
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
    );
  }
}
