import 'dart:convert';

import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String fullName;
  String emailAddress;
  double walletBalance;
  bool isLoading = true;

  initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userDetails =
        await json.decode(prefs.get("userDetails"));
    print(userDetails);
    setState(() {
      fullName = userDetails["full_name"];
      emailAddress = userDetails["mob_no"];
      if (userDetails["wallet_amount"] == null ||
          userDetails["wallet_amount"] == 0.0 ||
          userDetails["wallet_amount"] == 0) {
        walletBalance = 0;
      } else {
        walletBalance = userDetails["wallet_amount"];
      }
    });
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Wallet",
          style: TextStyle(color: ThemeColors.blueColor),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Card(
                      elevation: 3.0,
                      color: Color.fromRGBO(249, 249, 249, 1),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQ3W2b0jcCQUk6d4vQsnRfped9P8tM51dhYuQ&usqp=CAU"),
                                ),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      fullName,
                                      style: TextStyle(
                                        fontSize:
                                            3.0 * SizeConfig.textMultiplier,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "+91" + emailAddress,
                                      style: TextStyle(
                                        fontSize:
                                            2.4 * SizeConfig.textMultiplier,
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.clip,
                                    )
                                  ],
                                )
                              ],
                            ),
                            Divider(
                              height: 30.0,
                              color: Colors.grey,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10.0, right: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Account Credits / Wallet",
                                    style: TextStyle(
                                      fontSize: 2.5 * SizeConfig.textMultiplier,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "Rs " + walletBalance.toString(),
                                    style: TextStyle(
                                      fontSize: 2.5 * SizeConfig.textMultiplier,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.cyan,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Card(
                        elevation: 3.0,
                        color: Color.fromRGBO(249, 249, 249, 1),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                          child: Center(
                            child: Text(
                              "No Transaction found!",
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
