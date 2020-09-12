import 'dart:convert';

import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/constant/strings.dart';
import 'package:ecommerce/providers/addressesProvider.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAddress extends StatefulWidget {
  String title;
  String addressId;
  EditAddress({this.title, this.addressId});
  @override
  _EditAddressState createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  bool isPageLoading = false;
  bool isLoading = false;
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final pincodeController = TextEditingController();
  bool _validateAddress1 = false;
  bool _validateAddress2 = false;
  bool _validatePinCode = false;
  FocusNode nodeOne1 = FocusNode();
  FocusNode nodeOne2 = FocusNode();
  FocusNode nodeOne3 = FocusNode();
  final GlobalKey<ScaffoldState> _addAddressPageKey =
      new GlobalKey<ScaffoldState>();
  RegExp pinCodeRegExp = new RegExp(Strings.pinCodePattern);
  List addressDetails = [];

  void showToastMessage(String msg) {
    _addAddressPageKey.currentState.showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  getAddressDetails() async {
    setState(() {
      isPageLoading = true;
    });
    addressesProvider _addressProvider = addressesProvider();
    Global _global = Global();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userDetails =
        await json.decode(prefs.get("userDetails"));
    int userId = userDetails["userId"];
    await _global.getAuthToken().then((dynamic token) async {
      if (token != null) {
        await _addressProvider
            .getAllAddedAddresses(token)
            .then((dynamic response) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody);
          if (response.statusCode == 200) {
            if (responseBody["status"] == "success" &&
                responseBody["message"] == "OK") {
              setState(() {
                addressDetails = responseBody["data"];
                address1Controller.text = addressDetails[0]["address1"];
                address2Controller.text = addressDetails[0]["address2"];
                pincodeController.text = addressDetails[0]["pincode"];
              });
            } else {
              showToastMessage(responseBody["detail"]);
            }
          } else {
            showToastMessage("Something went wrong. please try again");
          }
        });
      }
    });
    setState(() {
      isPageLoading = false;
    });
  }

  void updateAddress(addressId, address1, address2, pincode) async {
    setState(() {
      isLoading = true;
    });
    double lat = 234.084;
    double long = 123.90;
    addressesProvider _addressProvider = addressesProvider();
    Global _global = Global();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userDetails =
        await json.decode(prefs.get("userDetails"));
    int userId = userDetails["userId"];
    await _global.getAuthToken().then((dynamic token) async {
      if (token != null) {
        await _addressProvider
            .updateAddress(token, addressId, userId, lat, long, address1,
                address2, pincode)
            .then((dynamic response) {
          final Map<String, dynamic> responseBody = json.decode(response.body);
          print(responseBody);
          if (response.statusCode == 200) {
            if (responseBody["status"] == "success" &&
                responseBody["message"] == "OK") {
              Navigator.pop(context, "isUpdateAddress");
            } else {
              showToastMessage(responseBody["detail"]);
            }
          } else {
            showToastMessage("Something went wrong. please try again");
          }
        });
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAddressDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _addAddressPageKey,
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
          widget.title != null ? widget.title : "Update Address",
          style: TextStyle(color: ThemeColors.blueColor),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: isPageLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      child: TextField(
                        enabled: isLoading ? false : true,
                        style: TextStyle(),
                        textCapitalization: TextCapitalization.sentences,
                        controller: address1Controller,
                        focusNode: nodeOne1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "House / Flat / Block No.",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          errorText: _validateAddress1
                              ? "This field is Required!"
                              : null,
                          errorStyle: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                        onSubmitted: (value) async {
                          setState(() {
                            if (address1Controller.text.isEmpty) {
                              _validateAddress1 = true;
                            } else {
                              _validateAddress1 = false;
                            }

                            if (address2Controller.text.isEmpty) {
                              _validateAddress2 = true;
                            } else {
                              _validateAddress2 = false;
                            }

                            pinCodeRegExp.hasMatch(pincodeController.text)
                                ? _validatePinCode = false
                                : _validatePinCode = true;
                          });

                          if (_validateAddress1) {
                            FocusScope.of(context).requestFocus(nodeOne1);
                          } else if (_validateAddress2) {
                            FocusScope.of(context).requestFocus(nodeOne2);
                          } else if (_validatePinCode) {
                            FocusScope.of(context).requestFocus(nodeOne3);
                          } else if (!_validateAddress1 &&
                              !_validateAddress2 &&
                              !_validatePinCode) {
                            updateAddress(
                                addressDetails[0]["id"],
                                address1Controller.text,
                                address2Controller.text,
                                pincodeController.text);
                          } else {
                            print("Indvalid Data");
                            FocusScope.of(context).requestFocus(nodeOne1);
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      child: TextField(
                        enabled: isLoading ? false : true,
                        style: TextStyle(),
                        textCapitalization: TextCapitalization.sentences,
                        controller: address2Controller,
                        focusNode: nodeOne2,
                        decoration: InputDecoration(
                          labelText: "City / District / Town",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          errorText: _validateAddress2
                              ? "This field is Required!"
                              : null,
                          errorStyle: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                        onSubmitted: (value) async {
                          setState(() {
                            if (address1Controller.text.isEmpty) {
                              _validateAddress1 = true;
                            } else {
                              _validateAddress1 = false;
                            }

                            if (address2Controller.text.isEmpty) {
                              _validateAddress2 = true;
                            } else {
                              _validateAddress2 = false;
                            }

                            pinCodeRegExp.hasMatch(pincodeController.text)
                                ? _validatePinCode = false
                                : _validatePinCode = true;
                          });

                          if (_validateAddress1) {
                            FocusScope.of(context).requestFocus(nodeOne1);
                          } else if (_validateAddress2) {
                            FocusScope.of(context).requestFocus(nodeOne2);
                          } else if (_validatePinCode) {
                            FocusScope.of(context).requestFocus(nodeOne3);
                          } else if (!_validateAddress1 &&
                              !_validateAddress2 &&
                              !_validatePinCode) {
                            updateAddress(
                                addressDetails[0]["id"],
                                address1Controller.text,
                                address2Controller.text,
                                pincodeController.text);
                          } else {
                            print("Indvalid Data");
                            FocusScope.of(context).requestFocus(nodeOne1);
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      child: TextField(
                        enabled: isLoading ? false : true,
                        style: TextStyle(),
                        textCapitalization: TextCapitalization.sentences,
                        controller: pincodeController,
                        focusNode: nodeOne3,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          counter: Offstage(),
                          labelText: "Pincode",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          errorText: _validatePinCode
                              ? "Please enter valid Pincode!"
                              : null,
                          errorStyle: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                        onSubmitted: (value) async {
                          setState(() {
                            if (address1Controller.text.isEmpty) {
                              _validateAddress1 = true;
                            } else {
                              _validateAddress1 = false;
                            }

                            if (address2Controller.text.isEmpty) {
                              _validateAddress2 = true;
                            } else {
                              _validateAddress2 = false;
                            }

                            pinCodeRegExp.hasMatch(pincodeController.text)
                                ? _validatePinCode = false
                                : _validatePinCode = true;
                          });

                          if (_validateAddress1) {
                            FocusScope.of(context).requestFocus(nodeOne1);
                          } else if (_validateAddress2) {
                            FocusScope.of(context).requestFocus(nodeOne2);
                          } else if (_validatePinCode) {
                            FocusScope.of(context).requestFocus(nodeOne3);
                          } else if (!_validateAddress1 &&
                              !_validateAddress2 &&
                              !_validatePinCode) {
                            updateAddress(
                                addressDetails[0]["id"],
                                address1Controller.text,
                                address2Controller.text,
                                pincodeController.text);
                          } else {
                            print("Indvalid Data");
                            FocusScope.of(context).requestFocus(nodeOne1);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: isPageLoading
          ? null
          : Container(
              margin: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 10),
              width: MediaQuery.of(context).size.width * 0.8,
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                padding: EdgeInsets.symmetric(vertical: 12.0),
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() {
                          if (address1Controller.text.isEmpty) {
                            _validateAddress1 = true;
                          } else {
                            _validateAddress1 = false;
                          }

                          if (address2Controller.text.isEmpty) {
                            _validateAddress2 = true;
                          } else {
                            _validateAddress2 = false;
                          }

                          pinCodeRegExp.hasMatch(pincodeController.text)
                              ? _validatePinCode = false
                              : _validatePinCode = true;
                        });

                        if (_validateAddress1) {
                          FocusScope.of(context).requestFocus(nodeOne1);
                        } else if (_validateAddress2) {
                          FocusScope.of(context).requestFocus(nodeOne2);
                        } else if (_validatePinCode) {
                          FocusScope.of(context).requestFocus(nodeOne3);
                        } else if (!_validateAddress1 &&
                            !_validateAddress2 &&
                            !_validatePinCode) {
                          updateAddress(
                              addressDetails[0]["id"],
                              address1Controller.text,
                              address2Controller.text,
                              pincodeController.text);
                        } else {
                          print("Indvalid Data");
                          FocusScope.of(context).requestFocus(nodeOne1);
                        }
                      },
                color: ThemeColors.blueColor,
                textColor: Colors.white,
                disabledColor: ThemeColors.blueColor,
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text(
                        "Update Address",
                        style: TextStyle(
                          fontSize: 17.0,
                        ),
                      ),
              ),
            ),
    );
  }
}
