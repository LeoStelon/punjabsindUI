import 'dart:convert';

import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/constant/images.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:ecommerce/providers/loginProvider.dart';
import 'package:ecommerce/providers/registerProvider.dart';
import 'package:ecommerce/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/constant/strings.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpVerify extends StatefulWidget {
  String mobileNumber;
  SignUpVerify(this.mobileNumber);
  @override
  _SignUpVerifyState createState() => _SignUpVerifyState();
}

class _SignUpVerifyState extends State<SignUpVerify> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final otpController = TextEditingController();
  bool _validateOTP = false;
  FocusNode nodeOTP = FocusNode();
  bool isLoading = false;
  bool isCodeSent = false;
  String _verificationId;

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
          Navigator.pushNamedAndRemoveUntil(
              context, "/location", (Route<dynamic> route) => false);
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

  void _register() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fullname = await prefs.getString("registerFullName");
    String mobno = await prefs.getString("registerMobileNumber");
    String password = await prefs.getString("registerPassword");
    RegisterProvider _registerProvider = RegisterProvider();
    _registerProvider
        .customerRegistration(fullname, mobno, password)
        .then((dynamic response) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        if (responseBody["status"] == "success" &&
            responseBody["message"] == "OK") {
          _login(mobno, password);
        } else if (responseBody["status"] == "error") {
          showToast("Error occureed during registeration!", Colors.red);
          setState(() {
            isLoading = false;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    //widget.mobileNumber = 8209446178.toString();
    _onVerifyCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
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
                        "OTP has been sent to +91" + widget.mobileNumber,
                        style: TextStyle(
                          fontSize: 2.8 * SizeConfig.textMultiplier,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                        Strings.SignUpVerifOTPMessage,
                        style: TextStyle(
                          fontSize: 2.7 * SizeConfig.textMultiplier,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          height: 60.0,
                          child: PinInputTextField(
                            pinLength: 6,
                            decoration: UnderlineDecoration(
                                gapSpace: 20, color: Colors.grey[800]),
                            controller: otpController,
                            focusNode: nodeOTP,
                            textInputAction: TextInputAction.go,
                            enabled: isLoading ? false : true,
                            keyboardType: TextInputType.number,
                            onSubmit: (pin) async {
                              if (otpController.text.length == 6) {
                                _onFormSubmitted();
                              } else {
                                showToast(
                                    "Please enter 6 digit OTP!", Colors.red);
                              }
                            },
                            enableInteractiveSelection: true,
                          ),
                        ),
                        _validateOTP
                            ? Container(
                                margin: EdgeInsets.only(top: 8, left: 6),
                                child: Text(
                                  "Please enter 6 digit OTP!",
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    ),
                    Container(
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
                                if (otpController.text.length == 6) {
                                  _onFormSubmitted();
                                } else {
                                  showToast(
                                      "Please enter 6 digit OTP!", Colors.red);
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
                                Strings.SignUpVerifBtn,
                                style: TextStyle(
                                  fontSize: 17.0,
                                ),
                              ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Don't received OTP ? ",
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Colors.grey[800],
                            ),
                          ),
                          TextSpan(
                            text: "Resend",
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _onVerifyCode();
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

  void _onVerifyCode() async {
    setState(() {
      isCodeSent = true;
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((AuthResult value) {
        if (value.user != null) {
          // Handle loogged in state
          print(value.user.phoneNumber);
          showToast("Verification Successfully!", Colors.green);
        } else {
          showToast("Error validating OTP, try again", Colors.red);
        }
      }).catchError((error) {
        handleError(error);
        print(error.toString());
      });
    };
    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      showToast(authException.message, Colors.red);
      setState(() {
        isCodeSent = false;
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };

    // TODO: Change country code

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+91${widget.mobileNumber}",
        timeout: const Duration(seconds: 120),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    showToast("OTP has been sent!", Colors.green);
  }

  void _onFormSubmitted() async {
    setState(() {
      isLoading = true;
    });
    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: otpController.text);

    _firebaseAuth
        .signInWithCredential(_authCredential)
        .then((AuthResult value) {
      if (value.user != null) {
        // Handle loogged in state
        print(value.user.phoneNumber);
        _register();
      } else {
        showToast("Error validating OTP, try again", Colors.red);
        setState(() {
          isLoading = false;
        });
      }
    }).catchError((error) {
      handleError(error);
      print(error.toString());
      setState(() {
        isLoading = false;
      });
    });
  }

  showToast(String msg, Color color) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(msg),
      duration: Duration(milliseconds: 2000),
    ));
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        showToast("Invalid OTP!", Colors.red);
        break;
      case 'ERROR_SESSION_EXPIRED':
        showToast("The sms code has expired. Please re-send!", Colors.red);
        break;
      default:
        showToast("Something went wrong.please try again!", Colors.red);
        break;
    }
  }
}
