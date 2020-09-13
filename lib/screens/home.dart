import 'dart:convert';

import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/constant/images.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:ecommerce/providers/homepageProvider.dart';
import 'package:ecommerce/providers/subscriptionProvider.dart';
import 'package:ecommerce/screens/allproducts.dart';
import 'package:ecommerce/screens/cart.dart';
import 'package:ecommerce/screens/wallet.dart';
import 'package:ecommerce/size_config.dart';
import 'package:ecommerce/ui_view/homepage/drawertile.dart';
import 'package:ecommerce/ui_view/homepage/homepage_categories.dart';
import 'package:ecommerce/ui_view/homepage/homepage_featured_sliders.dart';
import 'package:ecommerce/ui_view/homepage/homepage_trending_products.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

final Color backgroundColor = const Color.fromRGBO(255, 202, 0, 1);

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isCollapsed = true;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _menuScaleAnimation;
  Animation<Offset> _slideAnimation;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List trendingProductsList = [];
  List sliders = [];
  List categories = [];
  int _current = 0;
  bool isLoading = false;
  DateTime chosen = DateTime.now();
  String fullName = "";
  String emailAddress = "";
  List subscriptionProducts = [];
  bool isSubscriptionEmpty;

  initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userDetails =
        await json.decode(prefs.get("userDetails"));
    print(userDetails);
    setState(() {
      fullName = userDetails["full_name"];
      emailAddress = userDetails["mob_no"];
    });
  }

  logoutCustomer() async {
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
    //await db.execute('DELETE FROM dv_cart');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Global _global = Global();
    await prefs.remove("userDetails");
    await prefs.remove("AUTH_TOKEN");
    await _global.removeAuthToken().then((dynamic data) {
      Navigator.pushReplacementNamed((context), '/login');
    });
  }

  void homePageContent() async {
    setState(() {
      isLoading = true;
    });
    homepageProvider _homepageProvider = homepageProvider();
    _homepageProvider.getHomePageContent().then((dynamic response) async {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      print(responseBody);
      if (response.statusCode == 200) {
        if (responseBody["message"] == "OK" &&
            responseBody["status"] == "success") {
          setState(() {
            trendingProductsList = responseBody["data"]["trending_products"];
            sliders = responseBody["data"]["features"];
            categories = responseBody["data"]["product_category"];
          });
        } else {
          print("Error Occured!");
        }
        await getAllSubscriptionProducts();
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

  Future getAllSubscriptionProducts() async {
    subscriptionProvider _subscriptionProvider = subscriptionProvider();
    Global _global = Global();
    _global.getAuthToken().then((dynamic token) {
      if (token != null) {
        _subscriptionProvider
            .getAllSubscriptionProducts(token)
            .then((dynamic response) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody);
          if (response.statusCode == 200) {
            if (responseBody["status"] == "error") {
              setState(() {
                isSubscriptionEmpty = true;
              });
            } else if (responseBody["message"] == "OK" &&
                responseBody["status"] == "success") {
              setState(() {
                subscriptionProducts = responseBody["data"];
              });
            }
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(_controller);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
    initialize();
    homePageContent();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: <Widget>[
          menu(context),
          dashboard(context),
        ],
      ),
    );
  }

  Widget menu(context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SafeArea(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (isCollapsed)
                              _controller.forward();
                            else
                              _controller.reverse();

                            isCollapsed = !isCollapsed;
                          });
                        },
                        icon: Icon(Icons.close),
                      ),
                    ),
                    Row(
                      children: [
                        DrawerTileComponent(
                          icon: Icon(
                            Icons.person_outline_rounded,
                          ),
                          title: fullName,
                          subTitle: "+91" + emailAddress,
                          trailing: Text('ok'),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black54,
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/profile'),
                        )
                      ],
                    ),
                    Divider(
                      indent: 20,
                      endIndent: 20,
                      color: Colors.grey[600],
                    ),
                    DrawerTileComponent(
                      icon: Icon(Icons.subscriptions_outlined),
                      title: "My Subscription",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, "/subscription");
                      },
                    ),
                    DrawerTileComponent(
                      icon: Icon(Icons.account_balance_wallet_outlined),
                      title: "Wallet",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Wallet()));
                      },
                    ),
                    DrawerTileComponent(
                      icon: Icon(Icons.shopping_cart_outlined),
                      title: "Cart",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, "/cart");
                      },
                    ),
                    DrawerTileComponent(
                      icon: Icon(Icons.access_time_outlined),
                      title: "Order History",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, "/orders");
                      },
                    ),
                    DrawerTileComponent(
                      icon: Icon(Icons.help_outline),
                      title: "Support & FAQ",
                      onTap: () {},
                    ),
                    DrawerTileComponent(
                      icon: Icon(Icons.power_settings_new_outlined),
                      title: "Logout",
                      onTap: () {
                        // logoutCustomer();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dashboard(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.2 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          animationDuration: duration,
          borderRadius: BorderRadius.all(Radius.circular(isCollapsed ? 0 : 40)),
          elevation: 8,
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        child: Icon(Icons.menu),
                        onTap: () {
                          setState(() {
                            if (isCollapsed)
                              _controller.forward();
                            else
                              _controller.reverse();

                            isCollapsed = !isCollapsed;
                          });
                        },
                      ),
                      //Logo
                      Align(
                        //alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: 80.0,
                          height: 80.0,
                          child: Image.asset(Images.screensBgWatermarkLogo),
                        ),
                      ),

                      //Add Money
                      Container(
                        //margin: EdgeInsets.only(top: 8.0, right: 15.0, bottom: 8.0),
                        child: FlatButton(
                          onPressed: () {},
                          child: Text("+ Add Money"),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0)),
                          padding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 8.0),
                          color: ThemeColors.blueColor,
                          textColor: Colors.grey[100],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 50),

                  //Body
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                          ),
                        )
                      : SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Text('ok'),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    "Nothing is schedule for tomorrow",
                                    style: TextStyle(
                                      fontSize: 2.4 * SizeConfig.textMultiplier,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 10.0, top: 10.0, bottom: 20.0),
                                  child: Column(
                                    children: <Widget>[
                                      MaterialButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AllProducts()));
                                        },
                                        color: Color.fromRGBO(235, 235, 235, 1),
                                        textColor: Colors.black,
                                        child: Icon(
                                          Icons.add,
                                          size: 24,
                                        ),
                                        padding: EdgeInsets.all(16),
                                        shape: CircleBorder(),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Text(
                                        "ADD ITEMS",
                                        style: TextStyle(
                                          color: Colors.cyan,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                HomePageFeaturedSliders(sliders),
                                HomePageTrendingProducts(
                                    trendingProductsList, _scaffoldKey),
                                HomePageCategories(categories),
                                SizedBox(
                                  height: 20,
                                )
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
