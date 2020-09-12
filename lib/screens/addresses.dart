import 'dart:convert';

import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/providers/addressesProvider.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:ecommerce/screens/addaddress.dart';
import 'package:ecommerce/screens/editaddress.dart';
import 'package:flutter/material.dart';

import '../size_config.dart';

class Addresses extends StatefulWidget {
  @override
  _AddressesState createState() => _AddressesState();
}

class _AddressesState extends State<Addresses> {
  final GlobalKey<ScaffoldState> _addressesPageKey =
      new GlobalKey<ScaffoldState>();
  bool isLoading = true;
  bool isAddressEmpty = false;
  List<dynamic> allAddresses = [];

  void getAllAddresses() async {
    setState(() {
      isLoading = true;
    });
    addressesProvider _addressesProvider = addressesProvider();
    Global _global = Global();
    _global.getAuthToken().then((dynamic token) {
      if (token != null) {
        _addressesProvider.getAllAddedAddresses(token).then((dynamic response) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody);
          if (response.statusCode == 200) {
            if (responseBody["status"] == "error") {
              setState(() {
                isAddressEmpty = true;
                isLoading = false;
              });
            } else if (responseBody["message"] == "OK" &&
                responseBody["status"] == "success") {
              setState(() {
                isAddressEmpty = false;
                allAddresses = responseBody["data"];
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

  void customerDeleteAddresses(addressId) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    addressesProvider _addressesProvider = addressesProvider();
    Global _global = Global();
    _global.getAuthToken().then((dynamic token) {
      if (token != null) {
        _addressesProvider
            .deleteAddress(token, addressId)
            .then((dynamic response) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody);
          if (response.statusCode == 200) {
            Navigator.pop(context);
            getAllAddresses();
            showToastMessage("Address has been deleted successfully!");
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

  void showToastMessage(String msg) {
    _addressesPageKey.currentState.showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _addressesPageKey,
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
          "My Addresses",
          style: TextStyle(
            color: ThemeColors.blueColor,
            fontSize: 2.8 * SizeConfig.textMultiplier,
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isAddressEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Image.asset("images/s9.jpeg"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "You don't have any Address!",
                        style: TextStyle(
                          fontSize: 24.0,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: 20, left: 25, right: 25, bottom: 10),
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: FlatButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0)),
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddAddress()),
                            );
                            if (result != null) {
                              getAllAddresses();
                            }
                          },
                          color: ThemeColors.blueColor,
                          textColor: Colors.white,
                          child: Text(
                            "+ Add new Address",
                            style: TextStyle(
                              fontSize: 17.0,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Column(
                      children: allAddresses
                          .map(
                            (address) => Column(
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(width: 15.0),
                                    Icon(
                                      Icons.home,
                                      size: 27.0,
                                      color: Colors.grey[800],
                                    ),
                                    SizedBox(width: 20.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          child: Text(
                                            address["address1"],
                                            style: TextStyle(
                                              fontSize: 19.0,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.80,
                                          child: Text(
                                            address["address2"] +
                                                " ( " +
                                                address["pincode"].toString() +
                                                " ) ",
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 15.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            InkWell(
                                              highlightColor:
                                                  Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              onTap: () async {
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditAddress(
                                                            addressId:
                                                                address["id"]
                                                                    .toString(),
                                                          )),
                                                );

                                                if (result != null) {
                                                  getAllAddresses();
                                                }
                                              },
                                              child: Text(
                                                'EDIT',
                                                style: TextStyle(
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              splashColor: Colors.transparent,
                                            ),
                                            SizedBox(width: 15.0),
                                            InkWell(
                                              highlightColor:
                                                  Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              onTap: () => showDialog<void>(
                                                context: context,
                                                barrierDismissible:
                                                    false, // user must tap button!
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        Text('Delete Address'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: ListBody(
                                                        children: <Widget>[
                                                          Text(
                                                              'Are you sure you want to delete this address?'),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text('NO'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      FlatButton(
                                                          child: Text('YES'),
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            customerDeleteAddresses(
                                                                address["id"]);
                                                          }),
                                                    ],
                                                  );
                                                },
                                              ),
                                              child: Text(
                                                'DELETE',
                                                style: TextStyle(
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              splashColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 7.0),
                                Divider(
                                  indent: 60.0,
                                  endIndent: 20.0,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
    );
  }
}
