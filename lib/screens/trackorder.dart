import 'dart:async';

import 'package:ecommerce/main.dart';
import 'package:ecommerce/size_config.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:geolocator/geolocator.dart';

class TrackOrder extends StatefulWidget {
  @override
  _TrackOrderState createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Track your Order",
          style: TextStyle(color: Colors.red),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Expanded(
          flex: 7,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.only(top: 10.0),
                  child: Card(
                    elevation: 3.0,
                    color: Color.fromRGBO(249, 249, 249, 1),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)),
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQ3W2b0jcCQUk6d4vQsnRfped9P8tM51dhYuQ&usqp=CAU"),
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Your rider",
                                    style: TextStyle(
                                      fontSize: 2.4 * SizeConfig.textMultiplier,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.clip,
                                  ),
                                  Text(
                                    "Chetan Nager",
                                    style: TextStyle(
                                      fontSize: 3.0 * SizeConfig.textMultiplier,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Divider(
                            height: 30.0,
                            color: Colors.grey,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Estimated Delivery Time",
                                  style: TextStyle(
                                    fontSize: 2.5 * SizeConfig.textMultiplier,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Text(
                                    "01-06-2020 11:00 am",
                                    style: TextStyle(
                                      fontSize: 2.3 * SizeConfig.textMultiplier,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.cyan,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: MapSample(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
//      floatingActionButton: FloatingActionButton(
//        tooltip: "Locate me",
//        onPressed: _goToTheLake,
//        child: Icon(Icons.my_location),
//      ),
    );
  }

  Future<void> _goToTheLake() async {
    var geolocator = Geolocator();
    var lat;
    var long;
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    StreamSubscription<Position> positionStream = geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      print(position == null
          ? 'Unknown'
          : position.latitude.toString() +
              ', ' +
              position.longitude.toString());
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });

    final CameraPosition _kLake = CameraPosition(
      //bearing: 192.8334901395799,
      target: LatLng(lat, long),
      //tilt: 59.440717697143555,
      //zoom: 19.151926040649414
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
