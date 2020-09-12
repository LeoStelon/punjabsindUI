import 'dart:convert';
import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/constant/images.dart';
import 'package:ecommerce/constant/strings.dart';
import 'package:ecommerce/providers/forgotpasswordProvider.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:ecommerce/providers/loginProvider.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  bool _validatePassword = false;
  bool _validateConfirmPassword = false;
  RegExp passwordRegExp = new RegExp(Strings.newpasswordPattern);
  FocusNode nodePassword = FocusNode();
  FocusNode nodeConfirmPassword = FocusNode();
  bool isLoading = false;

  void _login(username, password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Global _global = Global();
    LoginProvider _loginProvider = LoginProvider();
    await _loginProvider
        .customerLogin(username, password)
        .then((dynamic response) async {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      print(responseBody);
      if (response.statusCode == 200) {
        if (responseBody["status"] == "success" &&
            responseBody["token"] != null) {
          String token = responseBody["token"]["token"];
          Map<String, dynamic> userDetails =
              responseBody["token"]["userDetails"]["user"][0];
          await prefs.setString("userDetails", json.encode(userDetails));
          await _global.setAuthToken(token);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Login Successfully!'),
            duration: Duration(milliseconds: 2000),
          ));
          Navigator.pushReplacementNamed(context, "/location");
        } else if (responseBody["status"] == "error" &&
            responseBody.containsKey("username")) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Username is must required!'),
            duration: Duration(milliseconds: 2000),
          ));
        } else if (responseBody["status"] == "error" &&
            responseBody.containsKey("password")) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Password is must required!'),
            duration: Duration(milliseconds: 2000),
          ));
        } else if (responseBody["status"] == "error" &&
            responseBody["message"]["non_field_errors"][0] ==
                "Unable to log in with provided credentials.") {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Invalid login credentials!'),
            duration: Duration(milliseconds: 2000),
          ));
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Login Faild!'),
            duration: Duration(milliseconds: 2000),
          ));
        }
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  void customerChangePassword(String password) async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = await prefs.getInt("forgotPasswordUserId");
    String mobno = await prefs.getString("forgotPasswordMobNo");
    forgotpasswordProvider _forgotpasswordProvider = forgotpasswordProvider();
    _forgotpasswordProvider
        .forgotPassword(userId, password)
        .then((dynamic response) async {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      print(response.body);
      if (response.statusCode == 200) {
        if (responseBody["status"] == "error") {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(responseBody["message"]),
            duration: Duration(milliseconds: 2000),
          ));
          setState(() {
            isLoading = false;
          });
        } else if (responseBody["status"] == "success" &&
            responseBody["message"] == "OK") {
          await _login(mobno, password);
          passwordController.text = "";
          confirmpasswordController.text = "";
        }
      }
    });
  }

  validateForm() {
    setState(() {
      passwordRegExp.hasMatch(passwordController.text)
          ? _validatePassword = false
          : _validatePassword = true;

      if (confirmpasswordController.text.isNotEmpty) {
        if (passwordController.text == confirmpasswordController.text) {
          passwordRegExp.hasMatch(confirmpasswordController.text)
              ? _validateConfirmPassword = false
              : _validateConfirmPassword = true;
        } else {
          _validateConfirmPassword = true;
        }
      } else {
        _validateConfirmPassword = true;
      }
    });

    if (_validatePassword) {
      FocusScope.of(context).requestFocus(nodePassword);
    } else if (_validateConfirmPassword) {
      FocusScope.of(context).requestFocus(nodeConfirmPassword);
    } else if (!_validatePassword && !_validateConfirmPassword) {
      customerChangePassword(passwordController.text);
    } else {
      print("Somthing Worng");
    }
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
    Widget _buildPasswordTF() {
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
              focusNode: nodePassword,
              controller: passwordController,
              obscureText: true,
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.grey,
                ),
                hintText: 'Password',
                hintStyle: kHintTextStyle,
              ),
              onSubmitted: (value) async {
                validateForm();
              },
            ),
          ),
          _validatePassword
              ? Container(
                  margin: EdgeInsets.only(top: 8, left: 6),
                  child: Text(
                    "Password must be at least 6 chars Required!",
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

    Widget _buildConfirmPasswordTF() {
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
              focusNode: nodeConfirmPassword,
              controller: confirmpasswordController,
              obscureText: true,
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Colors.grey,
                ),
                hintText: 'Confirm Password',
                hintStyle: kHintTextStyle,
              ),
              onSubmitted: (value) async {
                validateForm();
              },
            ),
          ),
          _validateConfirmPassword
              ? Container(
                  margin: EdgeInsets.only(top: 8, left: 6),
                  child: Text(
                    "Confirm Password does't match!",
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
                  validateForm();
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
                  "CHANGE PASSWORD",
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
                        "Enter password to proceed",
                        style: TextStyle(
                          fontSize: 2.7 * SizeConfig.textMultiplier,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _buildPasswordTF(),
                    _buildConfirmPasswordTF(),
                    _buildContinueBtn(),
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
