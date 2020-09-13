import 'dart:convert';
import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:ecommerce/screens/addresses.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:content_placeholder/content_placeholder.dart';
import 'package:share/share.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String fullName;
  String emailAddress;
  double walletBalance;
  bool isLoading = true;

  String appId = "com.sumit.dataviv.ecommerce";

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
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  logoutCustomer() async {
    //var dbPath = await getDatabasesPath();
    //String path = dbPath + "DATAVIV.db";
    //Database db = await openDatabase(path);
    //await db.execute('DELETE FROM dv_cart');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Global _global = Global();
    await prefs.remove("userDetails");
    await prefs.remove("AUTH_TOKEN");
    await _global.removeAuthToken().then((dynamic data) {
      Navigator.pushReplacementNamed((context), '/login');
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          "Profile",
          style: TextStyle(
            color: ThemeColors.blueColor,
            fontSize: 2.7 * SizeConfig.textMultiplier,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10.0),
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
                                isLoading
                                    ? ContentPlaceholder.block(
                                        width: 40 * SizeConfig.widthMultiplier,
                                        height: 15,
                                      )
                                    : Container(
                                        width: 0.45 * SizeConfig.screenWidth,
                                        //color: Colors.orange,
                                        child: Text(
                                          fullName,
                                          style: TextStyle(
                                            fontSize:
                                                3.0 * SizeConfig.textMultiplier,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                isLoading
                                    ? ContentPlaceholder.block(
                                        width: 45 * SizeConfig.widthMultiplier,
                                        height: 12,
                                      )
                                    : Container(
                                        width: 0.45 * SizeConfig.screenWidth,
                                        //color: Colors.orange,
                                        child: Text(
                                          "+91" + emailAddress.toString(),
                                          style: TextStyle(
                                            fontSize:
                                                2.4 * SizeConfig.textMultiplier,
                                            color: Colors.grey[400],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.clip,
                                          maxLines: 2,
                                        ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 0.50 * SizeConfig.screenWidth,
                                //color: Colors.orange,
                                child: Text(
                                  "Account Credits / Wallet",
                                  style: TextStyle(
                                    fontSize: 2.5 * SizeConfig.textMultiplier,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              isLoading
                                  ? ContentPlaceholder.block(
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      height: 15,
                                    )
                                  : Container(
                                      width: 0.25 * SizeConfig.screenWidth,
                                      //color: Colors.red,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Rs " + walletBalance.toString(),
                                        style: TextStyle(
                                          fontSize:
                                              2.5 * SizeConfig.textMultiplier,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.cyan,
                                        ),
                                        maxLines: 2,
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
                        ListTile(
                          title: Text(
                            "Payment Cards",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 2.7 * SizeConfig.textMultiplier,
                            ),
                          ),
                          subtitle: Text(
                            "Add Credit and Debit card",
                            style: TextStyle(
                              fontSize: 2.3 * SizeConfig.textMultiplier,
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {},
                        ),
                        Divider(
                          height: 10.0,
                          color: Colors.grey,
                        ),
                        ListTile(
                          title: Text(
                            "Address",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 2.7 * SizeConfig.textMultiplier,
                            ),
                          ),
                          subtitle: Text(
                            "Add or remove Delivery address",
                            style: TextStyle(
                              fontSize: 2.3 * SizeConfig.textMultiplier,
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Addresses()));
                          },
                        ),
                        Divider(
                          height: 10.0,
                          color: Colors.grey,
                        ),
                        ListTile(
                          title: Text(
                            "Refer a Friend",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 2.7 * SizeConfig.textMultiplier,
                            ),
                          ),
                          subtitle: Text(
                            "Get 10 % off",
                            style: TextStyle(
                              color: ThemeColors.redColor,
                              fontSize: 2.3 * SizeConfig.textMultiplier,
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Share.share(
                                "Let me recommend you this application :) https://play.google.com/store/apps/details?id=${appId}");
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width,
                child: FlatButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0)),
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  onPressed: () {
                    logoutCustomer();
                  },
                  color: ThemeColors.blueColor,
                  textColor: Colors.white,
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 2.5 * SizeConfig.textMultiplier,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
