import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/constant/images.dart';
import 'package:ecommerce/providers/registerProvider.dart';
import 'package:ecommerce/screens/signupverify.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/constant/strings.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final fullnameController = TextEditingController();
  final mobnoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  String mobileNumber;
  bool _validateFullName = false;
  bool _validateMobileNo = false;
  bool _validatePassword = false;
  bool _validateConfirmPassword = false;
  RegExp mobNoRegExp = new RegExp(Strings.mobileNoPatttern);
  RegExp passwordRegExp = new RegExp(Strings.newpasswordPattern);
  FocusNode nodeFullName = FocusNode();
  FocusNode nodeMobileNo = FocusNode();
  FocusNode nodePassword = FocusNode();
  FocusNode nodeConfirmPassword = FocusNode();
  bool isLoading = false;

  validateForm() {
    setState(() {
      if (fullnameController.text.isNotEmpty) {
        _validateFullName = false;
      } else {
        _validateFullName = true;
      }

      mobNoRegExp.hasMatch(mobnoController.text)
          ? _validateMobileNo = false
          : _validateMobileNo = true;

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

      if (_validateFullName) {
        FocusScope.of(context).requestFocus(nodeFullName);
      } else if (_validateMobileNo) {
        FocusScope.of(context).requestFocus(nodeMobileNo);
      } else if (_validatePassword) {
        FocusScope.of(context).requestFocus(nodePassword);
      } else if (_validateConfirmPassword) {
        FocusScope.of(context).requestFocus(nodeConfirmPassword);
      } else if (!_validateFullName &&
          !_validateMobileNo &&
          !_validatePassword &&
          !_validateConfirmPassword) {
        customerCheckRegister(fullnameController.text, mobnoController.text,
            passwordController.text);
      } else {
        print("Somthing Worng");
      }
    });
  }

  void customerCheckRegister(fullname, mobno, password) {
    setState(() {
      isLoading = true;
    });
    RegisterProvider _registerProvider = RegisterProvider();
    _registerProvider
        .checkRegister("rk123@rk.com", mobno)
        .then((dynamic response) async {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        if (responseBody["status"] == "error") {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Mobile number already exists!"),
            duration: Duration(milliseconds: 2000),
          ));
          setState(() {
            isLoading = false;
          });
        } else if (responseBody["status"] == "False") {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("registerMobileNumber", mobno);
          prefs.setString("registerFullName", fullname);
          prefs.setString("registerPassword", password);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SignUpVerify(mobno)));
          Future.delayed(Duration(milliseconds: 500), () {
            setState(() {
              isLoading = false;
            });
            fullnameController.text = "";
            mobnoController.text = "";
            passwordController.text = "";
            confirmpasswordController.text = "";
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildFullNameTF() {
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
              controller: fullnameController,
              focusNode: nodeFullName,
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
                hintText: 'Full name',
                hintStyle: kHintTextStyle,
              ),
              onSubmitted: (value) async {
                validateForm();
              },
            ),
          ),
          _validateFullName
              ? Container(
                  margin: EdgeInsets.only(top: 8, left: 6),
                  child: Text(
                    "Full Name is Required!",
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
                validateForm();
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

    Widget _buildSignupBTn() {
      return Container(
        margin: EdgeInsets.only(top: 15),
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          disabledColor: ThemeColors.yellowColor,
          disabledElevation: 3.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          padding: EdgeInsets.symmetric(vertical: 17),
          onPressed: isLoading
              ? null
              : () {
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
                  Strings.SignUpPageBtn,
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
          padding: EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 15),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Image.asset(
                      Images.screensBgWatermarkLogo,
                    ),
                  ),
                ),
                _buildFullNameTF(),
                _buildMobileTF(),
                _buildPasswordTF(),
                _buildConfirmPasswordTF(),
                _buildSignupBTn(),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "Already have account? ",
                        style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacementNamed(context, "/login");
                          },
                      )
                    ]),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
