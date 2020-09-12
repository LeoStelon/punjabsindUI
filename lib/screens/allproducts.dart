import 'dart:convert';
import 'package:ecommerce/providers/global.dart';
import 'package:ecommerce/providers/productProvider.dart';
import 'package:ecommerce/providers/subscriptionProvider.dart';
import 'package:ecommerce/size_config.dart';
import 'package:ecommerce/ui_view/categoryproducts/stackcontainers.dart';
import 'package:ecommerce/ui_view/subscription/subscriptionproductList.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllProducts extends StatefulWidget {
  @override
  _AllProductsState createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  final GlobalKey<ScaffoldState> _productsScaffoldKey =
      new GlobalKey<ScaffoldState>();
  List products = [];
  bool isLoading = true;
  int _currentIndex = 0;
  List<String> ringTone = ['All', 'Price - Low to High', 'Price - High to Low'];

  Future<void> _showMyDialog() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState2) {
              return AlertDialog(
                title: Text('Sort by'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('RESET'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context, ringTone[_currentIndex]);
                    },
                    child: Text('APPLY'),
                  ),
                ],
                content: Container(
                  width: double.minPositive,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ringTone.length,
                    itemBuilder: (BuildContext context, int index) {
                      return RadioListTile(
                        value: index,
                        groupValue: _currentIndex,
                        title: Text(ringTone[index]),
                        onChanged: (val) {
                          setState2(() {
                            _currentIndex = val;
                          });
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        });
  }

  getAllCategoryProducts() async {
    productProvider _productProvider = productProvider();
    _productProvider.allProducts().then((dynamic response) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      print(responseBody);
      if (response.statusCode == 200) {
        if (responseBody["message"] == "OK" &&
            responseBody["status"] == "success") {
          setState(() {
            products = responseBody["data"];
          });
        } else {
          print("Error Occured!");
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllCategoryProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _productsScaffoldKey,
      extendBody: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            StackContainers(),
            Positioned(
              top: 30.0,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              top: 220,
              child: Container(
                padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Color.fromRGBO(235, 235, 235, 1),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50)),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  //color: Colors.green,
                  margin: EdgeInsets.only(top: 10, left: 10.0, right: 10.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "All Products",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                          ),
//                          IconButton(
//                            icon: Icon(Icons.filter_list),
//                            onPressed: () {
//                              _showMyDialog();
//                            },
//                          )
                        ],
                      ),
                      isLoading
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.6,
                              //color: Colors.red,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : SubscriptionProductList(
                              products, _productsScaffoldKey),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddSubscriptionAlert extends StatefulWidget {
  String productId;
  final GlobalKey<ScaffoldState> _productsScaffoldKey;
  AddSubscriptionAlert(this.productId, this._productsScaffoldKey);
  @override
  _AddSubscriptionAlertState createState() => _AddSubscriptionAlertState();
}

class _AddSubscriptionAlertState extends State<AddSubscriptionAlert> {
  bool isAddProductSubscriptionLoading = false;
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  Future<Null> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedStartDate)
      setState(() {
        selectedStartDate = picked;
        print(selectedStartDate);
      });
  }

  Future<Null> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedEndDate)
      setState(() {
        selectedEndDate = picked;
        print(selectedEndDate);
      });
  }

  void addProductSubscription() async {
    setState(() {
      isAddProductSubscriptionLoading = true;
    });
    subscriptionProvider _subscriptionProvider = subscriptionProvider();
    Global _global = Global();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userDetails =
        await json.decode(prefs.get("userDetails"));
    int userId = userDetails["userId"];
    _global.getAuthToken().then((dynamic token) {
      if (token != null) {
        _subscriptionProvider
            .newProductSubscription(
                token,
                userId,
                widget.productId,
                radioItem,
                selectedStartDate.toLocal().toString().split(' ')[0],
                selectedEndDate.toLocal().toString().split(' ')[0])
            .then((dynamic response) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody);
          if (response.statusCode == 200) {
            if (responseBody["status"] == "success" &&
                responseBody["message"] == "OK") {
              showToastMessage("Product Subscription has been added!");
              Navigator.pop(context);
            } else if (responseBody["status"] == "error") {
              showToastMessage(responseBody["message"]);
              Navigator.pop(context);
            }
          } else {
            showToastMessage("Something went wrong. please try again");
            Navigator.pop(context);
          }
        });
      }
    });
  }

  void showToastMessage(String msg) {
    widget._productsScaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  List<String> Myarr = ["Daily", "Alternate Day", "Every 3 days", "Weekly"];

  int returnArrIndex(scheduleType) {
    int index;
    for (int i = 0; i < Myarr.length; i++) {
      if (Myarr[i] == scheduleType) {
        index = i + 1;
      }
    }
    return index;
  }

  // Default Radio Button Item
  String radioItem = "Daily";

  // Group Value for Radio Button.
  int id = 1;

  List<ScheduleList> fList = [
    ScheduleList(
      index: 1,
      name: "Daily",
    ),
    ScheduleList(
      index: 2,
      name: "Alternate Day",
    ),
    ScheduleList(
      index: 3,
      name: "Every 3 days",
    ),
    ScheduleList(
      index: 4,
      name: "Weekly",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return isAddProductSubscriptionLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : AlertDialog(
            title: new Text("Add Product Subscription"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text("Schedule Type"),
                ),
                Column(
                  children: fList
                      .map((data) => RadioListTile(
                            title: Text("${data.name}"),
                            groupValue: id,
                            value: data.index,
                            onChanged: (val) {
                              setState(() {
                                radioItem = data.name;
                                id = data.index;
                              });
                            },
                          ))
                      .toList(),
                ),
                Container(
                  child: Text("Subscription Start Sate"),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        selectedStartDate.toLocal().toString().split(' ')[0],
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      GestureDetector(
                        child: Text(
                          "Change",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () {
                          _selectStartDate(context);
                        },
                      )
                    ],
                  ),
                ),
                Container(
                  child: Text("Subscription End Date"),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        selectedEndDate.toLocal().toString().split(' ')[0],
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      GestureDetector(
                        child: Text(
                          "Change",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.blue,
                          ),
                        ),
                        onTap: () {
                          _selectEndDate(context);
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              new FlatButton(
                child: new Text("Add Subscription"),
                onPressed: () async {
                  addProductSubscription();
                },
              ),
            ],
          );
  }
}

class ScheduleList {
  String name;
  int index;
  ScheduleList({this.name, this.index});
}
