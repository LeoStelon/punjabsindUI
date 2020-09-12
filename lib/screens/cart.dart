import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final GlobalKey<ScaffoldState> _cartScaffoldKey =
      new GlobalKey<ScaffoldState>();
  bool isLoading = true;
  bool isCartEmpty = false;
  int totalCartProducts;
  int deliveryCharge = 20;
  int taxAndFess = 0;
  int grandTotal;
  int subTotal;
  int discount;
  List<Map<String, dynamic>> cartProducts;

  addToCart(String productId) async {
    var dbPath = await getDatabasesPath();
    String path = dbPath + "DATAVIV.db";
    //await deleteDatabase(path);
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE dv_cart (id INTEGER PRIMARY KEY, product_id TEXT,product_name TEXT,product_image TEXT, eff_price INTEGER,product_qty INTEGER,total_product_pricing INTEGER)');
      },
    );
    List<Map<String, dynamic>> list = await db.rawQuery(
        'SELECT * FROM dv_cart WHERE product_id=?', [productId.toString()]);
    int price = list[0]['eff_price'];
    int qty = list[0]['product_qty'] + 1;
    int totalPrice = qty * price;
    int count = await db.rawUpdate(
        'UPDATE dv_cart SET product_qty = ?, total_product_pricing = ? WHERE product_id = ?',
        [qty, totalPrice, productId]);
    print(count);
    getCartDetails();
  }

  void deleteToCart(String productId) async {
    var dbPath = await getDatabasesPath();
    String path = dbPath + "DATAVIV.db";
    var db = await openDatabase(path);
    List<Map<String, dynamic>> list = await db
        .rawQuery('SELECT * FROM dv_cart WHERE product_id=?', [productId]);
    if (list[0]["product_qty"] == 1) {
      int id = await db
          .rawDelete('DELETE FROM dv_cart WHERE product_id = ?', [productId]);
      print(id);
      getCartDetails();
    } else {
      int price = list[0]['eff_price'];
      int qty = list[0]['product_qty'] - 1;
      int totalPrice = qty * price;
      int count = await db.rawUpdate(
          'UPDATE dv_cart SET product_qty = ?, total_product_pricing = ? WHERE product_id = ?',
          [qty, totalPrice, productId]);
      print(count);
      getCartDetails();
    }
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
    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCartDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _cartScaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          "My Order",
          style: TextStyle(
            color: ThemeColors.blueColor,
            fontSize: 2.7 * SizeConfig.textMultiplier,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isCartEmpty
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
                        "Your cart is empty!",
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ],
                  ),
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
                                  left: 10.0,
                                  right: 10.0,
                                  top: 10.0,
                                  bottom: 10.0),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 10.0, right: 10.0, bottom: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "Sub Total",
                                          style: TextStyle(
                                            fontSize:
                                                2.9 * SizeConfig.textMultiplier,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "Rs. " + subTotal.toString(),
                                          style: TextStyle(
                                            fontSize:
                                                2.9 * SizeConfig.textMultiplier,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
//                                  Container(
//                                    margin: EdgeInsets.only(
//                                        left: 10.0, right: 10.0, bottom: 5.0),
//                                    child: Row(
//                                      mainAxisAlignment:
//                                          MainAxisAlignment.spaceBetween,
//                                      children: <Widget>[
//                                        Text(
//                                          "Tax and Fess",
//                                          style: TextStyle(
//                                            fontSize: 18.0,
//                                            fontWeight: FontWeight.w500,
//                                          ),
//                                        ),
//                                        Text(
//                                          "+ Rs. " + taxAndFess.toString(),
//                                          style: TextStyle(
//                                            fontSize: 18.0,
//                                            fontWeight: FontWeight.w500,
//                                            color: Colors.grey,
//                                          ),
//                                        )
//                                      ],
//                                    ),
//                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "Delivery",
                                          style: TextStyle(
                                            fontSize:
                                                3.0 * SizeConfig.textMultiplier,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "+ Rs. " + deliveryCharge.toString(),
                                          style: TextStyle(
                                            fontSize:
                                                3.0 * SizeConfig.textMultiplier,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.start,
                                        )
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    height: 30.0,
                                    color: Colors.grey,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "Total",
                                          style: TextStyle(
                                            fontSize:
                                                3.1 * SizeConfig.textMultiplier,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "Rs. " + grandTotal.toString(),
                                          style: TextStyle(
                                            fontSize:
                                                3.1 * SizeConfig.textMultiplier,
                                            fontWeight: FontWeight.w600,
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
                                  left: 10.0,
                                  right: 10.0,
                                  top: 10.0,
                                  bottom: 10.0),
                              child: Column(
                                children: cartProducts
                                    .map((product) => Container(
                                          //color: Colors.orange,
                                          margin: EdgeInsets.only(bottom: 20.0),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Container(
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.23,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.23,
                                                  child: Image.network(
                                                    product["product_image"],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15.0,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Text(
                                                        product["product_name"],
                                                        style: TextStyle(
                                                          fontSize: 2.7 *
                                                              SizeConfig
                                                                  .textMultiplier,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5.0,
                                                          bottom: 5.0),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(
                                                            product["product_qty"]
                                                                    .toString() +
                                                                " × Rs. " +
                                                                product["eff_price"]
                                                                    .toString(),
                                                            style: TextStyle(
                                                              color: ThemeColors
                                                                  .blueColor,
                                                              fontSize: 2.5 *
                                                                  SizeConfig
                                                                      .textMultiplier,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.55,
                                                      //color: Colors.deepOrange,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Container(
                                                            //margin: EdgeInsets.only(right: 5.0),
                                                            height: 37.0,
                                                            //width: 110.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: ThemeColors
                                                                      .blueColor,
                                                                  width: 1),
                                                            ),
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                IconButton(
                                                                  icon: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    color: ThemeColors
                                                                        .blueColor,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    deleteToCart(
                                                                        product[
                                                                            "product_id"]);
                                                                  },
                                                                ),
                                                                Text(
                                                                  product["product_qty"]
                                                                      .toString(),
                                                                ),
                                                                IconButton(
                                                                  icon: Icon(
                                                                    Icons.add,
                                                                    color: ThemeColors
                                                                        .blueColor,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    addToCart(
                                                                        product[
                                                                            "product_id"]);
                                                                  },
                                                                ),
                                                              ],
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                            ),
                                                          ),
                                                          Container(
                                                            //color: Colors.blue,
                                                            //alignment: Alignment
                                                            //s   .center,
                                                            child: Text(
                                                              "Rs. " +
                                                                  product["total_product_pricing"]
                                                                      .toString(),
                                                              style: TextStyle(
                                                                color: ThemeColors
                                                                    .blueColor,
                                                                fontSize: 2.5 *
                                                                    SizeConfig
                                                                        .textMultiplier,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: isLoading || isCartEmpty
          ? null
          : Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              width: MediaQuery.of(context).size.width,
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                padding: EdgeInsets.symmetric(vertical: 12.0),
                onPressed: () {
                  Navigator.pushNamed(context, "/checkout");
                },
                color: ThemeColors.blueColor,
                textColor: Colors.grey[100],
                child: Text(
                  "Checkout",
                  style: TextStyle(
                    fontSize: 2.7 * SizeConfig.textMultiplier,
                  ),
                ),
              ),
            ),
    );
  }
}
