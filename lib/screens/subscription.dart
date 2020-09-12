import 'dart:convert';
import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:ecommerce/providers/subscriptionProvider.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';

class Subscription extends StatefulWidget {
  @override
  _SubscriptionState createState() => _SubscriptionState();
}

final GlobalKey<ScaffoldState> _subscriptionPageKey =
    new GlobalKey<ScaffoldState>();

void showToastMessage(String msg) {
  _subscriptionPageKey.currentState.showSnackBar(SnackBar(
    content: Text(msg),
  ));
}

class _SubscriptionState extends State<Subscription> {
  bool isLoading = true;
  bool isSubscriptionEmpty = false;
  List<dynamic> subscriptionLists = [];
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();

  void customerStopProductSubscription(productId) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    subscriptionProvider _subscriptionProvider = subscriptionProvider();
    Global _global = Global();
    _global.getAuthToken().then((dynamic token) {
      if (token != null) {
        _subscriptionProvider
            .stopProductSubscription(token, productId)
            .then((dynamic response) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody);
          if (response.statusCode == 200) {
            if (responseBody["status"] == "success") {
              showToastMessage("Product Subscription has been changed!");
            }
            Navigator.pop(context);
            getAllSubscription();
          } else if (response.statusCode == 404) {
            Navigator.pop(context);
            showToastMessage(responseBody["detail"]);
          } else {
            Navigator.pop(context);
            showToastMessage("Something went wrong. please try again");
          }
        });
      }
    });
  }

  void getAllSubscription() async {
    setState(() {
      isLoading = true;
    });
    subscriptionProvider _subscriptionProvider = subscriptionProvider();
    Global _global = Global();
    _global.getAuthToken().then((dynamic token) {
      print(token);
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
                isLoading = false;
              });
            } else if (responseBody["message"] == "OK" &&
                responseBody["status"] == "success") {
              setState(() {
                subscriptionLists = responseBody["data"];
              });
            }
            setState(() {
              isLoading = false;
            });
          } else {
            showToastMessage("Something went wrong. please try again");
            setState(() {
              isLoading = false;
            });
          }
        });
      }
    });
  }

  void deleteProductSubscription(productId) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    subscriptionProvider _subscriptionProvider = subscriptionProvider();
    Global _global = Global();
    _global.getAuthToken().then((dynamic token) {
      if (token != null) {
        _subscriptionProvider
            .deleteProductSubscription(token, productId)
            .then((dynamic response) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody);
          if (response.statusCode == 200) {
            if (responseBody["status"] == "success") {
              showToastMessage("Product Subscription has been deleted!");
            }
            Navigator.pop(context);
            getAllSubscription();
          } else if (response.statusCode == 404) {
            Navigator.pop(context);
            showToastMessage(responseBody["detail"]);
          } else {
            Navigator.pop(context);
            showToastMessage("Something went wrong. please try again");
          }
        });
      }
    });
  }

  Future<Null> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedStartDate,
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
        initialDate: selectedEndDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedEndDate)
      setState(() {
        selectedEndDate = picked;
        print(selectedEndDate);
      });
  }

  void changeProductSubscription(
      productId, scheduleType, subStartDate, subEndDate) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SubscriptionAlert(
            productId,
            scheduleType,
            DateTime.parse(subStartDate),
            DateTime.parse(subEndDate),
            getAllSubscription);
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _subscriptionPageKey,
      backgroundColor: Colors.white,
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
          "My Subscription",
          style: TextStyle(color: ThemeColors.blueColor),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isSubscriptionEmpty
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
                      "You don't have any Subscription!",
                      style: TextStyle(
                        fontSize: 3.2 * SizeConfig.textMultiplier,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ))
              : SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: Column(
                      children: subscriptionLists
                          .map((subscription) => Container(
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 15),
                                  width: MediaQuery.of(context).size.width,
                                  child: Card(
                                    elevation: 0.0,
                                    color: Color.fromRGBO(249, 249, 249, 1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 25.0, horizontal: 15.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                child: Text(
                                                  "Subscription :     " +
                                                      subscription[
                                                              "schedule_type"]
                                                          .toString(),
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              subscription["status"] == true
                                                  ? Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10.0,
                                                          top: 2.0,
                                                          bottom: 2.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Text(
                                                        "Running",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10.0,
                                                          top: 2.0,
                                                          bottom: 2.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Text(
                                                        "Stopped",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                    )
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Image.network(
                                                subscription["product_id"]
                                                    ["product_images"],
                                                width: 90,
                                                height: 90,
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
                                                      subscription["product_id"]
                                                          ["product_name"],
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 5.0, bottom: 5.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          subscription["product_id"]
                                                                          [
                                                                          "discount"] !=
                                                                      null &&
                                                                  subscription[
                                                                              "product_id"]
                                                                          [
                                                                          "discount"] !=
                                                                      0
                                                              ? "Rs. " +
                                                                  (subscription["product_id"]
                                                                              [
                                                                              "product_price"] -
                                                                          subscription["product_id"]
                                                                              [
                                                                              "discount"])
                                                                      .toString()
                                                              : " Rs. " +
                                                                  subscription[
                                                                              "product_id"]
                                                                          [
                                                                          "product_price"]
                                                                      .toString(),
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      FlatButton.icon(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        textColor: Colors.red,
                                                        onPressed: () {
                                                          changeProductSubscription(
                                                              subscription[
                                                                  "id"],
                                                              subscription[
                                                                  "schedule_type"],
                                                              subscription[
                                                                  "subscription_start_date"],
                                                              subscription[
                                                                  "subscription_end_date"]);
                                                        },
                                                        icon: Icon(
                                                          Icons.calendar_today,
                                                          size: 20,
                                                        ),
                                                        label: Text("Modify"),
                                                      ),
                                                      FlatButton.icon(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        textColor: Colors.red,
                                                        onPressed: () {
                                                          deleteProductSubscription(
                                                              subscription[
                                                                  "id"]);
                                                        },
                                                        icon: Icon(
                                                          Icons.delete,
                                                          size: 20,
                                                        ),
                                                        label: Text("Delete"),
                                                      ),
                                                    ],
                                                  ),
                                                  subscription["status"] == true
                                                      ? FlatButton.icon(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          textColor: Colors.red,
                                                          onPressed: () {
                                                            customerStopProductSubscription(
                                                                subscription[
                                                                    "id"]);
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .pause_circle_outline,
                                                            size: 20,
                                                          ),
                                                          label: Text("Pause"),
                                                        )
                                                      : FlatButton.icon(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          textColor: Colors.red,
                                                          onPressed: () {
                                                            customerStopProductSubscription(
                                                                subscription[
                                                                    "id"]);
                                                          },
                                                          icon: Icon(
                                                            Icons.timer,
                                                            size: 20,
                                                          ),
                                                          label: Text("Start"),
                                                        ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
    );
  }
}

class SubscriptionAlert extends StatefulWidget {
  int productId;
  String scheduleType;
  DateTime selectedStartDate;
  DateTime selectedEndDate;
  Function getAllSubscription;
  SubscriptionAlert(this.productId, this.scheduleType, this.selectedStartDate,
      this.selectedEndDate, this.getAllSubscription);
  @override
  _SubscriptionAlertState createState() => _SubscriptionAlertState();
}

class _SubscriptionAlertState extends State<SubscriptionAlert> {
  bool isLoading = false;
  Future<Null> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: widget.selectedStartDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != widget.selectedStartDate)
      setState(() {
        widget.selectedStartDate = picked;
        print(widget.selectedStartDate);
      });
  }

  Future<Null> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: widget.selectedEndDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != widget.selectedEndDate)
      setState(() {
        widget.selectedEndDate = picked;
        print(widget.selectedEndDate);
      });
  }

  void updateProductSubscription() {
    setState(() {
      isLoading = true;
    });
    subscriptionProvider _subscriptionProvider = subscriptionProvider();
    Global _global = Global();
    _global.getAuthToken().then((dynamic token) {
      if (token != null) {
        _subscriptionProvider
            .updateProductSubscription(
                token,
                widget.productId,
                radioItem,
                widget.selectedStartDate.toLocal().toString().split(' ')[0],
                widget.selectedEndDate.toLocal().toString().split(' ')[0])
            .then((dynamic response) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody);
          if (response.statusCode == 200) {
            if (responseBody["status"] == "success" &&
                responseBody["message"] == "OK") {
              Navigator.pop(context);
              Navigator.pop(context);
              showToastMessage("Product Subscription has been updated!");
              Navigator.pushNamed(context, "/subscription");
            }
          } else if (response.statusCode == 404) {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context);
            showToastMessage(responseBody["detail"]);
          } else {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context);
            showToastMessage("Something went wrong. please try again");
          }
        });
      }
    });
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
  String radioItem;

  // Group Value for Radio Button.
  int id;

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
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      id = returnArrIndex(widget.scheduleType);
      radioItem = Myarr[id - 1];
      print(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : AlertDialog(
            title: new Text("Update Product Subscription"),
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
                        widget.selectedStartDate
                            .toLocal()
                            .toString()
                            .split(' ')[0],
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
                        widget.selectedEndDate
                            .toLocal()
                            .toString()
                            .split(' ')[0],
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
                child: new Text("Change"),
                onPressed: () async {
                  updateProductSubscription();
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
