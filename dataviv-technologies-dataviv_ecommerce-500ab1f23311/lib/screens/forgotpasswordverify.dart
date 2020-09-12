import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/constant/images.dart';
import 'package:ecommerce/constant/strings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

import '../size_config.dart';

class ForgotPasswordVerify extends StatefulWidget {
  String mobileNumber;
  ForgotPasswordVerify(this.mobileNumber);
  @override
  _ForgotPasswordVerifyState createState() => _ForgotPasswordVerifyState();
}

class _ForgotPasswordVerifyState extends State<ForgotPasswordVerify> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final otpController = TextEditingController();
  bool _validateOTP = false;
  FocusNode nodeOTP = FocusNode();
  bool isLoading = false;
  bool isCodeSent = false;
  String _verificationId;

  @override
  void initState() {
    super.initState();
    //widget.mobileNumber = 8209446178.toString();
    _onVerifyCode();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildMobileTF() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10.0),
          Container(
            alignment: Alignment.center,
            child: PinInputTextField(
              pinLength: 6,
              decoration:
                  UnderlineDecoration(gapSpace: 20, color: Colors.grey[800]),
              controller: otpController,
              focusNode: nodeOTP,
              textInputAction: TextInputAction.go,
              enabled: isLoading ? false : true,
              keyboardType: TextInputType.number,
              onSubmit: (pin) async {
                if (otpController.text.length == 6) {
                  _onFormSubmitted();
                } else {
                  showToast("Please enter 6 digit OTP!", Colors.red);
                }
              },
              enableInteractiveSelection: true,
            ),
          ),
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
                  if (otpController.text.length == 6) {
                    _onFormSubmitted();
                  } else {
                    showToast("Please enter 6 digit OTP!", Colors.red);
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
                  "VERIFY OTP",
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
                    _buildMobileTF(),
                    SizedBox(height: 20.0),
                    _buildContinueBtn(),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Don't received OTP? ",
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
          Navigator.pushNamedAndRemoveUntil(
              context, "/change_password", (Route<dynamic> route) => false);
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
        Navigator.pushNamedAndRemoveUntil(
            context, "/change_password", (Route<dynamic> route) => false);
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
