import 'package:ecommerce/constant/colors.dart';
import 'package:ecommerce/constant/images.dart';
import 'package:flutter/material.dart';

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  @override
  void initState() {
    super.initState();
    //isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: 15),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 7,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      //color: Colors.orange,
                      //height: MediaQuery.of(context).size.height * 0.6,
                      //width: MediaQuery.of(context).size.width * 0.5,
                      child: new Image.asset(
                        Images.splashScreenLogo,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      child: Container(
                        //color: Colors.red,
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: new Image.asset(
                          "images/s37.png",
                          fit: BoxFit.fitHeight,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  Container(
                    //margin: EdgeInsets.only(top: 20),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: RaisedButton(
                      elevation: 3.0,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                      padding: EdgeInsets.symmetric(vertical: 18.0),
                      onPressed: () {
                        Navigator.pushReplacementNamed((context), '/login');
                      },
                      color: ThemeColors.blueColor,
                      textColor: Colors.white,
                      child: Text(
                        "LOGIN",
                        style: TextStyle(
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: RaisedButton(
                      elevation: 2.0,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                      padding: EdgeInsets.symmetric(vertical: 18.0),
                      onPressed: () {
                        Navigator.pushReplacementNamed((context), '/signup');
                      },
                      color: ThemeColors.yellowColor,
                      textColor: Colors.black,
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
