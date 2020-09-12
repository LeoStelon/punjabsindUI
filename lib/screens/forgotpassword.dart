import 'dart:convert';
import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/constant/images.dart';
import 'package:ecommerce/constant/strings.dart';
import 'package:ecommerce/providers/forgotpasswordProvider.dart';
import 'package:ecommerce/screens/forgotpasswordverify.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final mobnoController = TextEditingController();
  bool _validateMobileNo = false;
  RegExp mobNoRegExp = new RegExp(Strings.mobileNoPatttern);
  FocusNode nodeMobileNo = FocusNode();
  bool isLoading = false;

  void customerForgotPassword(String mobno) async {
    setState(() {
      isLoading = true;
    });
    forgotpasswordProvider _forgotpasswordProvider = forgotpasswordProvider();
    _forgotpasswordProvider
        .checkForgotPassword(mobno)
        .then((dynamic response) async {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      print(response.body);
      if (response.statusCode == 200) {
        if (responseBody["status"] == "error") {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Your account does't exists in our system!"),
            duration: Duration(milliseconds: 2000),
          ));
          setState(() {
            isLoading = false;
          });
        } else if (responseBody["status"] == "success" &&
            responseBody["message"] == "OK") {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt(
              "forgotPasswordUserId", responseBody["data"]["userId"]);
          await prefs.setString(
              "forgotPasswordMobNo", responseBody["data"]["mob_no"]);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ForgotPasswordVerify(mobno)));
          Future.delayed(Duration(milliseconds: 500), () {
            setState(() {
              isLoading = false;
            });
            mobnoController.text = "";
          });
        }
      }
    });
  }

  final kHintTextStyle = TextStyle(
    color: Colors.grey,
    fontFamily: 'OpenSans',
  );

  final kLabelStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontFamily: 'OpenSans',
  );

  final kBoxDecorationStyle = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(30.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 4.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    Widget _buildMobileTF() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: TextField(
              enabled: isLoading ? false : true,
              controller: mobnoController,
              focusNode: nodeMobileNo,
              keyboardType: TextInputType.number,
              maxLength: 10,
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                counter: Offstage(),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.call,
                  color: Colors.grey,
                ),
                hintText: 'Mobile Number',
                hintStyle: kHintTextStyle,
              ),
              onSubmitted: (value) async {
                setState(() {
                  mobNoRegExp.hasMatch(mobnoController.text)
                      ? _validateMobileNo = false
                      : _validateMobileNo = true;

                  if (_validateMobileNo) {
                    FocusScope.of(context).requestFocus(nodeMobileNo);
                  } else if (!_validateMobileNo) {
                    customerForgotPassword(mobnoController.text);
                  } else {
                    print("Somthing Worng");
                  }
                });
              },
            ),
          ),
          _validateMobileNo
              ? Container(
                  margin: EdgeInsets.only(top: 8, left: 6),
                  child: Text(
                    "Please enter valid mobile number!",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Container()
        ],
      );
    }

    Widget _buildContinueBtn() {
      return Container(
        margin: EdgeInsets.only(top: 20),
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          disabledColor: ThemeColors.yellowColor,
          disabledElevation: 3.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          padding: EdgeInsets.symmetric(vertical: 18.0),
          onPressed: isLoading
              ? null
              : () async {
                  setState(() {
                    mobNoRegExp.hasMatch(mobnoController.text)
                        ? _validateMobileNo = false
                        : _validateMobileNo = true;

                    if (_validateMobileNo) {
                      FocusScope.of(context).requestFocus(nodeMobileNo);
                    } else if (!_validateMobileNo) {
                      customerForgotPassword(mobnoController.text);
                    } else {
                      print("Somthing Worng");
                    }
                  });
                },
          color: ThemeColors.yellowColor,
          textColor: Colors.black,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                )
              : Text(
                  "CONTINUE",
                  style: TextStyle(
                    fontSize: 17.0,
                  ),
                ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 30, left: 30, right: 30),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Image.asset(
                        Images.screensBgWatermarkLogo,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                        "Enter mobile number to proceed forgot password",
                        style: TextStyle(
                          fontSize: 2.7 * SizeConfig.textMultiplier,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _buildMobileTF(),
                    _buildContinueBtn(),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Don't have an Account ? ",
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Colors.grey[800],
                            ),
                          ),
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacementNamed(
                                    context, "/signup");
                              },
                          )
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
