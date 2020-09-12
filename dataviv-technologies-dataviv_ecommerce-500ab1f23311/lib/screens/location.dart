import 'dart:async';

import 'package:ecommerce/constant/images.dart';
import 'package:ecommerce/constant/strings.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/constant/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  final GlobalKey<ScaffoldState> _locationscaffoldKey =
      new GlobalKey<ScaffoldState>();
  bool isLoading = false;

  Future getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    StreamSubscription<Position> positionStream = geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      if (position == null) {
        setState(() {
          isLoading = false;
        });
        showToastMessage("Unable to Fetch your Location!");
      } else {
        print(
            position.latitude.toString() + "," + position.longitude.toString());
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            isLoading = false;
          });
          Navigator.pushReplacementNamed(context, "/tabs");
        });
      }
    });
  }

  void showToastMessage(String msg) {
    _locationscaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(msg),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _locationscaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.grey[100].withOpacity(0.1),
        actions: <Widget>[
          FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            textColor: ThemeColors.redColor,
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/tabs");
            },
            child: Row(
              children: <Widget>[
                Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                FaIcon(
                  FontAwesomeIcons.angleDoubleRight,
                  size: 20.0,
                )
              ],
            ),
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.55,
              child: Image.asset(
                Images.locationPageLocationIcon,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              margin: EdgeInsets.only(top: 20),
              child: FittedBox(
                child: Text(
                  Strings.locationHiMessage,
                  style: TextStyle(
                    fontSize: 34.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              width: MediaQuery.of(context).size.width * 0.65,
              child: Text(
                Strings.locationChooseLocationMessage,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: OutlineButton(
                highlightedBorderColor: ThemeColors.redColor,
                borderSide: BorderSide(
                  color: ThemeColors.redColor,
                  width: 2,
                ),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(7.0)),
                color: ThemeColors.redColor,
                textColor: ThemeColors.redColor,
                onPressed: () {
                  getCurrentLocation();
                },
                child: isLoading
                    ? SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.navigation),
                          Text(
                            Strings.locationBtn,
                            style: TextStyle(fontSize: 19.0),
                          )
                        ],
                      ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(top: 50.0),
                child: Container(
                  margin: const EdgeInsets.only(top: 10.3),
                  height: 7,
                  width: MediaQuery.of(context).size.width * 0.30,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    border: Border.all(
                      color: Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
