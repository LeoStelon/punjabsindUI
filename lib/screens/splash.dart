import 'dart:convert';

import 'package:ecommerce/constant/images.dart';
import 'package:ecommerce/providers/global.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Future isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Global _global = Global();
    _global.getAuthToken().then((dynamic token) {
      if (token != null) {
        _global.isLoggedIn(token).then((dynamic response) async {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data["detail"] == "Invalid token.") {
            if (prefs.getBool("isFirstTimeOpenApp") == null) {
              Navigator.pushReplacementNamed((context), '/onboarding');
            } else {
              Navigator.pushReplacementNamed((context), '/intro');
            }
          } else if (data["status"] == "success" && data["message"] == "OK") {
            Map<String, dynamic> userDetails = data["data"][0];
            print(userDetails);
            await prefs.setString("userDetails", json.encode(userDetails));
            Navigator.pushReplacementNamed((context), '/location');
          }
        });
      } else {
        if (prefs.getBool("isFirstTimeOpenApp") == null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            Navigator.pushReplacementNamed((context), '/onboarding');
          });
        } else {
          Future.delayed(const Duration(milliseconds: 1000), () {
            Navigator.pushReplacementNamed((context), '/intro');
          });
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 251, 255, 1),
      body: new Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width * 0.7,
          child: new Image.asset(
            Images.splashScreenLogo,
            fit: BoxFit.fitWidth,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
