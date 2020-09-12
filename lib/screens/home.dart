import 'dart:convert';
import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/constant/images.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:ecommerce/providers/homepageProvider.dart';
import 'package:ecommerce/providers/subscriptionProvider.dart';
import 'package:ecommerce/screens/wallet.dart';
import 'package:ecommerce/size_config.dart';
import 'package:ecommerce/ui_view/homepage/homepage_categories.dart';
import 'package:ecommerce/ui_view/homepage/homepage_featured_sliders.dart';
import 'package:ecommerce/ui_view/homepage/homepage_trending_products.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:custom_horizontal_calendar/custom_horizontal_calendar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ecommerce/screens/allproducts.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    // TODO: implement initState
    super.initState();
    initialize();
    homePageContent();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> gridWidget = [
      Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "images/track.png",
              width: 60,
              height: 60,
            ),
            SizedBox(
              height: 8.0,
            ),
            FittedBox(
              child: Text(
                "Track Order",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 3.2 * SizeConfig.textMultiplier,
                    fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 1),
          border: Border.all(
            color: Color.fromRGBO(235, 235, 235, 1),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.person,
                color: ThemeColors.blueColor,
                size: 45,
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              title: Text(fullName),
              subtitle: Text(
                "+91" + emailAddress,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(
              indent: 20,
              endIndent: 20,
              color: Colors.grey[600],
            ),
            ListTile(
              leading: Icon(Icons.subscriptions),
              title: Text("My Subscription"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/subscription");
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text("Wallet"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Wallet()));
              },
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text("Order History"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/orders");
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text("Support & FAQ"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.power_settings_new),
              title: Text("Logout"),
              onTap: () {
                logoutCustomer();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Container(),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        bottom: PreferredSize(
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 10.0,
                  top: 17.0,
                  child: SizedBox(
                    child: IconButton(
                      icon: Icon(
                        Icons.menu,
                        size: 32.0,
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState.openDrawer();
                      },
                    ),
                  ),
                ),
                Align(
                  //alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 80.0,
                    height: 80.0,
                    child: Image.asset(Images.screensBgWatermarkLogo),
                  ),
                ),
                Positioned(
                  top: 20.0,
                  right: 10.0,
                  child: Container(
                    //margin: EdgeInsets.only(top: 8.0, right: 15.0, bottom: 8.0),
                    child: FlatButton(
                      onPressed: () {},
                      child: Text("+ Add Money"),
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0)),
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                      color: ThemeColors.blueColor,
                      textColor: Colors.grey[100],
                    ),
                  ),
                )
              ],
            ),
            preferredSize: Size.fromHeight(30)),
      ),
      body: isLoading
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
                      margin:
                          EdgeInsets.only(left: 10.0, top: 10.0, bottom: 20.0),
                      child: Column(
                        children: <Widget>[
                          MaterialButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AllProducts()));
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
    );
  }
}

class ProductSearch extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return null;
  }
}
