import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/constant/images.dart';
import 'package:ecommerce/constant/strings.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:ecommerce/providers/loginProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String userName;
  String passWord;
  bool _validateUsername = false;
  bool _validatePassword = false;
  FocusNode nodeOne1 = FocusNode();
  FocusNode nodeOne2 = FocusNode();
  bool isLoading = false;
  RegExp mobNoRegExp = new RegExp(Strings.mobileNoPatttern);

  void _login(username, password) async {
    setState(() {
      isLoading = true;
    });
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

  Future loginWithFacebook() async {
    final facebookLogin = FacebookLogin();
    //facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${token}');
        final profile = json.decode(graphResponse.body);
        print(profile);
        break;
      case FacebookLoginStatus.cancelledByUser:
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Facebook login cancelled by user!'),
          duration: Duration(milliseconds: 2000),
        ));
        break;
      case FacebookLoginStatus.error:
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Unable to login with Facebook!'),
          duration: Duration(milliseconds: 2000),
        ));
        break;
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
    Widget _buildEmailTF() {
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
              controller: usernameController,
              focusNode: nodeOne1,
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
                  Icons.person,
                  color: Colors.grey,
                ),
                hintText: 'Mobile Number',
                hintStyle: kHintTextStyle,
              ),
              onSubmitted: (value) async {
                setState(() {
                  mobNoRegExp.hasMatch(usernameController.text)
                      ? _validateUsername = false
                      : _validateUsername = true;

                  if (passwordController.text.isEmpty) {
                    _validatePassword = true;
                  } else {
                    _validatePassword = false;
                  }
                });

                if (_validateUsername) {
                  FocusScope.of(context).requestFocus(nodeOne1);
                } else if (_validatePassword) {
                  FocusScope.of(context).requestFocus(nodeOne2);
                } else if (!_validateUsername && !_validatePassword) {
                  print(usernameController.text);
                  print(passwordController.text);
                  await _login(
                      usernameController.text, passwordController.text);
                } else {
                  print("Indvalid Data");
                  FocusScope.of(context).requestFocus(nodeOne1);
                }
              },
            ),
          ),
          _validateUsername
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
              focusNode: nodeOne2,
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
                setState(() {
                  mobNoRegExp.hasMatch(usernameController.text)
                      ? _validateUsername = false
                      : _validateUsername = true;

                  if (passwordController.text.isEmpty) {
                    _validatePassword = true;
                  } else {
                    _validatePassword = false;
                  }
                });

                if (_validateUsername) {
                  FocusScope.of(context).requestFocus(nodeOne1);
                } else if (_validatePassword) {
                  FocusScope.of(context).requestFocus(nodeOne2);
                } else if (!_validateUsername && !_validatePassword) {
                  print(usernameController.text);
                  print(passwordController.text);
                  await _login(
                      usernameController.text, passwordController.text);
                } else {
                  print("Indvalid Data");
                  FocusScope.of(context).requestFocus(nodeOne1);
                }
              },
            ),
          ),
          _validatePassword
              ? Container(
                  margin: EdgeInsets.only(top: 8, left: 6),
                  child: Text(
                    "Password is Required!",
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

    Widget _buildLoginBtn() {
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
                    mobNoRegExp.hasMatch(usernameController.text)
                        ? _validateUsername = false
                        : _validateUsername = true;

                    if (passwordController.text.isEmpty) {
                      _validatePassword = true;
                    } else {
                      _validatePassword = false;
                    }
                  });
                  if (!_validateUsername && !_validatePassword) {
                    print(usernameController.text);
                    print(passwordController.text);
                    await _login(usernameController.text.trim(),
                        passwordController.text);
                  } else {
                    print("Indvalid Data");
                    FocusScope.of(context).requestFocus(nodeOne1);
                  }
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
                  "LOGIN",
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
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Image.asset(
                          Images.screensBgWatermarkLogo,
                        ),
                      ),
                    ),
                    _buildEmailTF(),
                    _buildPasswordTF(),
                    _buildLoginBtn(),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: MediaQuery.of(context).size.width,
                      child: RaisedButton(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        onPressed: () {
                          loginWithFacebook();
                        },
                        color: Color.fromRGBO(40, 114, 201, 1),
                        textColor: Colors.grey[100],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            FaIcon(
                              FontAwesomeIcons.facebookF,
                              size: 22,
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Text(
                              "Connect with facebook",
                              style: TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: GestureDetector(
                        child: Text(
                          "Forgot Password ?",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _validateUsername = false;
                            _validatePassword = false;
                          });
                          usernameController.text = "";
                          passwordController.text = "";
                          Navigator.pushNamed(context, "/forgot_password");
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Don't have an Account ? ",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[800],
                            ),
                          ),
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              fontSize: 16.0,
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
