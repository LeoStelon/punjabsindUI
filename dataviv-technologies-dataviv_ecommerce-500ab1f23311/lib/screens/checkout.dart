import 'dart:convert';
import 'package:content_placeholder/content_placeholder.dart';
import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/providers/addressesProvider.dart';
import 'package:ecommerce/providers/cartProvider.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:ecommerce/providers/ordersProvider.dart';
import 'package:ecommerce/screens/addaddress.dart';
import 'package:ecommerce/screens/editaddress.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class Checkout extends StatefulWidget {
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final GlobalKey<ScaffoldState> _checkoutScaffoldKey =
      new GlobalKey<ScaffoldState>();
  final promoCodeController = TextEditingController();
  double walletBalance;
  bool isLoading = true;
  bool isPromoCodeAppliedLoading = false;
  bool isCartEmpty = false;
  bool isDeliveryChargesApplied = true;
  bool isTaxApplied = false;
  bool isPromoCodeApplied = false;
  int totalCartProducts;
  int deliveryCharge = 20;
  int taxAndFess = 0;
  int grandTotal;
  int subTotal;
  int discount = 0;
  String paymentMode = "cod";
  List<Map<String, dynamic>> cartProducts;
  bool isAddressEmpty = false;
  List<dynamic> allAddresses = [];
  bool isOrderPlacingLoading = false;

  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();

  final node1 = FocusNode();
  final node2 = FocusNode();
  final node3 = FocusNode();

  initialize() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userDetails =
        await json.decode(prefs.get("userDetails"));
    print(userDetails);
    setState(() {
      if (userDetails["wallet_amount"] == null ||
          userDetails["wallet_amount"] == 0.0 ||
          userDetails["wallet_amount"] == 0) {
        walletBalance = 0;
      } else {
        walletBalance = userDetails["wallet_amount"];
      }
    });
    await getCartDetails();
  }

  Future getCartDetails() async {
    var dbPath = await getDatabasesPath();
    String path = dbPath + "DATAVIV.db";
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE dv_cart (id INTEGER PRIMARY KEY, product_id TEXT,product_name TEXT,product_image TEXT, eff_price INTEGER,product_qty INTEGER,total_product_pricing INTEGER)');
      },
    );

    List<Map<String, dynamic>> productslist =
        await db.rawQuery('SELECT * FROM dv_cart');
    List<Map<String, dynamic>> TEMP2 =
        await db.rawQuery('SELECT total_product_pricing FROM dv_cart');
    int amount = 0;
    for (int k = 0; k < TEMP2.length; k++) {
      amount += TEMP2[k]["total_product_pricing"];
    }
    setState(() {
      totalCartProducts = productslist.length;
      subTotal = amount;
      cartProducts = productslist;
    });
    setState(() {
      grandTotal = subTotal + deliveryCharge + taxAndFess;
    });
    if (productslist.length == 0) {
      setState(() {
        isCartEmpty = true;
      });
    }

    addressesProvider _addressesProvider = addressesProvider();
    Global _global = Global();
    await _global.getAuthToken().then((dynamic token) async {
      if (token != null) {
        await _addressesProvider
            .getAllAddedAddresses(token)
            .then((dynamic response) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody);
          if (response.statusCode == 200) {
            if (responseBody["status"] == "error") {
              setState(() {
                isAddressEmpty = true;
              });
            } else if (responseBody["message"] == "OK" &&
                responseBody["status"] == "success") {
              setState(() {
                allAddresses = responseBody["data"];
                isAddressEmpty = false;
              });
            }
          }
        });
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  void applyPromoCode(promoCode) async {
    setState(() {
      isPromoCodeAppliedLoading = true;
    });
    cartProvider _cartProvider = cartProvider();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uD = await prefs.getString("userDetails");
    String AUTH_TOKEN = await prefs.getString("AUTH_TOKEN");
    Map<String, dynamic> userDetails = json.decode(uD);
    int userId = userDetails["userId"];
    await _cartProvider
        .applyPromoCode(userId, cartProducts.length, promoCode, AUTH_TOKEN)
        .then((data) {
      final Map<String, dynamic> responseBody = json.decode(data.body);
      if (data.statusCode == 200) {
        if (responseBody["status"] == "error" &&
            responseBody["message"] == "This Promo Code Is Used ") {
          showToastMessage("This Promo Code is Already Used!");
        } else if (responseBody["status"] == "error" &&
            responseBody["message"] == "promocode Does not Exists") {
          showToastMessage("Invalid Promo Code!");
        } else if (responseBody["status"] == "error" &&
            responseBody["message"] ==
                "offer is valid for minimum 5 quantity") {
          showToastMessage("offer is valid for minimum 5 products quantity");
        } else if (responseBody["status"] == "success" &&
            responseBody["message"] == "OK") {
          int responseDiscount = responseBody["data"]["discount"];
          setState(() {
            discount = responseDiscount;
            grandTotal = subTotal + deliveryCharge + taxAndFess - discount;
            isPromoCodeApplied = true;
          });
        } else {
          showToastMessage("Something went wrong. please try again!");
        }
      } else {
        showToastMessage("Something went wrong. please try again!");
      }
    });
    setState(() {
      isPromoCodeAppliedLoading = false;
    });
  }

  void removePromoCode() async {
    setState(() {
      isPromoCodeApplied = false;
      promoCodeController.text = "";
      grandTotal = subTotal + deliveryCharge + taxAndFess;
    });
  }

  void showToastMessage(String msg) {
    _checkoutScaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  void customerOrderPlace() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    var dbPath = await getDatabasesPath();
    String path = dbPath + "DATAVIV.db";
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE dv_cart (id INTEGER PRIMARY KEY, product_id TEXT,product_name TEXT,product_image TEXT, eff_price INTEGER,product_qty INTEGER,total_product_pricing INTEGER)');
      },
    );

    List<Map<String, dynamic>> productslist =
        await db.rawQuery('SELECT * FROM dv_cart');
    List<Map<String, dynamic>> tempProductsList = [];
    for (int i = 0; i < productslist.length; i++) {
      Map<String, dynamic> tempData = {
        "product_id": productslist[i]["product_id"],
        "quantity": productslist[i]["product_qty"]
      };
      tempProductsList.add(tempData);
    }
    ordersProvider _ordersProvider = ordersProvider();
    Global _global = Global();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userDetails =
        await json.decode(prefs.get("userDetails"));
    int userId = userDetails["userId"];
    await _global.getAuthToken().then((dynamic token) async {
      if (token != null) {
        await _ordersProvider
            .orderPlaced(
                token,
                userId,
                tempProductsList,
                subTotal,
                isDeliveryChargesApplied ? deliveryCharge : 0,
                isTaxApplied ? taxAndFess : 0,
                isPromoCodeApplied ? discount : 0,
                isPromoCodeApplied ? promoCodeController.text : "",
                grandTotal,
                allAddresses[0],
                paymentMode)
            .then((dynamic response) async {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody);
          if (response.statusCode == 200) {
            if (responseBody["status"] == "success" &&
                responseBody["message"] == "OK") {
              Navigator.pop(context);
              var dbPath = await getDatabasesPath();
              String path = dbPath + "DATAVIV.db";
              Database db = await openDatabase(path);
              await db.execute('DELETE FROM dv_cart');
              setState(() {
                isCartEmpty = true;
                isOrderPlacingLoading = true;
              });
              _checkoutScaffoldKey.currentState.showBottomSheet(
                (context) => Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(50.0),
                      topRight: const Radius.circular(50.0),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "images/ok.png",
                          width: 100,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Thank you for your Order.",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 24.0,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            'you can track the delivery in the "Order" section',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 17.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin:
                              EdgeInsets.only(left: 20, right: 20, bottom: 10),
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: FlatButton(
                            disabledTextColor: Colors.grey[100],
                            disabledColor: ThemeColors.blueColor,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0)),
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, "/tabs");
                              Navigator.pushNamed(context, "/orders");
                            },
                            color: ThemeColors.blueColor,
                            textColor: Colors.grey[100],
                            child: Text(
                              "Track Order",
                              style: TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          child: Text(
                            "Order Something else",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 24.0,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pushReplacementNamed(context, "/tabs");
                            Navigator.pushNamed(context, "/orders");
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(50.0),
                    topRight: const Radius.circular(50.0),
                  ),
                ),
                elevation: 4.0,
              );
            } else {
              Navigator.pop(context);
              showToastMessage(responseBody["message"]);
            }
          } else {
            Navigator.pop(context);
            showToastMessage("Something went wrong. please try again");
          }
        });
      }
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
      key: _checkoutScaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          "Checkout",
          style: TextStyle(
            color: ThemeColors.blueColor,
            fontSize: 2.7 * SizeConfig.textMultiplier,
          ),
        ),
      ),
      body: isCartEmpty
          ? Container()
          : isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
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
                                  left: 25.0,
                                  right: 25.0,
                                  top: 20.0,
                                  bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Delivery Address",
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      isAddressEmpty
                                          ? GestureDetector(
                                              child: Text(
                                                "Add +",
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              onTap: () async {
                                                //addDeliveryAddress();
                                                final result = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddAddress(
                                                                title:
                                                                    "Add Delivery Address")));
                                                if (result != null) {
                                                  initialize();
                                                }
                                              },
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  isAddressEmpty
                                      ? Container()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Radio(
                                                  value: null,
                                                  groupValue: null,
                                                  onChanged: null,
                                                ),
                                                Container(
                                                  //color: Colors.orange,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  child: Text(allAddresses[0]
                                                          ["address1"] +
                                                      " " +
                                                      allAddresses[0]
                                                              ["address2"]
                                                          .toString() +
                                                      " ( " +
                                                      allAddresses[0]["pincode"]
                                                          .toString() +
                                                      " ) "),
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              child: Text(
                                                "Change",
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              onTap: () async {
                                                final result =
                                                    await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    EditAddress(
                                                                      title:
                                                                          "Change Delivery Address",
                                                                      addressId:
                                                                          allAddresses[0]["id"]
                                                                              .toString(),
                                                                    )));
                                                if (result != null) {
                                                  initialize();
                                                }
                                              },
                                            )
                                          ],
                                        ),
                                  Divider(
                                    height: 30.0,
                                    color: Colors.grey,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "Account Credits / Wallet",
                                          style: TextStyle(
                                            fontSize: 19.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        isLoading
                                            ? ContentPlaceholder.block(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                                height: 15,
                                              )
                                            : Text(
                                                "Rs " +
                                                    walletBalance.toString(),
                                                style: TextStyle(
                                                  fontSize: 20.0,
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
                        Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Card(
                            elevation: 3.0,
                            color: Color.fromRGBO(249, 249, 249, 1),
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0)),
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: 25.0,
                                  right: 25.0,
                                  top: 20.0,
                                  bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "Payment Methods",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
//                                    Text(
//                                      "Add +",
//                                      style: TextStyle(
//                                        fontSize: 14.0,
//                                        color: Colors.red,
//                                        fontWeight: FontWeight.w500,
//                                      ),
//                                    ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Radio(
                                        value: null,
                                        groupValue: null,
                                        onChanged: null,
                                      ),
                                      Text("Cash on Delivery"),
                                    ],
                                  ),
                                  Divider(
                                    height: 30.0,
                                    color: Colors.grey,
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Enter Coupon Code",
                                          style: TextStyle(
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Stack(
                                          children: <Widget>[
                                            TextField(
                                              cursorColor: Colors.red,
                                              enabled: isPromoCodeApplied ||
                                                      isPromoCodeAppliedLoading
                                                  ? false
                                                  : true,
                                              controller: promoCodeController,
                                              style: TextStyle(),
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              decoration: InputDecoration(
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .never,
                                                  errorStyle: TextStyle(
                                                    fontSize: 15.0,
                                                  ),
                                                  hintText:
                                                      "Enter coupon code here.."),
                                              onSubmitted: (value) async {
                                                applyPromoCode(
                                                    promoCodeController.text);
                                              },
                                            ),
                                            isPromoCodeAppliedLoading
                                                ? Positioned(
                                                    right: 10,
                                                    top: 18,
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  )
                                                : Positioned(
                                                    right: -10,
                                                    top: 5,
                                                    child: isPromoCodeApplied
                                                        ? IconButton(
                                                            icon: Icon(
                                                                Icons.close),
                                                            onPressed: () {
                                                              removePromoCode();
                                                            },
                                                          )
                                                        : FlatButton(
                                                            onPressed: () {
                                                              applyPromoCode(
                                                                  promoCodeController
                                                                      .text);
                                                            },
                                                            child: Text(
                                                              "Apply",
                                                              style: TextStyle(
                                                                fontSize: 17.0,
                                                              ),
                                                            ),
                                                          ),
                                                  )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    height: 30.0,
                                    color: Colors.grey,
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10.0),
                                          child: Text(
                                            "Order Summary",
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                "Sub Total",
                                                style: TextStyle(
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                "Rs. " + subTotal.toString(),
                                                style: TextStyle(
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        isTaxApplied
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      "Tax and Fess",
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      "+ Rs. " +
                                                          taxAndFess.toString(),
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                        isPromoCodeApplied
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      "Discount",
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      "- Rs. 20",
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                        isDeliveryChargesApplied
                                            ? Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      "Delivery",
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      "+ Rs. " +
                                                          deliveryCharge
                                                              .toString(),
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    )
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                        Divider(
                                          height: 30.0,
                                          color: Colors.grey,
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                "Total",
                                                style: TextStyle(
                                                  fontSize: 19.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                "Rs. " + grandTotal.toString(),
                                                style: TextStyle(
                                                  fontSize: 19.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              )
                                            ],
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
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: isOrderPlacingLoading || isLoading
          ? null
          : Container(
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
              width: MediaQuery.of(context).size.width,
              child: FlatButton(
                disabledTextColor: Colors.grey[100],
                disabledColor: ThemeColors.blueColor.withOpacity(0.8),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                padding: EdgeInsets.symmetric(vertical: 12.0),
                onPressed: isPromoCodeAppliedLoading
                    ? null
                    : isAddressEmpty
                        ? () {
                            showToastMessage("Please add Delivery Address!");
                          }
                        : () {
                            customerOrderPlace();
                          },
                color: ThemeColors.blueColor,
                textColor: Colors.grey[100],
                child: Text(
                  "Send Order",
                  style: TextStyle(
                    fontSize: 2.7 * SizeConfig.textMultiplier,
                  ),
                ),
              ),
            ),
    );
  }
}
